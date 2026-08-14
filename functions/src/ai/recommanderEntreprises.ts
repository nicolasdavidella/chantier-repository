import { onCall } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

const db = admin.firestore();

interface RecommandationRequest {
  localisation: string;
  type_construction: string; // e.g. 'Residentiel', 'Commercial'
  budget: number;
}

/**
 * Callable function from the client app.
 * Takes project criteria and returns a sorted list of relevant enterprises based on a scoring algorithm.
 */
export const recommanderEntreprises = onCall<RecommandationRequest>(async (request) => {
  const data = request.data;
  const { localisation, type_construction } = data; // ignored budget for now

  try {
    // 1. Fetch all verified enterprises
    const entreprisesSnapshot = await db.collection('users')
      .where('role', '==', 'entreprise')
      .where('estVerifie', '==', true)
      .get();

    const entreprises = entreprisesSnapshot.docs.map(doc => {
      const e = doc.data() as any;
      return { id: doc.id, ...e } as any;
    });

    // 2. Score each enterprise
    const recommandations = entreprises.map(entreprise => {
      let score = 0;
      let matchingReasons: string[] = [];

      // A. Speciality Match (+10 pts)
      const specialites = (entreprise.specialites as string[]) || [];
      if (specialites.some(s => s.toLowerCase().includes(type_construction.toLowerCase()))) {
        score += 10;
        matchingReasons.push('Spécialité correspondante');
      }

      // B. Location Match (+10 pts)
      const zones = (entreprise.zonesIntervention as string[]) || [];
      if (zones.some(z => z.toLowerCase().includes(localisation.toLowerCase()))) {
        score += 10;
        matchingReasons.push('Intervient dans votre zone');
      }

      // C. Rating (Note moyenne) (* 2 pts per star)
      const noteMoyenne = entreprise.noteMoyenne || 0;
      score += (noteMoyenne * 2);
      if (noteMoyenne >= 4.0) matchingReasons.push('Excellente évaluation client');

      // D. Budget suitability (heuristic)
      // E.g. penalty if budget is very small and enterprise is massive, etc. (skipped for simplicity)

      return {
        entrepriseId: entreprise.id,
        nom: entreprise.nomEntreprise || entreprise.nom,
        score,
        noteMoyenne,
        reasons: matchingReasons
      };
    });

    // 3. Filter out zero scores and sort descending
    const result = recommandations
      .filter(r => r.score > 0)
      .sort((a, b) => b.score - a.score)
      .slice(0, 5); // Return top 5

    return { success: true, data: result };

  } catch (error) {
    console.error('Erreur recommanderEntreprises', error);
    return { success: false, error: 'Une erreur est survenue lors du calcul des recommandations.' };
  }
});
