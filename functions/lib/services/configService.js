"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getIAConfig = void 0;
const admin = require("firebase-admin");
// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
    admin.initializeApp();
}
const db = admin.firestore();
const DEFAULT_CONFIG = {
    seuil_anomalie_depense: 1.5,
    seuil_confiance_retard: 0.8,
};
let cachedConfig = null;
let lastFetch = 0;
const CACHE_TTL = 1000 * 60 * 5; // 5 minutes
async function getIAConfig() {
    const now = Date.now();
    if (cachedConfig && (now - lastFetch) < CACHE_TTL) {
        return cachedConfig;
    }
    try {
        const doc = await db.collection('config').doc('config_ia').get();
        if (doc.exists) {
            const data = doc.data();
            cachedConfig = {
                seuil_anomalie_depense: data.seuil_anomalie_depense ?? DEFAULT_CONFIG.seuil_anomalie_depense,
                seuil_confiance_retard: data.seuil_confiance_retard ?? DEFAULT_CONFIG.seuil_confiance_retard,
            };
            lastFetch = now;
            return cachedConfig;
        }
    }
    catch (error) {
        console.error('Error fetching IA config, falling back to defaults', error);
    }
    cachedConfig = DEFAULT_CONFIG;
    lastFetch = now;
    return cachedConfig;
}
exports.getIAConfig = getIAConfig;
//# sourceMappingURL=configService.js.map