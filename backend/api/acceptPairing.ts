import { VercelRequest, VercelResponse } from '@vercel/node';
import { db, default as admin } from '../lib/firebaseAdmin';
import { verifyRequest } from '../lib/auth';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  const uid = await verifyRequest(req, res);
  if (!uid) return;

  const { pairId } = req.body || {};
  if (!pairId || typeof pairId !== 'string') {
    return res.status(400).json({ error: 'Missing or invalid pairId' });
  }

  try {
    const result = await db.runTransaction(async (transaction) => {
      const pairingRef = db.collection('pairings').doc(pairId);
      const pairingDoc = await transaction.get(pairingRef);

      if (!pairingDoc.exists) {
        return { status: 404, message: 'Pairing link not found' };
      }

      const pairingData = pairingDoc.data()!;
      const { creatorUid, status, expiresAt } = pairingData;

      if (creatorUid === uid) {
        return { status: 400, message: 'Cannot pair with yourself' };
      }

      if (status !== 'pending') {
        return { status: 409, message: 'Pairing code has already been used or is no longer pending' };
      }

      if (typeof expiresAt === 'number' && Date.now() > expiresAt) {
        return { status: 400, message: 'Pairing link has expired' };
      }

      const userRef = db.collection('users').doc(uid);
      const creatorUserRef = db.collection('users').doc(creatorUid);

      transaction.update(pairingRef, {
        status: 'connected',
        partnerUid: uid,
        acceptedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      transaction.set(userRef, { partnerUid: creatorUid, pairId }, { merge: true });
      transaction.set(creatorUserRef, { partnerUid: uid, pairId }, { merge: true });

      return { status: 200, partnerUid: creatorUid, pairId };
    });

    if (result.status !== 200) {
      return res.status(result.status).json({ error: result.message });
    }

    return res.status(200).json({
      success: true,
      partnerUid: result.partnerUid,
      pairId: result.pairId,
    });
  } catch (error: any) {
    return res.status(500).json({ error: 'Failed to accept pairing', message: error.message });
  }
}
