import 'package:dio/dio.dart';

class ApiService {
  final dio = Dio();
  final baseUrl = "https://file-transfer-server-2.onrender.com/";

  Future uploadFile(
    String fileName,
    List<int> encryptedBytes, {
    required Function(int, int) onProgress,
  }) async {
    FormData formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(
        encryptedBytes,
        filename: fileName,
      ),
    });

    await dio.post(
      "$baseUrl/upload",
      data: formData,
      onSendProgress: onProgress,
    );
  }

  Future<List<int>> downloadFile(String filename) async {
    final response = await dio.get(
      "$baseUrl/download/$filename",
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data;
  }
}

Future<List<String>> getFileList() async {
  final response = await dio.get("$baseUrl/files");
  return List<String>.from(response.data);
}