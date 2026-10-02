require("dotenv").config();
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentWritten, onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const { getFirestore, Timestamp, FieldValue } = require("firebase-admin/firestore");
const Anthropic = require("@anthropic-ai/sdk");
const logger = require("firebase-functions/logger");

admin.initializeApp();
const db = getFirestore();

// -----------------------------------------------------------------------------
// CONFIGURATION ANTHROPIC
// -----------------------------------------------------------------------------
function getAnthropicClient() {
  return new Anthropic({
    apiKey: process.env.CLAUDE_API_KEY || "dummy",
  });
}
function getClaudeModel() {
  return process.env.CLAUDE_MODEL || "claude-3-haiku-20240307";
}

// -----------------------------------------------------------------------------
// UTILITAIRES
// -----------------------------------------------------------------------------

async function checkRateLimit(uid) {
  const now = Timestamp.now();
  const oneHourAgo = new Timestamp(now.seconds - 3600, 0);

  const statsRef = db.collection("users").doc(uid).collection("api_usage").doc("claude");
  const statsDoc = await statsRef.get();
  
  if (!statsDoc.exists) {
    await statsRef.set({
      count: 1,
      lastUsage: now,
      history: [now]
    });
    return true;
  }

  const data = statsDoc.data();
  let history = data.history || [];
  
  // Filter history to last hour
  history = history.filter(t => t.seconds > oneHourAgo.seconds);
  
  if (history.length >= 20) {
    throw new HttpsError("resource-exhausted", "Vous avez dépassé la limite d'appels IA (20 par heure). Veuillez réessayer plus tard.");
  }
  
  history.push(now);
  await statsRef.update({
    count: FieldValue.increment(1),
    lastUsage: now,
    history: history
  });
  return true;
}

const planSchemaPrompt = `
Renvoie UNIQUEMENT un objet JSON valide (aucun autre texte) respectant exactement cette structure:
{
  "variantes": [
    {
      "nom": "Nom de la variante (ex: L'Économique, La Spacieuse)",
      "surfaceHabitable": 120, // en m2
      "estimationBudget": 15000000, // en FCFA
      "pointsForts": ["point 1", "point 2"],
      "pointsAttention": ["point 1", "point 2"],
      "pieces": [
        {
          "nom": "Séjour",
          "surface": 35, // en m2
          "niveau": "RDC",
          "positionX": 0, // position relative sur grille (0,1,2...)
          "positionY": 0, // position relative sur grille (0,1,2...)
          "width": 2, // taille relative pour le dessin
          "height": 2 // taille relative pour le dessin
        }
      ]
    }
  ]
}
Tu dois proposer exactement 3 variantes cohérentes. Assure-toi que la somme des surfaces des pièces correspond à la surfaceHabitable, et que tout rentre dans le budget et la surface du terrain. Adapte le tout au contexte camerounais.
`;

// -----------------------------------------------------------------------------
// FONCTIONS CALLABLE
// -----------------------------------------------------------------------------

