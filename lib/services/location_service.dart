import 'package:geolocator/geolocator.dart';

import '../domain/entities/geo.dart';

sealed class LocationOutcome {
  const LocationOutcome();
}

class LocationGranted extends LocationOutcome {
  const LocationGranted(this.point);
  final GeoPoint point;
}

class LocationDenied extends LocationOutcome {
  const LocationDenied();
}

class LocationDeniedForever extends LocationOutcome {
  const LocationDeniedForever();
}

class LocationServiceOff extends LocationOutcome {
  const LocationServiceOff();
}

class LocationFailed extends LocationOutcome {
  const LocationFailed();
}

/// One-shot, user-initiated location. Never subscribes to updates, never runs
/// in the background and never stores the result.
abstract interface class LocationService {
  Future<LocationOutcome> getCurrentLocation();
  Future<void> openAppSettings();
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<LocationOutcome> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationServiceOff();
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied) return const LocationDenied();
      if (perm == LocationPermission.deniedForever) {
        return const LocationDeniedForever();
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return LocationGranted(GeoPoint(pos.latitude, pos.longitude));
    } catch (_) {
      return const LocationFailed();
    }
  }

  @override
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
