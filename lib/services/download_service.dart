import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/file_info.dart';

// Your Render backend URL
const String baseUrl = "https://file-transfer-server-3.onrender.com";

// ------------------------------------------------------------
// FETCH FILE LIST (metadata)
// ------------------------------------------------------------
Future<List<FileInfo>> fetchFileList() async {
  final response = await http.get(Uri.parse("$baseUrl/files"));

  if (response.statusCode != 200) {
    throw Exception("Failed to load file list");
  }

  final List data = jsonDecode(response.body);
  return data.map((e) => FileInfo.fromJson(e)).toList();
}

// ------------------------------------------------------------
// DOWNLOAD FILE (decrypts on backend)
// ------------------------------------------------------------
Future<Uint8List> downloadFile(String filename) async {
  final url = Uri.parse("$baseUrl/download/$filename");
  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception("Download failed");
  }

  return response.bodyBytes;
}
