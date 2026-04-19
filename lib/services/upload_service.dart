import 'dart:typed_data';
import 'package:http/http.dart' as http;

// Your Render backend URL
const String baseUrl = "https://file-transfer-server-3.onrender.com";

// ------------------------------------------------------------
// UPLOAD FILE (encrypts on backend)
// ------------------------------------------------------------
Future<bool> uploadFile(String filename, Uint8List bytes) async {
  final url = Uri.parse("$baseUrl/upload");

  final request = http.MultipartRequest(
    "POST",
    url,
  )..files.add(http.MultipartFile.fromBytes("file", bytes, filename: filename));

  final response = await request.send();

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}
