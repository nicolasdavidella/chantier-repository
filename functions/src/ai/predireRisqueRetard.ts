import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';
import { getIAConfig } from '../services/configService';
import { sendNotificationToUser } from '../services/fcmService';

const db = admin.firestore();

/**
 * Triggered when a task is updated.
 * Compares current progress to the planned end date.
 */
export const predireRisqueRetard = onDocumentWritten('projets/{projectId}/taches/{tacheId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;

  const tache = snapshot.after.exists ? snapshot.after.data() : null;
  if (!tache) return;

  const projectId = event.params.projectId;
  const progression = tache.progression || 0; // 0 to 100
  const dateFinPrevue: admin.firestore.Timestamp | undefined = tache.dateFin;
  const dateDebutPrevue: admin.firestore.Timestamp | undefined = tache.dateDebut;

  if (progression === 100 || !dateFinPrevue || !dateDebutPrevue) return;

  try {
    const config = await getIAConfig();
    const now = new Date();
    
    const dureeTotale = dateFinPrevue.toMillis() - dateDebutPrevue.toMillis();
    const tempsEcoule = now.getTime() - dateDebutPrevue.toMillis();
    
    // Avoid division by zero or negative time
    if (dureeTotale <= 0 || tempsEcoule <= 0) return;

    // Expected progress based on linear time
    const expectedProgression = (tempsEcoule / dureeTotale) * 100;
    
    // If we are past the expected progress by a significant margin
    // Example: We are 80% through the time, but only 40% complete.
    // Confidence score calculation (simple ratio for demonstration)
    const ratio = progression / expectedProgression; // e.g. 40 / 80 = 0.5 (very bad)
    
    // We reverse the ratio to get a "risk confidence" where 1 is highest risk
    // If ratio >= 1, we are on track or ahead (risk = 0)
    // If ratio is 0.5, risk = 0.5.
    const risqueScore = ratio >= 1 ? 0 : (1 - ratio);

    if (risqueScore >= config.seuil_confiance_retard) { // e.g. 0.8
      console.log(`Risque de retard detecte sur tache ${event.params.tacheId}: progression ${progression}% vs attendu ${Math.round(expectedProgression)}%`);
      
      const alertRef = db.collection(`projets/${projectId}/alertes_ia`).doc();
      await alertRef.set({
        id: alertRef.id,
        type: 'risque_retard',
        titre: 'Risque de Retard Détecté',
        description: `La tâche "${tache.nom}" avance plus lentement que prévu (Confiance IA: ${Math.round(risqueScore * 100)}%).`,
        dateCreation: admin.firestore.FieldValue.serverTimestamp(),
        referenceId: event.params.tacheId,
        severite: 'moyenne',
        resolue: false
      });

      // Notify the Chef de Chantier (responsable)
      const responsableId = tache.assigneeA;
      if (responsableId) {
        await sendNotificationToUser(
          responsableId,
          '⚠️ Risque de Retard',
          `La tâche "${tache.nom}" semble prendre du retard.`,
          'alerte_ia',
          projectId
        );
      }
    }
  } catch (error) {
    console.error('Error in predireRisqueRetard', error);
  }
});
