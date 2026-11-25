/// Normalisation shared by search and name matching.
///
/// * lower-cases Latin text,
/// * removes zero-width joiners/non-joiners,
/// * decomposes precomposed Bangla nukta letters (ড়, ঢ়, য়) so that either
///   encoding typed by a user matches the dataset,
/// * turns `_ - . ,` into spaces and collapses whitespace.
String normalizeText(String input) {
  final b = StringBuffer();
  for (final r in input.runes) {
    switch (r) {
      case 0x200C:
      case 0x200D:
        continue;
      case 0x09DC:
        b.writeCharCode(0x09A1);
        b.writeCharCode(0x09BC);
      case 0x09DD:
        b.writeCharCode(0x09A2);
        b.writeCharCode(0x09BC);
      case 0x09DF:
        b.writeCharCode(0x09AF);
        b.writeCharCode(0x09BC);
      case 0x5F: // _
      case 0x2D: // -
      case 0x2E: // .
      case 0x2C: // ,
        b.write(' ');
      default:
        b.writeCharCode(r);
    }
  }
  return b.toString().toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Turns a dataset station key such as `gouripur_myn` into `Gouripur Myn`.
String titleFromKey(String key) => key
    .split('_')
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1))
    .join(' ');

/// Levenshtein distance with an early exit once it exceeds [max].
int boundedLevenshtein(String a, String b, int max) {
  if ((a.length - b.length).abs() > max) return max + 1;
  var prev = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final cur = List<int>.filled(b.length + 1, 0)..[0] = i;
    var rowMin = cur[0];
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      cur[j] = [prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost]
          .reduce((x, y) => x < y ? x : y);
      if (cur[j] < rowMin) rowMin = cur[j];
    }
    if (rowMin > max) return max + 1;
    prev = cur;
  }
  return prev.last;
}
