import '../../domain/entities/train.dart';
import '../../domain/repositories/train_repository.dart';

/// Stand-in used until the owner supplies a real live-tracking backend.
/// Never fabricates data: it reports [ServiceState.notConfigured].
class UnconfiguredTrainRepository implements TrainRepository {
  const UnconfiguredTrainRepository();

  @override
  TrainDataSourceKind get sourceKind => TrainDataSourceKind.notConfigured;

  @override
  Stream<TrainSnapshot> watchTrainPositions() => const Stream.empty();

  @override
  Future<TrainDetails?> getTrainDetails(String trainId) async => null;

  @override
  Future<ServiceStatus> getServiceStatus() async => const ServiceStatus(
        source: TrainDataSourceKind.notConfigured,
        state: ServiceState.notConfigured,
        message: 'No live tracking backend is configured.',
      );

  @override
  void dispose() {}
}
