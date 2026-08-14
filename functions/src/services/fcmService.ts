import * as admin from 'firebase-admin';

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

const messaging = admin.messaging();
const db = admin.firestore();

/**
 * Sends a push notification to a user by their userId.
 * It looks up their FCM token from the users collection.
 */
export async function sendNotificationToUser(
  userId: string,
  title: string,
  body: string,
  type: string,
  referenceId?: string
): Promise<void> {
  try {
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      console.log(`User ${userId} not found, skipping notification.`);
      return;
    }

    const userData = userDoc.data();
    const fcmToken = userData?.fcmToken;

    if (!fcmToken) {
      console.log(`No FCM token for user ${userId}, skipping notification.`);
      return;
    }

    const message: admin.messaging.Message = {
      token: fcmToken,
      notification: {
        title,
        body,
      },
      data: {
        type,
        referenceId: referenceId || '',
      },
    };

    const response = await messaging.send(message);
    console.log(`Successfully sent message to ${userId}:`, response);
  } catch (error) {
    console.error(`Error sending message to ${userId}:`, error);
  }
}
