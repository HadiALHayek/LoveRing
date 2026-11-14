import { VercelRequest, VercelResponse } from '@vercel/node';
import { db, messaging, default as admin } from '../lib/firebaseAdmin';
import { verifyRequest } from '../lib/auth';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  const uid = await verifyRequest(req, res);
  if (!uid) return;

  const { fromName = 'Your Love' } = req.body || {};

  try {
    // 1. Transaction to check pairing, verify rate limit (3s), and retrieve partner FCM token
    const transactionResult = await db.runTransaction(async (transaction) => {
      const userRef = db.collection('users').doc(uid);
      const userDoc = await transaction.get(userRef);

      if (!userDoc.exists) {
        return { status: 403, error: 'User profile not found' };
      }

      const userData = userDoc.data()!;
      const partnerUid = userData.partnerUid;

      if (!partnerUid) {
        return { status: 403, error: 'Not paired with any partner' };
      }

      // Check pairing document status
      const pairId = userData.pairId;
      if (pairId) {
        const pairingRef = db.collection('pairings').doc(pairId);
        const pairingDoc = await transaction.get(pairingRef);
        if (!pairingDoc.exists || pairingDoc.data()?.status !== 'connected') {
          return { status: 403, error: 'Pairing is not active or connected' };
        }
      }

      // Check rate limit: 3 seconds (3000 ms)
      const lastPingAt = userData.lastPingAt;
      const now = Date.now();
      if (typeof lastPingAt === 'number' && now - lastPingAt < 3000) {
        return { status: 429, error: 'Please wait at least 3 seconds between pings' };
      }

      // Fetch partner user doc to get fcmToken
      const partnerRef = db.collection('users').doc(partnerUid);
      const partnerDoc = await transaction.get(partnerRef);

      if (!partnerDoc.exists) {
        return { status: 403, error: 'Partner profile not found' };
      }

      const partnerData = partnerDoc.data()!;
      const fcmToken = partnerData.fcmToken;

      if (!fcmToken) {
        return { status: 400, error: 'Partner has no active FCM token' };
      }

      // Update rate limit timestamp
      transaction.update(userRef, { lastPingAt: now });

      return {
        status: 200,
        partnerUid,
        fcmToken,
      };
    });

    if (transactionResult.status !== 200) {
      return res.status(transactionResult.status).json({ error: transactionResult.error });
    }

    const { partnerUid, fcmToken } = transactionResult;

    // 2. Send DATA-ONLY, HIGH-priority FCM message
    try {
      await messaging.send({
        token: fcmToken,
        android: {
          priority: 'high',
          ttl: 0,
        },
        data: {
          type: 'ping',
          fromName: String(fromName),
          sentAt: new Date().toISOString(),
        },
      });
    } catch (fcmError: any) {
      if (
        fcmError.code === 'messaging/registration-token-not-registered' ||
        fcmError.code === 'messaging/invalid-registration-token'
      ) {
        // Clear stale token
        await db.collection('users').doc(partnerUid!).update({
          fcmToken: admin.firestore.FieldValue.delete(),
        });
        return res.status(410).json({ error: 'Partner registration token is no longer valid' });
      }
      throw fcmError;
    }

    // 3. Log ping in pings collection
    await db.collection('pings').add({
      fromUid: uid,
      toUid: partnerUid,
      fromName,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return res.status(200).json({ ok: true });
  } catch (error: any) {
    return res.status(500).json({ error: 'Failed to send ping', message: error.message });
  }
}
