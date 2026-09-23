import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:just_audio_web/just_audio_web.dart';

/// Web variant: the tool omits just_audio_web from the generated web
/// registrant, so register it explicitly (idempotent if the tool
/// also registers it later).
void registerAudioWeb() {
  JustAudioPlugin.registerWith(webPluginRegistrar);
}
