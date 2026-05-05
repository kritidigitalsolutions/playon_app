import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareHelper {
  static Future<void> shareMatchWithImage({
    required String text,
    String? imageUrl,
  }) async {
    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final temp = await getTemporaryDirectory();
          final path = '${temp.path}/match_thumbnail.png';
          File(path).writeAsBytesSync(response.bodyBytes);
          
          await Share.shareXFiles(
            [XFile(path)],
            text: text,
          );
          return;
        }
      }
      // Fallback to text only if image fails or is null
      await Share.share(text);
    } catch (e) {
      // Fallback to text only on error
      await Share.share(text);
    }
  }
}
