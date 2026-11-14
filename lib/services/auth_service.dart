import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    messaging: FirebaseMessaging.instance,
  );
});

final userAuthStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  AuthService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required FirebaseMessaging messaging,
  })  : _auth = auth,
        _firestore = firestore,
        _messaging = messaging;

  User? get currentUser => _auth.currentUser;

  /// Signs in anonymously on initial app launch if user is not signed in,
  /// and updates/saves the FCM token in Firestore under `users/{uid}`.
  Future<User?> initializeAnonymousAuth() async {
    User? user = _auth.currentUser;
    if (user == null) {
      final credential = await _auth.signInAnonymously();
      user = credential.user;
    }

    if (user != null) {
      await saveFcmToken(user.uid);
      _listenToTokenRefresh(user.uid);
    }

    return user;
  }

  /// Saves the device FCM token to Firestore document `users/{uid}.fcmToken`.
  Future<void> saveFcmToken(String uid) async {
    try {
      final String? token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(uid).set(
          {
            'fcmToken': token,
            'lastTokenUpdate': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
    } catch (e) {
      // FCM token fetch might fail if Google Play Services are missing or not ready
    }
  }

  /// Listens for FCM token refreshes and updates Firestore.
  void _listenToTokenRefresh(String uid) {
    _messaging.onTokenRefresh.listen((newToken) async {
      try {
        await _firestore.collection('users').doc(uid).set(
          {
            'fcmToken': newToken,
            'lastTokenUpdate': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } catch (_) {}
    });
  }
}
