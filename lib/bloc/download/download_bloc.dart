import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DownloadBloc {
  final String url = "https://dl.dropboxusercontent.com/scl/fi/w2p0pe346p1o98rrp9bj1/cache.zip?rlkey=scsvr2e3m75ma8jim4wlunkzs";

  Future<void> downloadData() async {
    try {
      final dir = await getExternalStorageDirectory();
      final file = File("${dir!.path}/cache.zip");

      final response = await http.get(Uri.parse(url));
      await file.writeAsBytes(response.bodyBytes);

      print("Download concluído");
    } catch (e) {
      print("Erro: $e");
    }
  }

  void dispose() {}
}
