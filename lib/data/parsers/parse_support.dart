/// Thrown when a dataset file is structurally unusable (not just one bad row).
class DatasetFormatException implements Exception {
  DatasetFormatException(this.file, this.message);
  final String file;
  final String message;
  @override
  String toString() => 'DatasetFormatException($file): $message';
}

/// Collects non-fatal record problems, capping stored messages.
class IssueLog {
  IssueLog(this.file, {this.maxStored = 40});
  final String file;
  final int maxStored;
  final List<String> messages = [];
  int total = 0;

  void add(String message) {
    total++;
    if (messages.length < maxStored) messages.add('$file: $message');
  }

  List<String> toList() => [
        ...messages,
        if (total > messages.length) '$file: … ${total - messages.length} more',
      ];
}

double? asDouble(Object? v) => v is num && v.isFinite ? v.toDouble() : null;
