const admin = require('firebase-admin');
process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080';
admin.initializeApp({ projectId: 'chantier-track-test' });

const db = admin.firestore();

async function run() {
    const projectsSnap = await db.collection('projects').where('statut', '==', 'en_recherche_entreprise').get();
    const entreprisesSnap = await db.collection('entreprises').get();
    
    let count = 0;
    const batch = db.batch();
    
    projectsSnap.forEach(projDoc => {
        const p = projDoc.data();
        entreprisesSnap.forEach(entDoc => {
            const e = entDoc.data();
            const entId = e.userId || entDoc.id;
            
            const diffId = `${projDoc.id}_${entId}`;
            const diffRef = db.collection('diffusions_projet').doc(diffId);
            
            batch.set(diffRef, {
                projectId: projDoc.id,
                clientId: p.clientId,
                entrepriseId: entId,
                ville: p.localisation?.ville || "",
                statut: 'envoye',
                createdAt: admin.firestore.FieldValue.serverTimestamp()
            });
            count++;
        });
    });
    
    await batch.commit();
    console.log(`Created ${count} diffusions!`);
}

run().catch(console.error);
