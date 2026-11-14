// ignore_for_file: use_super_parameters
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../core/config.dart';

// Typed Exceptions
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException([String message = 'Network connection error. Please check your internet connection.'])
      : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Unauthorized access. Please re-authenticate.'])
      : super(message, 401);
}

class NotPairedException extends ApiException {
  NotPairedException([String message = 'You are not paired with any partner.'])
      : super(message, 403);
}

class NotFoundException extends ApiException {
  NotFoundException([String message = 'Pairing link or user not found.'])
      : super(message, 404);
}

class ExpiredException extends ApiException {
  ExpiredException([String message = 'This pairing link has expired.'])
      : super(message, 400);
}

class PairingConflictException extends ApiException {
  PairingConflictException([String message = 'Pairing link has already been used or is invalid.'])
      : super(message, 409);
}

class RateLimitedException extends ApiException {
  RateLimitedException([String message = 'Please wait at least 3 seconds between pings.'])
      : super(message, 429);
}

class ServerException extends ApiException {
  ServerException([String message = 'Server error occurred. Please try again later.', int? statusCode])
      : super(message, statusCode);
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<String> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw UnauthorizedException('User is not signed in.');
    }
    final token = await user.getIdToken(true);
    if (token == null || token.isEmpty) {
      throw UnauthorizedException('Failed to retrieve Firebase ID token.');
    }
    return token;
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Creates a new pairing link and returns `{ pairId, link }`
  Future<Map<String, dynamic>> createPairing() async {
    return _post('/api/createPairing');
  }

  /// Accepts a pairing link given a [pairId]
  Future<Map<String, dynamic>> acceptPairing(String pairId) async {
    return _post('/api/acceptPairing', body: {'pairId': pairId});
  }

  /// Unpairs the current user from their partner
  Future<Map<String, dynamic>> unpair() async {
    return _post('/api/unpair');
  }

  /// Sends a ping to partner
  Future<Map<String, dynamic>> sendPing({String fromName = 'Your Love'}) async {
    return _post('/api/sendPing', body: {'fromName': fromName});
  }

  Future<Map<String, dynamic>> _post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$apiBaseUrl$endpoint');
    try {
      final headers = await _headers();
      final response = await _client.post(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> body = {};
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}
    }

    final errorMessage = body['error'] ?? body['message'] ?? 'An error occurred';

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 400:
        if (errorMessage.toString().toLowerCase().contains('expired')) {
          throw ExpiredException(errorMessage.toString());
        }
        throw ServerException(errorMessage.toString(), 400);
      case 401:
        throw UnauthorizedException(errorMessage.toString());
      case 403:
        throw NotPairedException(errorMessage.toString());
      case 404:
        throw NotFoundException(errorMessage.toString());
      case 409:
        throw PairingConflictException(errorMessage.toString());
      case 429:
        throw RateLimitedException(errorMessage.toString());
      default:
        throw ServerException(errorMessage.toString(), response.statusCode);
    }
  }
}