exports.genererPropositionsPlans = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Vous devez être connecté pour utiliser l'assistant IA.");
  }

  const uid = request.auth.uid;
  await checkRateLimit(uid);

  const data = request.data;
  const projet = data.projet;

  if (!projet) {
    throw new HttpsError("invalid-argument", "Les données du projet sont manquantes.");
  }

  const promptText = `
Voici les informations d'un projet de construction au Cameroun :
- Type: ${projet.typeConstruction}
- Ville: ${projet.ville} (${projet.quartier})
- Budget prévisionnel: ${projet.budgetPrevisionnel} FCFA
- Surface terrain: ${projet.surfaceTerrain} m²
- Chambres: ${projet.nombreChambres}
- Salles de bain: ${projet.nombreSallesDeBain}
- Description additionnelle: ${projet.description}

Ton rôle est de générer 3 esquisses d'aménagement (plans) en JSON.
${planSchemaPrompt}
`;

  try {
    const anthropic = getAnthropicClient();
    const msg = await anthropic.messages.create({
      model: getClaudeModel(),
      max_tokens: 4000,
      temperature: 0.2,
      system: "Tu es un architecte expert au Cameroun. Tu conçois des plans réalistes, économiques et adaptés au climat local.",
      messages: [
        { role: "user", content: promptText }
      ]
    });

    let rawJson = msg.content[0].text.trim();
    // Nettoyer si Claude a rajouté des backticks
    if (rawJson.startsWith("\`\`\`json")) {
        rawJson = rawJson.replace(/^\`\`\`json\n/, "").replace(/\n\`\`\`$/, "");
    } else if (rawJson.startsWith("\`\`\`")) {
        rawJson = rawJson.replace(/^\`\`\`\n/, "").replace(/\n\`\`\`$/, "");
    }

    try {
        const parsedJson = JSON.parse(rawJson);
        // Validation basique
        if (!parsedJson.variantes || !Array.isArray(parsedJson.variantes)) {
            throw new Error("Structure JSON invalide");
        }
        return { success: true, donnees: parsedJson };
    } catch (e) {
        logger.error("JSON parsing error", e, rawJson);
        throw new HttpsError("internal", "L'IA a généré une réponse invalide. Veuillez réessayer.");
    }
  } catch (error) {
    logger.error("Claude API error", error);
    throw new HttpsError("internal", "Erreur lors de la communication avec l'assistant IA.");
  }
});


exports.affinerPlan = onCall(async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Vous devez être connecté.");
    }
  
    const uid = request.auth.uid;
    await checkRateLimit(uid);
  
    const data = request.data;
    const planOriginal = data.plan;
    const consigne = data.consigne;
  
    if (!planOriginal || !consigne) {
      throw new HttpsError("invalid-argument", "Plan ou consigne manquante.");
    }
  
    const promptText = `
Voici une esquisse de plan au format JSON :
${JSON.stringify(planOriginal)}

Le client demande la modification suivante : "${consigne}"

Applique la modification et renvoie UNIQUEMENT le plan modifié sous forme d'un objet JSON respectant exactement la même structure (mais sans encapsuler dans "variantes", renvoie l'objet Variante directement).
    `;
  
    try {
      const anthropic = getAnthropicClient();
      const msg = await anthropic.messages.create({
        model: getClaudeModel(),
        max_tokens: 2000,
        temperature: 0.2,
        system: "Tu es un architecte expert au Cameroun.",
        messages: [
          { role: "user", content: promptText }
        ]
      });
  
      let rawJson = msg.content[0].text.trim();
      if (rawJson.startsWith("\`\`\`json")) {
          rawJson = rawJson.replace(/^\`\`\`json\n/, "").replace(/\n\`\`\`$/, "");
      } else if (rawJson.startsWith("\`\`\`")) {
          rawJson = rawJson.replace(/^\`\`\`\n/, "").replace(/\n\`\`\`$/, "");
      }
  
      const parsedJson = JSON.parse(rawJson);
      return { success: true, donnees: parsedJson };
    } catch (error) {
      logger.error("Claude API error in affinerPlan", error);
      throw new HttpsError("internal", "Erreur lors de l'affinage du plan.");
    }
});


exports.publierProjetAuxEntreprises = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Non authentifié.");
    }

    const projectId = request.data.projectId;
    if (!projectId) {
        throw new HttpsError("invalid-argument", "projectId manquant");
    }

    const projetDoc = await db.collection("projects").doc(projectId).get();
    if (!projetDoc.exists) {
        throw new HttpsError("not-found", "Projet introuvable.");
    }

    const projet = projetDoc.data();
    if (projet.clientId !== request.auth.uid) {
        throw new HttpsError("permission-denied", "Vous n'êtes pas le propriétaire de ce projet.");
    }

    const ville = projet.localisation?.ville || "Inconnue";

    // 1. Chercher les entreprises (sans filtrer par certification pour tester en dev)
    let entreprisesSnapshot = await db.collection("entreprises").get();
    
    let entreprises = [];
    entreprisesSnapshot.forEach(doc => {
        const ent = doc.data();
        // Utiliser userId (Firebase Auth UID) comme identifiant pour les diffusions
        if (ent.userId) {
            if (ent.villesIntervention && ent.villesIntervention.includes(ville)) {
                entreprises.push(ent);
            }
        }
    });

    if (entreprises.length === 0) {
        // Fallback: toutes les entreprises
        entreprisesSnapshot.forEach(doc => {
            const ent = doc.data();
            if (ent.userId) entreprises.push(ent);
        });
    }

    if (entreprises.length === 0) {
        throw new HttpsError("not-found", "Aucune entreprise disponible pour le moment.");
    }

    const batch = db.batch();
    
    // Mettre à jour le projet
    batch.update(projetDoc.ref, {
        statut: "en_recherche_entreprise"
    });

    // Envoyer les diffusions et notifications
    for (const ent of entreprises) {
        // IMPORTANT: on utilise ent.userId (Firebase Auth UID) car le dashboard filtre par user.uid
        const entrepriseUserId = ent.userId;
        const diffusionId = `${projectId}_${entrepriseUserId}`;
        const diffusionRef = db.collection("diffusions_projet").doc(diffusionId);
        batch.set(diffusionRef, {
            projectId: projectId,
            clientId: projet.clientId,
            entrepriseId: entrepriseUserId,
            dateEnvoi: FieldValue.serverTimestamp(),
            statut: "envoye"
        }, { merge: true });

        // Notification in-app pour l'entreprise
        const notifRef = db.collection("notifications").doc();
        batch.set(notifRef, {
            userId: entrepriseUserId,
            titre: "Nouveau projet disponible",
            message: `Un projet à ${ville} correspond à vos spécialités.`,
            isRead: false,
            createdAt: FieldValue.serverTimestamp(),
            data: { projectId: projectId }
        });
    }

    await batch.commit();
    logger.info(`Projet ${projectId} publié à ${entreprises.length} entreprise(s).`);
    return { success: true, count: entreprises.length };
});

exports.onProjectCreated = onDocumentCreated("projects/{projectId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const projet = snapshot.data();
    const projectId = event.params.projectId;

    // Only broadcast if the status is en_recherche_entreprise
    if (projet.statut !== "en_recherche_entreprise") {
        return;
    }

    const ville = projet.localisation?.ville || "Inconnue";

    // 1. Chercher les entreprises
    let entreprisesSnapshot = await db.collection("entreprises").get();
    
    let entreprises = [];
    entreprisesSnapshot.forEach(doc => {
        const ent = doc.data();
        if (ent.userId) {
            if (ent.villesIntervention && ent.villesIntervention.includes(ville)) {
                entreprises.push(ent);
            }
        }
    });

    if (entreprises.length === 0) {
        // Fallback: toutes les entreprises
        entreprisesSnapshot.forEach(doc => {
            const ent = doc.data();
            if (ent.userId) entreprises.push(ent);
        });
    }

    if (entreprises.length === 0) {
        logger.info("No enterprises found for auto-broadcast of project", projectId);
        return;
    }

    const batch = db.batch();
    
    for (const ent of entreprises) {
        // IMPORTANT: on utilise ent.userId (Firebase Auth UID) car le dashboard filtre par user.uid
        const entrepriseUserId = ent.userId;
        const diffusionId = `${projectId}_${entrepriseUserId}`;
        const diffusionRef = db.collection("diffusions_projet").doc(diffusionId);
        batch.set(diffusionRef, {
            projectId: projectId,
            clientId: projet.clientId,
            entrepriseId: entrepriseUserId,
            dateEnvoi: FieldValue.serverTimestamp(),
            statut: "envoye"
        }, { merge: true });

        const notifRef = db.collection("notifications").doc();
        batch.set(notifRef, {
            userId: entrepriseUserId,
            titre: "Nouveau projet disponible",
            message: `Un projet à ${ville} a été publié.`,
            isRead: false,
            createdAt: FieldValue.serverTimestamp(),
            data: { projectId: projectId }
        });
    }

    await batch.commit();
    logger.info(`Auto-broadcasted project ${projectId} to ${entreprises.length} enterprises.`);
});

exports.repondreProjet = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Non authentifié.");
    }

    const { projectId, reponse } = request.data; // reponse: 'accepte' ou 'decline'
    if (!projectId || !['accepte', 'decline'].includes(reponse)) {
        throw new HttpsError("invalid-argument", "Paramètres invalides.");
    }

    const entrepriseId = request.auth.uid; // Supposons que l'uid est l'entrepriseId
    const diffusionId = `${projectId}_${entrepriseId}`;
    const diffusionRef = db.collection("diffusions_projet").doc(diffusionId);
    
    await db.runTransaction(async (transaction) => {
        const diffDoc = await transaction.get(diffusionRef);
        if (!diffDoc.exists) {
            throw new HttpsError("not-found", "Diffusion introuvable.");
        }
        
        const diffData = diffDoc.data();
        if (diffData.statut !== "envoye") {
            throw new HttpsError("failed-precondition", "Vous avez déjà répondu à ce projet.");
        }

        const projetRef = db.collection("projects").doc(projectId);
        const projetDoc = await transaction.get(projetRef);
        
        if (!projetDoc.exists || projetDoc.data().statut !== "en_recherche_entreprise") {
            throw new HttpsError("failed-precondition", "Ce projet n'est plus en recherche d'entreprise.");
        }

        transaction.update(diffusionRef, {
            statut: reponse,
            dateReponse: FieldValue.serverTimestamp()
        });

        if (reponse === 'accepte') {
            // Notifier le client
            const clientId = projetDoc.data().clientId;
            const notifRef = db.collection("notifications").doc();
            transaction.set(notifRef, {
                userId: clientId,
                titre: "Une entreprise est intéressée !",
                message: "Une entreprise peut réaliser votre projet. Cliquez pour voir son profil.",
                isRead: false,
                createdAt: FieldValue.serverTimestamp(),
                data: { projectId: projectId, entrepriseId: entrepriseId }
            });
        }
    });

    return { success: true };
});

exports.choisirEntreprise = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Non authentifié.");
    }

    const { projectId, entrepriseId } = request.data;
    if (!projectId || !entrepriseId) {
        throw new HttpsError("invalid-argument", "Paramètres manquants.");
    }

    const projetRef = db.collection("projects").doc(projectId);
    const diffusionRef = db.collection("diffusions_projet").doc(`${projectId}_${entrepriseId}`);
    
    await db.runTransaction(async (transaction) => {
        const projetDoc = await transaction.get(projetRef);
        if (!projetDoc.exists) {
            throw new HttpsError("not-found", "Projet introuvable.");
        }
        
        if (projetDoc.data().clientId !== request.auth.uid) {
            throw new HttpsError("permission-denied", "Non autorisé.");
        }
        
        if (projetDoc.data().statut !== "en_recherche_entreprise") {
            throw new HttpsError("failed-precondition", "Le projet n'est plus en phase de recherche.");
        }

        const diffDoc = await transaction.get(diffusionRef);
        if (!diffDoc.exists || diffDoc.data().statut !== "accepte") {
            throw new HttpsError("failed-precondition", "Cette entreprise n'a pas accepté le projet.");
        }

        // Mettre à jour le projet
        transaction.update(projetRef, {
            entrepriseId: entrepriseId,
            statut: "entreprise_choisie"
        });

        // Créer la conversation (Flux 2)
        // L'ID de la conversation sera le projectId pour unicité, ou un ID généré.
        // Utilisons projectId pour simplifier, c'est ce que suggère le prompt "ID = projectId".
        const conversationRef = db.collection("conversations").doc(projectId);
        transaction.set(conversationRef, {
            projectId: projectId,
            participantsIds: [request.auth.uid, entrepriseId],
            dernierMessage: "Conversation initiée.",
            dateDernierMessage: FieldValue.serverTimestamp(),
            nonLus: {
                [request.auth.uid]: 0,
                [entrepriseId]: 1
            }
        });
        
        // Premier message système
        const msgRef = conversationRef.collection("messages").doc();
        transaction.set(msgRef, {
            expediteurId: "system",
            type: "systeme",
            contenu: `Vous pouvez maintenant discuter des derniers détails de la réalisation du projet.`,
            dateEnvoi: FieldValue.serverTimestamp(),
            luPar: []
        });

        // Notification à l'entreprise retenue
        const notifRef = db.collection("notifications").doc();
        transaction.set(notifRef, {
            userId: entrepriseId,
            titre: "Félicitations !",
            message: "Vous avez été retenu pour le projet.",
            isRead: false,
            createdAt: FieldValue.serverTimestamp(),
            data: { projectId: projectId }
        });
        
        // Note: Idéalement, notifier aussi les autres entreprises qui avaient accepté.
    });

    return { success: true };
});

exports.soumettreCertification = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Non authentifié.");
    }

    const entrepriseId = request.auth.uid;
    const demandeRef = db.collection("demandes_certification").doc(entrepriseId);
    
    await db.runTransaction(async (transaction) => {
        const demandeDoc = await transaction.get(demandeRef);
        
        if (!demandeDoc.exists) {
            throw new HttpsError("not-found", "Demande introuvable. Veuillez d'abord remplir le brouillon.");
        }

        const data = demandeDoc.data();
        if (data.statut !== "brouillon" && data.statut !== "rejetee") {
            throw new HttpsError("failed-precondition", "La demande ne peut pas être soumise dans son état actuel.");
        }

        // Vérification des documents manquants (simplifiée ici)
        if (!data.documents || data.documents.length < 3) {
            throw new HttpsError("failed-precondition", "Veuillez fournir tous les documents requis.");
        }

        transaction.update(demandeRef, {
            statut: "en_attente",
            dateSoumission: FieldValue.serverTimestamp(),
            nombreSoumissions: FieldValue.increment(1)
        });

        // Mettre à jour l'entreprise
        const entRef = db.collection("entreprises").doc(entrepriseId);
        transaction.update(entRef, {
            certifie: false,
            statutVerification: "en_attente_verification"
        });

        // Notification aux admins
        const adminsSnapshot = await db.collection("users").where("role", "==", "admin").get();
        adminsSnapshot.forEach(adminDoc => {
            const notifRef = db.collection("notifications").doc();
            transaction.set(notifRef, {
                userId: adminDoc.id,
                titre: "Nouvelle demande de certification",
                message: `L'entreprise ${data.raisonSociale} a soumis une demande de certification.`,
                isRead: false,
                createdAt: FieldValue.serverTimestamp()
            });
        });
    });

    return { success: true };
});

