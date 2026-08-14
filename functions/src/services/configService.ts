import * as admin from 'firebase-admin';

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

export interface IAConfig {
  seuil_anomalie_depense: number; // e.g. 1.5 (50% over expected)
  seuil_confiance_retard: number; // e.g. 0.8 (80% confidence)
}

const DEFAULT_CONFIG: IAConfig = {
  seuil_anomalie_depense: 1.5,
  seuil_confiance_retard: 0.8,
};

let cachedConfig: IAConfig | null = null;
let lastFetch = 0;
const CACHE_TTL = 1000 * 60 * 5; // 5 minutes

export async function getIAConfig(): Promise<IAConfig> {
  const now = Date.now();
  if (cachedConfig && (now - lastFetch) < CACHE_TTL) {
    return cachedConfig;
  }

  try {
    const doc = await db.collection('config').doc('config_ia').get();
    if (doc.exists) {
      const data = doc.data() as Partial<IAConfig>;
      cachedConfig = {
        seuil_anomalie_depense: data.seuil_anomalie_depense ?? DEFAULT_CONFIG.seuil_anomalie_depense,
        seuil_confiance_retard: data.seuil_confiance_retard ?? DEFAULT_CONFIG.seuil_confiance_retard,
      };
      lastFetch = now;
      return cachedConfig;
    }
  } catch (error) {
    console.error('Error fetching IA config, falling back to defaults', error);
  }

  cachedConfig = DEFAULT_CONFIG;
  lastFetch = now;
  return cachedConfig;
}
