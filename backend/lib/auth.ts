import { VercelRequest, VercelResponse } from '@vercel/node';
import { auth } from './firebaseAdmin';

export async function verifyRequest(
  req: VercelRequest,
  res: VercelResponse
): Promise<string | null> {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json({ error: 'Unauthorized: Missing or malformed Authorization header' });
    return null;
  }

  const token = authHeader.split('Bearer ')[1].trim();
  if (!token) {
    res.status(401).json({ error: 'Unauthorized: Empty Bearer token' });
    return null;
  }

  try {
    const decodedToken = await auth.verifyIdToken(token);
    return decodedToken.uid;
  } catch (error) {
    res.status(401).json({ error: 'Unauthorized: Invalid or expired Firebase ID token' });
    return null;
  }
}
