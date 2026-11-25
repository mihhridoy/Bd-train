import 'package:flutter/services.dart';

/// Wraps the `bd_train_tracker/settings` MethodChannel implemented in
/// `MainActivity.kt` (opens Android's wireless/network settings).
abstract interface class PlatformSettingsService {
  Future<bool> openInternetSettings();
}

class ChannelPlatformSettingsService implements PlatformSettingsService {
  const ChannelPlatformSettingsService();
  static const _channel = MethodChannel('bd_train_tracker/settings');

  @override
  Future<bool> openInternetSettings() async {
    try {
      final ok = await _channel.invokeMethod<bool>('openInternet');
      return ok ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
