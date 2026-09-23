import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Crash-safe haptics for premium tap feedback.
/// - Web: no-op (no vibration API wired).
/// - Tests: platform channel is unmocked — failures are swallowed.
/// - Devices: subtle selection tick. Never await — fire and forget.
void softTick() {
  if (kIsWeb) return;
  HapticFeedback.selectionClick().catchError((Object _) {});
}

/// Slightly stronger tick for primary confirmations (approve, enroll).
void confirmTick() {
  if (kIsWeb) return;
  HapticFeedback.mediumImpact().catchError((Object _) {});
}
