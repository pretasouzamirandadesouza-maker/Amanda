import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DownloadBloc {

  // 🔥 COLOCA SEU LINK AQUI
  final String url = "https://www.dropbox.com/scl/fi/w2p0pe346p1o98rrp9bj1/cache.zip?rlkey=scsvr2e3m75ma8jim4wlunkzs&st=fq8dheik&dl=1";

  Future<void> downloadData() async {
    try {
      final dir = await getExternalStorageDirectory();
      final file = File("${dir!.path}/cache.zip");

      print("Baixando data...");

      final response = await http.get(Uri.parse(url));

      await file.writeAsBytes(response.bodyBytes);

      print("Download concluído: ${file.path}");

    } catch (e) {
      print("Erro no download: $e");
    }
  }
}