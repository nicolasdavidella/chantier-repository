import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';
import { getIAConfig } from '../services/configService';
import { sendNotificationToUser } from '../services/fcmService';

const db = admin.firestore();

/**
 * Triggered when a new expense (depense) is created or updated.
 * Compares the expense amount with historical averages for similar categories.
 */
export const detectAnomalieDepenses = onDocumentWritten('projets/{projectId}/depenses/{depenseId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;

  const depense = snapshot.after.exists ? snapshot.after.data() : null;
  // Ignore deletions
  if (!depense) return;

  const projectId = event.params.projectId;
  const montant = depense.montant;
  const categorie = depense.categorie;

  if (!montant || !categorie) return;

  try {
    const config = await getIAConfig();
    
    // Simulate fetching historical data for this category across all projects
    // In a real app, this might be aggregated periodically into a 'stats' collection
    // For now, we query the last 50 expenses of the same category
    const historySnapshot = await db.collectionGroup('depenses')
      .where('categorie', '==', categorie)
      .limit(50)
      .get();

    let totalMontant = 0;
    let count = 0;

    historySnapshot.forEach((doc) => {
      const data = doc.data();
      if (data.montant && typeof data.montant === 'number') {
        totalMontant += data.montant;
        count++;
      }
    });

    if (count > 5) { // Need a minimum sample size to be statistically significant
      const moyenne = totalMontant / count;
      const seuil = config.seuil_anomalie_depense; // e.g. 1.5

      // If the amount is > 150% of the average
      if (montant > (moyenne * seuil)) {
        console.log(`Anomalie detected for depense ${event.params.depenseId}: ${montant} vs avg ${moyenne}`);
        
        // 1. Create an IA alert in the project
        const alertRef = db.collection(`projets/${projectId}/alertes_ia`).doc();
        await alertRef.set({
          id: alertRef.id,
          type: 'anomalie_depense',
          titre: 'Dépense potentiellement excessive',
          description: `La dépense de ${montant}€ en ${categorie} est nettement supérieure à la moyenne historique (${Math.round(moyenne)}€).`,
          dateCreation: admin.firestore.FieldValue.serverTimestamp(),
          referenceId: event.params.depenseId,
          severite: 'haute',
          resolue: false
        });

        // 2. Fetch the project to find the client (userId)
        const projectDoc = await db.collection('projets').doc(projectId).get();
        const clientId = projectDoc.data()?.clientId;

        if (clientId) {
          // 3. Create In-App Notification
          const notifRef = db.collection(`users/${clientId}/notifications`).doc();
          await notifRef.set({
            id: notifRef.id,
            userId: clientId,
            titre: 'Alerte IA Critique',
            corps: `Anomalie détectée dans les dépenses du chantier.`,
            type: 'alerte_ia',
            lienVersEcran: projectId,
            dateEnvoi: admin.firestore.FieldValue.serverTimestamp(),
            lu: false,
          });

          // 4. Send Push Notification
          await sendNotificationToUser(
            clientId,
            '⚠️ Alerte IA: Dépense Anormale',
            `Une dépense de ${montant}€ a été détectée comme anormale sur votre chantier.`,
            'alerte_ia',
            projectId
          );
        }
      }
    }
  } catch (error) {
    console.error('Error in detectAnomalieDepenses', error);
  }
});
