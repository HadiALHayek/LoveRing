import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  const serviceAccountEnv = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (!serviceAccountEnv) {
    throw new Error('FIREBASE_SERVICE_ACCOUNT environment variable is not defined.');
  }

  let serviceAccount: admin.ServiceAccount;
  try {
    serviceAccount = JSON.parse(serviceAccountEnv);
  } catch (error) {
    throw new Error('FIREBASE_SERVICE_ACCOUNT environment variable is not valid JSON.');
  }

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

export const db = admin.firestore();
export const auth = admin.auth();
export const messaging = admin.messaging();
export default admin;