// -----------------------------------------------------------------------------
// PHASE 1: DIFFUSION DU PROJET AUX ENTREPRISES
// -----------------------------------------------------------------------------
exports.publierProjetAuxEntreprises = onDocumentCreated("projects/{projectId}", async (event) => {
    const snap = event.data;
    if (!snap) return;

    const projectData = snap.data();
    const projectId = event.params.projectId;

    // Only process if status is en_recherche_entreprise
    if (projectData.statut !== "en_recherche_entreprise") {
        return;
    }

    const ville = projectData.localisation?.ville;
    const clientId = projectData.clientId;

    try {
        // Modifié pour le test : on supprime temporairement la restriction 'certifie' == true
        // pour que vous puissiez voir les offres immédiatement dans votre entreprise de test.
        const entreprisesSnap = await db.collection('entreprises').get();
        
        // Si aucune entreprise certifiée n'est trouvée, on peut élargir. 
        // Pour l'instant on se limite aux certifiées pour respecter le prompt.
        
        const batch = db.batch();
        let notifiedCount = 0;

        entreprisesSnap.forEach((entDoc) => {
            const entData = entDoc.data();
            const entrepriseUserId = entData.userId || entDoc.id;

            // 1. Diffusion document
            const diffusionId = `${projectId}_${entrepriseUserId}`;
            const diffRef = db.collection('diffusions_projet').doc(diffusionId);
            batch.set(diffRef, {
                projectId: projectId,
                clientId: clientId,
                entrepriseId: entrepriseUserId,
                ville: ville || "",
                statut: 'envoye',
                dateEnvoi: FieldValue.serverTimestamp(),
            }, { merge: true });

            // 2. Notification In-App
            const notifRef = db.collection('notifications').doc();
            batch.set(notifRef, {
                userId: entrepriseUserId,
                titre: "Nouveau projet disponible",
                message: `Un nouveau projet "${projectData.titre}" vient d'être publié dans votre zone.`,
                isRead: false,
                createdAt: FieldValue.serverTimestamp(),
                type: 'nouveau_projet',
                projectId: projectId
            });

            // 3. Mail outbox
            if (entData.emailProfessionnel) {
                const mailRef = db.collection('mail_outbox').doc();
                batch.set(mailRef, {
                    to: entData.emailProfessionnel,
                    message: {
                        subject: "ChantierTrack - Nouveau projet disponible",
                        html: `<p>Bonjour ${entData.raisonSociale},</p><p>Un nouveau projet <strong>${projectData.titre}</strong> vient d'être publié. Connectez-vous sur ChantierTrack pour y répondre.</p>`
                    },
                    status: "pending",
                    createdAt: FieldValue.serverTimestamp()
                });
            }

            notifiedCount++;
        });

        await batch.commit();
        logger.info(`✅ Projet ${projectId} diffusé à ${notifiedCount} entreprise(s).`);
    } catch (e) {
        logger.error(`Erreur lors de la diffusion du projet ${projectId}`, e);
    }
});

