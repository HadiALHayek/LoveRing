import { VercelRequest, VercelResponse } from '@vercel/node';
import { db, default as admin } from '../lib/firebaseAdmin';
import { verifyRequest } from '../lib/auth';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  const uid = await verifyRequest(req, res);
  if (!uid) return;

  try {
    await db.runTransaction(async (transaction) => {
      const userRef = db.collection('users').doc(uid);
      const userDoc = await transaction.get(userRef);

      if (!userDoc.exists) {
        return;
      }

      const userData = userDoc.data()!;
      const partnerUid = userData.partnerUid;
      const pairId = userData.pairId;

      if (partnerUid) {
        const partnerRef = db.collection('users').doc(partnerUid);
        transaction.update(partnerRef, {
          partnerUid: admin.firestore.FieldValue.delete(),
          pairId: admin.firestore.FieldValue.delete(),
        });
      }

      transaction.update(userRef, {
        partnerUid: admin.firestore.FieldValue.delete(),
        pairId: admin.firestore.FieldValue.delete(),
      });

      if (pairId) {
        const pairingRef = db.collection('pairings').doc(pairId);
        transaction.update(pairingRef, {
          status: 'unpaired',
          unpairedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    });

    return res.status(200).json({ success: true });
  } catch (error: any) {
    return res.status(500).json({ error: 'Failed to unpair', message: error.message });
  }
}
