import '../../domain/entities/geo.dart';

const _bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

/// Locale-aware formatting helpers (Bangla digits when language is `bn`).
class Fmt {
  const Fmt(this.lang);
  final String lang;
  bool get isBn => lang == 'bn';

  String digits(Object value) {
    final s = value.toString();
    if (!isBn) return s;
    return s.replaceAllMapped(RegExp(r'\d'), (m) => _bnDigits[int.parse(m[0]!)]);
  }

  String distance(double meters) {
    if (meters < 1000) return '${digits(meters.round())} ${isBn ? 'মিটার' : 'm'}';
    final km = meters / 1000;
    final text = km >= 100 ? km.toStringAsFixed(0) : km.toStringAsFixed(1);
    return '${digits(text)} ${isBn ? 'কিমি' : 'km'}';
  }

  String coordinate(GeoPoint p) =>
      '${digits(p.lat.toStringAsFixed(5))}, ${digits(p.lng.toStringAsFixed(5))}';

  String clock(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return digits('${two(t.hour)}:${two(t.minute)}:${two(t.second)}');
  }

  /// `18:30` → `১৮:৩০` in Bangla.
  String hhmm(String value) => digits(value);

  static const _days = {
    'saturday': 'শনিবার',
    'sunday': 'রবিবার',
    'monday': 'সোমবার',
    'tuesday': 'মঙ্গলবার',
    'wednesday': 'বুধবার',
    'thursday': 'বৃহস্পতিবার',
    'friday': 'শুক্রবার',
    'sat': 'শনি',
    'sun': 'রবি',
    'mon': 'সোম',
    'tue': 'মঙ্গল',
    'wed': 'বুধ',
    'thu': 'বৃহস্পতি',
    'fri': 'শুক্র',
  };

  /// Translates `Saturday` or `Sat/Sun/Tue/Thu` for Bangla.
  String weekdays(String value) {
    if (!isBn) return value;
    return value
        .split('/')
        .map((d) => _days[d.trim().toLowerCase()] ?? d)
        .join('/');
  }
}
