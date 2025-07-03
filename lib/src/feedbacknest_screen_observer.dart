import 'package:flutter/material.dart';

class FeedbacknestScreenObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final screenName = _getRouteName(route);
    debugPrint('🟢 Route Pushed: $screenName');

    if (previousRoute != null) {
      debugPrint('Previous Route: ${_getRouteName(previousRoute)}');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final poppedScreen = _getRouteName(route);
    debugPrint('🔴 Route Popped: $poppedScreen');

    if (previousRoute != null) {
      debugPrint('New current Route: ${_getRouteName(previousRoute)}');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    debugPrint(
      '🔁 Route Replaced: ${_getRouteName(oldRoute)} → ${_getRouteName(newRoute)}',
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('🗑️ Route Removed: ${_getRouteName(route)}');
  }

  String _getRouteName(Route<dynamic>? route) {
    if (route == null) return 'null';

    // Prefer the explicitly set name
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) return name;

    throw Exception('''
  Add RouteSettings to your routes to get the name.
  For example, when using MaterialPageRoute:
  ```dart
  MaterialPageRoute(
    builder: (context) => TestScreen(),
    settings: RouteSettings(name: 'TestScreen'),
  ),

  add settings: RouteSettings(name: 'screen name') to your routes.

  ''');
  }
}