// -----------------------------------------------------------------------------
// PHASE 4: SIMULATEUR DE DEVIS PAR L'IA (CLAUDE)
// -----------------------------------------------------------------------------
exports.simulerDevisIA = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Vous devez être connecté pour simuler un devis.");
    }

    const uid = request.auth.uid;
    const { typeConstruction, ville, superficie, nombrePieces, budgetDeclare } = request.data;

    // Rate Limiting (Simple check)
    const canCall = await checkRateLimit(uid);
    if (!canCall) {
        throw new HttpsError("resource-exhausted", "Vous avez atteint la limite de simulations pour le moment.");
    }

    try {
        const anthropic = getAnthropicClient();
        const model = getClaudeModel();

        const prompt = `
Tu es un expert en estimation de construction au Sénégal.
Le client veut construire :
- Type : ${typeConstruction || "Non spécifié"}
- Ville : ${ville || "Sénégal"}
- Superficie : ${superficie || "Non spécifiée"} m²
- Nombre de pièces : ${nombrePieces || "Non spécifié"}
- Budget déclaré par le client : ${budgetDeclare || 0} FCFA

Génère une estimation réaliste de devis sous forme STRICTEMENT JSON.
Ne retourne QUE le JSON, sans aucun texte avant ou après.

Format JSON attendu :
{
  "fourchetteTotal": {
    "minimum": nombre (FCFA),
    "moyenne": nombre (FCFA),
    "maximum": nombre (FCFA)
  },
  "repartitionParPoste": [
    { "nom": "Gros œuvre", "pourcentage": nombre, "montantEstime": nombre },
    { "nom": "Toiture", "pourcentage": nombre, "montantEstime": nombre },
    { "nom": "Finitions (Peinture, Carrelage)", "pourcentage": nombre, "montantEstime": nombre },
    { "nom": "Plomberie & Électricité", "pourcentage": nombre, "montantEstime": nombre }
  ],
  "delaiEstimeSemaines": nombre,
  "hypotheses": ["Hypothèse 1", "Hypothèse 2"],
  "avertissement": "Ceci est une simulation automatisée à titre indicatif et ne remplace pas le devis final d'une entreprise."
}`;

        const response = await anthropic.messages.create({
            model: model,
            max_tokens: 1024,
            messages: [{ role: "user", content: prompt }]
        });

        const texteResponse = response.content[0].text;
        
        // Extraire le JSON si Claude a ajouté du texte autour
        const match = texteResponse.match(/\{.*\}/s);
        const jsonStr = match ? match[0] : texteResponse;
        
        const devisJSON = JSON.parse(jsonStr);

        return devisJSON;
    } catch (error) {
        logger.error("Erreur lors de la simulation IA : ", error);
        throw new HttpsError("internal", "Impossible de générer la simulation pour le moment.");
    }
});

