import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/encryption_service.dart';
import '../services/api_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  double progress = 0.0;
  String status = "Pick a file to upload";

  final EncryptionService _encryptor = EncryptionService();
  final ApiService _api = ApiService();

  Future<void> pickAndUploadFile() async {
    setState(() {
      progress = 0.0;
      status = "Picking file...";
    });

    // Pick file
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      setState(() => status = "No file selected");
      return;
    }

    final fileBytes = result.files.first.bytes;
    final fileName = result.files.first.name;

    if (fileBytes == null) {
      setState(() => status = "Error reading file");
      return;
    }

    setState(() => status = "Encrypting...");

    // Encrypt file
    Uint8List encrypted = _encryptor.encrypt(fileBytes);

    setState(() => status = "Uploading...");

    // Upload with progress
    await _api.uploadFile(
      fileName,
      encrypted,
      onProgress: (sent, total) {
        setState(() {
          progress = sent / total;
        });
      },
    );

    setState(() {
      status = "Upload complete!";
      progress = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload File")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              status,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Upload button
            ElevatedButton(
              onPressed: pickAndUploadFile,
              child: Text("Pick File"),
            ),

            SizedBox(height: 30),

            // Progress bar
            LinearProgressIndicator(value: progress, minHeight: 8),
          ],
        ),
      ),
    );
  }
}
