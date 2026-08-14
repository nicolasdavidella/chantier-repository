"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.genererRapportPeriodique = void 0;
const scheduler_1 = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const openai_1 = require("openai");
const fcmService_1 = require("../services/fcmService");
const db = admin.firestore();
// Note: Ensure the API key is set in Firebase Secrets:
// firebase functions:secrets:set OPENAI_API_KEY
// For this example, we mock the call if the key is missing.
exports.genererRapportPeriodique = (0, scheduler_1.onSchedule)('every monday 08:00', async (event) => {
    try {
        const apiKey = process.env.OPENAI_API_KEY;
        const openai = apiKey ? new openai_1.default({ apiKey }) : null;
        // 1. Get all active projects
        const projetsSnapshot = await db.collection('projets')
            .where('statut', '==', 'en_cours')
            .get();
        const now = new Date();
        const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        const dateLimit = admin.firestore.Timestamp.fromDate(oneWeekAgo);
        for (const doc of projetsSnapshot.docs) {
            const projet = doc.data();
            const projectId = doc.id;
            const clientId = projet.clientId;
            // 2. Fetch data from the last 7 days
            // Depenses
            const depensesSnapshot = await db.collection(`projets/${projectId}/depenses`)
                .where('date', '>=', dateLimit)
                .get();
            const depenses = depensesSnapshot.docs.map(d => d.data());
            const totalDepenses = depenses.reduce((sum, d) => sum + (d.montant || 0), 0);
            // Rapports d'avancement
            const rapportsSnapshot = await db.collection(`projets/${projectId}/rapports`)
                .where('date', '>=', dateLimit)
                .get();
            const rapports = rapportsSnapshot.docs.map(d => d.data());
            // Only generate if there is new activity
            if (depenses.length === 0 && rapports.length === 0)
                continue;
            let resumeTexte = '';
            if (openai) {
                // 3a. Generate summary using LLM
                const prompt = `Génère un résumé clair, professionnel et rassurant (max 150 mots) pour le client concernant son projet de construction "${projet.titre}".
Données de la semaine :
- ${rapports.length} nouveaux rapports d'avancement soumis.
- ${depenses.length} nouvelles dépenses déclarées pour un total de ${totalDepenses}€.
- Avancement actuel du projet : ${projet.pourcentageAvancement}%.
Mets en évidence que le chantier suit son cours.`;
                const completion = await openai.chat.completions.create({
                    model: "gpt-4-turbo-preview",
                    messages: [{ role: "user", content: prompt }],
                });
                resumeTexte = completion.choices[0].message.content || 'Impossible de générer le résumé.';
            }
            else {
                // 3b. Fallback summary if no API key
                resumeTexte = `Résumé automatique : Cette semaine, ${rapports.length} rapports ont été ajoutés et ${totalDepenses}€ ont été dépensés. Le projet en est à ${projet.pourcentageAvancement}% d'avancement global.`;
            }
            // 4. Save the report to Firestore
            const summaryRef = db.collection(`projets/${projectId}/syntheses_hebdo`).doc();
            await summaryRef.set({
                id: summaryRef.id,
                dateGeneration: admin.firestore.FieldValue.serverTimestamp(),
                texte: resumeTexte,
                totalDepensesSemaine: totalDepenses,
                nombreRapportsSemaine: rapports.length
            });
            // 5. Notify the client
            if (clientId) {
                await (0, fcmService_1.sendNotificationToUser)(clientId, 'Résumé Hebdomadaire Disponible', 'Le point sur l\'avancement de votre chantier cette semaine est prêt.', 'rapport', summaryRef.id);
            }
        }
        console.log('Génération des rapports périodiques terminée avec succès.');
    }
    catch (error) {
        console.error('Erreur lors de la génération des rapports périodiques', error);
    }
});
//# sourceMappingURL=genererRapportPeriodique.js.map