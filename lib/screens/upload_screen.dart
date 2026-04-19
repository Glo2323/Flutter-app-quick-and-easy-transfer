import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import '../services/upload_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool uploading = false;
  String? selectedFileName;

  Future<void> pickAndUploadFile() async {
    try {
      // Pick file
      final XFile? file = await openFile();

      if (file == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No file selected")));
        return;
      }

      setState(() {
        selectedFileName = file.name;
        uploading = true;
      });

      // Read bytes
      final bytes = await file.readAsBytes();

      // Upload to backend
      final success = await uploadFile(file.name, bytes);

      setState(() => uploading = false);

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Uploaded: ${file.name}")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed for ${file.name}")),
        );
      }
    } catch (e) {
      setState(() => uploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload File")),
      body: Center(
        child: uploading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text("Uploading $selectedFileName..."),
                ],
              )
            : ElevatedButton(
                onPressed: pickAndUploadFile,
                child: const Text("Select File to Upload"),
              ),
      ),
    );
  }
}
