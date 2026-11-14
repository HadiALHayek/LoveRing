import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return DeepLinkService();
});

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  /// Parses pairId from incoming Uri
  String? parsePairId(Uri uri) {
    // Check custom scheme loveRing://pair/{pairId}
    if (uri.scheme == 'loveRing' || uri.scheme == 'lovering') {
      if (uri.host == 'pair' && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
      if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'pair') {
        return uri.pathSegments[1];
      }
    }

    // Check App Links https://YOUR_PROJECT.vercel.app/pair/{pairId}
    if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'pair') {
      return uri.pathSegments[1];
    }

    return null;
  }

  /// Initializes listening to initial link (cold start) and link stream (warm start)
  void initDeepLinks(Function(String pairId) onPairIdReceived) async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        final pairId = parsePairId(initialUri);
        if (pairId != null && pairId.isNotEmpty) {
          onPairIdReceived(pairId);
        }
      }
    } catch (_) {}

    _sub = _appLinks.uriLinkStream.listen((uri) {
      final pairId = parsePairId(uri);
      if (pairId != null && pairId.isNotEmpty) {
        onPairIdReceived(pairId);
      }
    });
  }

  void dispose() {
    _sub?.cancel();
  }
}