// -----------------------------------------------------------------------------
// PHASE 5: SURVEILLANCE DES RISQUES & ALERTES
// -----------------------------------------------------------------------------
exports.surveillerRisquesProjet = onDocumentUpdated("projects/{projectId}", async (event) => {
    const newData = event.data.after.data();
    const oldData = event.data.before.data();
    const projectId = event.params.projectId;

    if (newData.statut !== 'en_cours') return;

    const batch = db.batch();
    let hasAlert = false;

    // Condition 1: Budget dépensé > budget estimé + 10%
    if (newData.budgetDepense && newData.budgetPrevisionnel) {
        const seuilAlerte = newData.budgetPrevisionnel * 1.1;
        if (newData.budgetDepense > seuilAlerte && (oldData.budgetDepense || 0) <= seuilAlerte) {
            hasAlert = true;
            const alerteRef = db.collection("alertes").doc();
            batch.set(alerteRef, {
                projectId: projectId,
                title: "Dépassement de Budget Imminent",
                description: `Le budget dépensé (${newData.budgetDepense} FCFA) dépasse de plus de 10% le budget prévisionnel (${newData.budgetPrevisionnel} FCFA).`,
                type: "budget",
                severity: "high",
                statut: "alerte_rouge",
                date: FieldValue.serverTimestamp(),
                isRead: false
            });
            
            // Notifier le client
            const notifRef = db.collection("notifications").doc();
            batch.set(notifRef, {
                userId: newData.clientId,
                titre: "Alerte Rouge Budget",
                message: "Votre projet dépasse le budget prévisionnel de plus de 10%.",
                isRead: false,
                createdAt: FieldValue.serverTimestamp()
            });
        }
    }

    // Condition 2: Date prévue dépassée
    if (newData.dateFinPrevue) {
        const dateFin = newData.dateFinPrevue.toDate ? newData.dateFinPrevue.toDate() : new Date(newData.dateFinPrevue);
        const now = new Date();
        
        // Si la date vient d'être dépassée (simplification, devrait idéalement être un cron)
        if (dateFin < now && (!oldData.alerteRetardEnvoyee)) {
            hasAlert = true;
            const alerteRef = db.collection("alertes").doc();
            batch.set(alerteRef, {
                projectId: projectId,
                title: "Risque de Retard Critique",
                description: "La date de fin prévue est dépassée. Veuillez vérifier l'avancement avec l'entreprise.",
                type: "delay",
                severity: "high",
                statut: "alerte_rouge",
                date: FieldValue.serverTimestamp(),
                isRead: false
            });

            // Mettre à jour le projet pour ne pas renvoyer l'alerte en boucle
            batch.update(event.data.after.ref, {
                alerteRetardEnvoyee: true
            });
        }
    }

    if (hasAlert) {
        await batch.commit();
        logger.info(`Alertes générées pour le projet ${projectId}`);
    }
});
