/// One row of the (partial) published timetable.
///
/// Only origin/destination, their times and the weekly off-day are known. No
/// intermediate stops are available; never infer them from track geometry.
class TimetableEntry {
  const TimetableEntry({
    required this.trainNumber,
    required this.nameEn,
    required this.serviceType,
    required this.originName,
    required this.destinationName,
    required this.departureTime,
    required this.arrivalTime,
    required this.weeklyOffDay,
    required this.verificationStatus,
    required this.effectiveNote,
    this.nameBn,
    this.originKey,
    this.destinationKey,
  });

  /// String on purpose: some services use non-numeric identifiers.
  final String trainNumber;
  final String nameEn;
  final String? nameBn;
  final String serviceType;
  final String originName;
  final String destinationName;

  /// Local Bangladesh time, `HH:mm`.
  final String departureTime;
  final String arrivalTime;

  /// Null when not sourced; `No` is kept as the literal source value.
  final String? weeklyOffDay;
  final String verificationStatus;
  final String effectiveNote;

  /// Rail-geometry keys when the endpoint exists in the bundled network.
  final String? originKey;
  final String? destinationKey;

  bool get canShowOnMap => originKey != null && destinationKey != null;

  /// True when arrival is numerically earlier than departure (next-day arrival).
  /// A same-time pair is treated as next-day only when it is `00:00`.
  bool get arrivesNextDay {
    final d = _minutes(departureTime), a = _minutes(arrivalTime);
    return a <= d;
  }

  static int _minutes(String hhmm) {
    final p = hhmm.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  TimetableEntry withKeys(String? origin, String? destination) => TimetableEntry(
        trainNumber: trainNumber,
        nameEn: nameEn,
        nameBn: nameBn,
        serviceType: serviceType,
        originName: originName,
        destinationName: destinationName,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        weeklyOffDay: weeklyOffDay,
        verificationStatus: verificationStatus,
        effectiveNote: effectiveNote,
        originKey: origin,
        destinationKey: destination,
      );
}
