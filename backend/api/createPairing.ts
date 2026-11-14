import { VercelRequest, VercelResponse } from '@vercel/node';
import { db, default as admin } from '../lib/firebaseAdmin';
import { verifyRequest } from '../lib/auth';
import { randomBytes } from 'crypto';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  const uid = await verifyRequest(req, res);
  if (!uid) return;

  try {
    const pairId = randomBytes(6).toString('hex');
    const now = Date.now();
    const expiresAt = now + 24 * 60 * 60 * 1000; // 24 hours from creation

    const host = req.headers.host || 'YOUR_PROJECT.vercel.app';
    const protocol = req.headers['x-forwarded-proto'] || 'https';
    const link = `${protocol}://${host}/pair/${pairId}`;

    await db.collection('pairings').doc(pairId).set({
      pairId,
      creatorUid: uid,
      status: 'pending',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt,
    });

    return res.status(200).json({ pairId, link });
  } catch (error: any) {
    return res.status(500).json({ error: 'Failed to create pairing', message: error.message });
  }
}
