import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_client.dart';

class UserPairingInfo {
  final String? partnerUid;
  final String? pairId;
  final bool isConnected;

  UserPairingInfo({
    this.partnerUid,
    this.pairId,
    required this.isConnected,
  });

  factory UserPairingInfo.fromMap(Map<String, dynamic>? data) {
    if (data == null) return UserPairingInfo(isConnected: false);
    final partnerUid = data['partnerUid'] as String?;
    final pairId = data['pairId'] as String?;
    return UserPairingInfo(
      partnerUid: partnerUid,
      pairId: pairId,
      isConnected: partnerUid != null && partnerUid.isNotEmpty,
    );
  }
}

final userPairingStreamProvider = StreamProvider<UserPairingInfo>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Stream.value(UserPairingInfo(isConnected: false));
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => UserPairingInfo.fromMap(doc.data()));
});

class PairingNotifierState {
  final bool isLoading;
  final String? createdLink;
  final String? createdPairId;
  final String? errorMessage;
  final bool isSuccess;

  PairingNotifierState({
    this.isLoading = false,
    this.createdLink,
    this.createdPairId,
    this.errorMessage,
    this.isSuccess = false,
  });

  PairingNotifierState copyWith({
    bool? isLoading,
    String? createdLink,
    String? createdPairId,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return PairingNotifierState(
      isLoading: isLoading ?? this.isLoading,
      createdLink: createdLink ?? this.createdLink,
      createdPairId: createdPairId ?? this.createdPairId,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

final pairingNotifierProvider =
    StateNotifierProvider<PairingNotifier, PairingNotifierState>((ref) {
  return PairingNotifier(ref.read(apiClientProvider));
});

class PairingNotifier extends StateNotifier<PairingNotifierState> {
  final ApiClient _apiClient;

  PairingNotifier(this._apiClient) : super(PairingNotifierState());

  Future<void> createPairingLink() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _apiClient.createPairing();
      state = state.copyWith(
        isLoading: false,
        createdPairId: res['pairId'] as String?,
        createdLink: res['link'] as String?,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to create pairing link');
    }
  }

  Future<bool> acceptPairing(String inputLinkOrId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Extract pairId if input is full URL
      String pairId = inputLinkOrId.trim();
      if (pairId.contains('/pair/')) {
        pairId = pairId.split('/pair/').last.split('?').first.split('#').first;
      }

      await _apiClient.acceptPairing(pairId);
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to accept pairing link');
      return false;
    }
  }

  Future<void> unpair() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _apiClient.unpair();
      state = PairingNotifierState();
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to unpair');
    }
  }

  void resetError() {
    state = state.copyWith(errorMessage: null);
  }
}
