import 'package:share_plus/share_plus.dart';

abstract interface class ShareService {
  Future<void> shareText(String text);
}

class SharePlusShareService implements ShareService {
  const SharePlusShareService();
  @override
  Future<void> shareText(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }
}
