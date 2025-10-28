import 'dart:async';
import 'package:flutter/widgets.dart';

typedef LifecycleEventCallback = FutureOr<void> Function();

class _Handler {
  final String name;
  final LifecycleEventCallback onPause;
  final LifecycleEventCallback onResume;
  final LifecycleEventCallback? onDetach;

  _Handler({
    required this.name,
    required this.onPause,
    required this.onResume,
    this.onDetach,
  });
}

// Using Mixin to observe app lifecycle changes
class LifecycleManager with WidgetsBindingObserver {
  // Singleton
  static final LifecycleManager _instance = LifecycleManager._internal();
  factory LifecycleManager() => _instance;
  LifecycleManager._internal();

  final List<_Handler> _handlers = [];

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void registerHandler({
    required String name,
    required LifecycleEventCallback onPause,
    required LifecycleEventCallback onResume,
    LifecycleEventCallback? onDetach,
  }) {
    _handlers.removeWhere((h) => h.name == name);
    _handlers.add(
      _Handler(
        name: name,
        onPause: onPause,
        onResume: onResume,
        onDetach: onDetach,
      ),
    );
  }

  void unregisterHandler(String name) {
    _handlers.removeWhere((h) => h.name == name);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('LifecycleManager: state -> $state');

    switch (state) {
      case AppLifecycleState.paused:
        _runPause();
        break;
      case AppLifecycleState.resumed:
        _runResume();
        break;
      case AppLifecycleState.inactive:
        // transient (iOS) - we ignore or treat lightly
        break;
      case AppLifecycleState.detached:
        _runDetach();
        break;
      case AppLifecycleState.hidden:
        // some platforms (web/embedded) may use this.
        // Treat it like paused (or ignore) — do NOT throw.
        _runPause();
        break;
    }
  }

  // Helpers that schedule handlers safely (support sync & async handlers)
  void _runPause() {
    for (final h in List<_Handler>.from(_handlers)) {
      // schedule and catch errors so they don't bubble to platform channel
      Future.microtask(() => Future.sync(() => h.onPause())).catchError(
        (e, st) => debugPrint(
          'LifecycleManager: pause handler ${h.name} failed: $e\n$st',
        ),
      );
    }
  }

  void _runResume() {
    for (final h in List<_Handler>.from(_handlers)) {
      Future.microtask(() => Future.sync(() => h.onResume())).catchError(
        (e, st) => debugPrint(
          'LifecycleManager: resume handler ${h.name} failed: $e\n$st',
        ),
      );
    }
  }

  void _runDetach() {
    for (final h in List<_Handler>.from(_handlers)) {
      if (h.onDetach == null) continue;
      Future.microtask(() => Future.sync(() => h.onDetach!())).catchError(
        (e, st) => debugPrint(
          'LifecycleManager: detach handler ${h.name} failed: $e\n$st',
        ),
      );
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
