import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Trigger: onWrite (Création, modification, ou suppression d'un avis)
 * Action: Recalcule la note moyenne et le nombre d'avis pour l'entreprise ciblée.
 */
export const recalculerNoteMoyenne = functions.firestore
  .document("avis/{avisId}")
  .onWrite(async (change, context) => {
    // Récupérer les données après (si existe, sinon avant en cas de suppression)
    const avisData = change.after.exists ? change.after.data() : change.before.data();
    
    if (!avisData) return null;
    
    const targetId = avisData.targetId;
    const targetType = avisData.targetType; // 'entreprise' ou 'chef_chantier'

    if (!targetId || !targetType) {
      console.log("Missing targetId or targetType");
      return null;
    }

    // Déterminer la collection cible en fonction du type
    let targetCollection = "";
    if (targetType === "entreprise") {
      targetCollection = "entreprises";
    } else if (targetType === "chef_chantier") {
      targetCollection = "users"; // Ou la collection appropriée
    } else {
      console.log(`Unknown targetType: ${targetType}`);
      return null;
    }

    try {
      // 1. Récupérer tous les avis valides pour cette cible
      const avisSnapshot = await db
        .collection("avis")
        .where("targetId", "==", targetId)
        .where("targetType", "==", targetType)
        .get();

      let totalNote = 0;
      let validAvisCount = 0;

      // 2. Calculer la somme
      avisSnapshot.forEach((doc) => {
        const data = doc.data();
        if (data.note !== undefined && typeof data.note === "number") {
          totalNote += data.note;
          validAvisCount++;
        }
      });

      // 3. Calculer la moyenne (arrondie à 1 décimale)
      const noteMoyenne = validAvisCount > 0 ? Math.round((totalNote / validAvisCount) * 10) / 10 : 0;

      // 4. Mettre à jour le document de la cible
      await db.collection(targetCollection).doc(targetId).update({
        noteMoyenne: noteMoyenne,
        nombreAvis: validAvisCount
      });

      console.log(`Note moyenne de ${targetId} mise à jour: ${noteMoyenne} (${validAvisCount} avis)`);
      return null;
    } catch (error) {
      console.error("Erreur lors du recalcul de la note:", error);
      return null;
    }
  });
