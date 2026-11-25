import '../entities/train.dart';

/// Source of train state, kept separate from the static rail geometry.
///
/// Implementations: `MockTrainRepository` (demo, local simulation) and
/// `UnconfiguredTrainRepository` (no backend). A real Firebase/REST adapter
/// goes here once the owner supplies the API/schema — see
/// `docs/MISSING_BACKEND.md`.
abstract interface class TrainRepository {
  TrainDataSourceKind get sourceKind;

  /// Emits a new snapshot whenever positions change. May complete with an error
  /// event on transport failure; UI maps that to the offline state.
  Stream<TrainSnapshot> watchTrainPositions();

  Future<TrainDetails?> getTrainDetails(String trainId);

  Future<ServiceStatus> getServiceStatus();

  /// Release resources (timers, sockets).
  void dispose();
}
