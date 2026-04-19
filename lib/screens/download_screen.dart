import 'package:flutter/material.dart';
import '../services/download_service.dart';
import '../models/file_info.dart';
import 'dart:io';
import 'package:file_selector/file_selector.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  // ------------------------------------------------------------
  // ICONS
  IconData getFileIcon(String filename) {
    final ext = filename.toLowerCase();

    if (ext.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (ext.endsWith('.png') || ext.endsWith('.jpg') || ext.endsWith('.jpeg')) {
      return Icons.image;
    }
    if (ext.endsWith('.mp4') || ext.endsWith('.mov') || ext.endsWith('.avi')) {
      return Icons.movie;
    }
    if (ext.endsWith('.mp3') || ext.endsWith('.wav')) {
      return Icons.music_note;
    }
    if (ext.endsWith('.zip') || ext.endsWith('.rar') || ext.endsWith('.7z')) {
      return Icons.archive;
    }
    if (ext.endsWith('.txt') || ext.endsWith('.doc') || ext.endsWith('.docx')) {
      return Icons.description;
    }

    return Icons.insert_drive_file;
  }

  // ------------------------------------------------------------
  // FORMATTERS
  String formatSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    if (bytes < 1024 * 1024 * 1024) {
      return "${(bytes / 1024 / 1024).toStringAsFixed(1)} MB";
    }
    return "${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB";
  }

  String formatDate(DateTime dt) {
    return "${dt.month}/${dt.day}/${dt.year} "
        "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  // ------------------------------------------------------------
  // STATE
  List<FileInfo> files = [];
  bool loading = true;

  String searchQuery = "";
  String sortMode = "name_asc";
  String filterType = "all";

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  // ------------------------------------------------------------
  // LOAD FILE LIST
  Future<void> loadFiles() async {
    try {
      final list = await fetchFileList();
      setState(() {
        files = list;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading files: $e")));
    }
  }

  // ------------------------------------------------------------
  // FILTER + SORT
  List<FileInfo> get filteredFiles {
    List<FileInfo> list = files.where((f) {
      return f.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    // File type filter
    if (filterType != "all") {
      list = list.where((f) {
        final name = f.name.toLowerCase();
        if (filterType == "images") {
          return name.endsWith(".png") ||
              name.endsWith(".jpg") ||
              name.endsWith(".jpeg");
        }
        if (filterType == "videos") {
          return name.endsWith(".mp4") ||
              name.endsWith(".mov") ||
              name.endsWith(".avi");
        }
        if (filterType == "docs") {
          return name.endsWith(".pdf") ||
              name.endsWith(".txt") ||
              name.endsWith(".doc") ||
              name.endsWith(".docx");
        }
        return true;
      }).toList();
    }

    // Sorting
    switch (sortMode) {
      case "name_asc":
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case "name_desc":
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case "size_asc":
        list.sort((a, b) => a.size.compareTo(b.size));
        break;
      case "size_desc":
        list.sort((a, b) => b.size.compareTo(a.size));
        break;
      case "newest":
        list.sort((a, b) => b.modified.compareTo(a.modified));
        break;
      case "oldest":
        list.sort((a, b) => a.modified.compareTo(b.modified));
        break;
    }

    return list;
  }

  // ------------------------------------------------------------
  // AUTO-DOWNLOAD
  Future<void> autoDownload(String filename) async {
    try {
      final bytes = await downloadFile(filename);

      final home = Platform.environment['USERPROFILE'];
      final downloadsPath = "$home/Downloads/$filename";

      final file = File(downloadsPath);
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saved to Downloads: $downloadsPath")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Download failed: $e")));
    }
  }

  // ------------------------------------------------------------
  // SAVE AS
  Future<void> saveAs(String filename) async {
    try {
      final bytes = await downloadFile(filename);

      final location = await getSaveLocation(suggestedName: filename);

      if (location == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Save canceled")));
        return;
      }

      final file = XFile.fromData(
        bytes,
        name: filename,
        mimeType: "application/octet-stream",
      );

      await file.saveTo(location.path);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Saved to: ${location.path}")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Save As failed: $e")));
    }
  }

  // ------------------------------------------------------------
  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Download Files")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // SEARCH + SORT + FILTER BAR
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: "Search files...",
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setState(() => searchQuery = value);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Sort dropdown
                      DropdownButton<String>(
                        value: sortMode,
                        items: const [
                          DropdownMenuItem(
                            value: "name_asc",
                            child: Text("A → Z"),
                          ),
                          DropdownMenuItem(
                            value: "name_desc",
                            child: Text("Z → A"),
                          ),
                          DropdownMenuItem(
                            value: "size_asc",
                            child: Text("Smallest"),
                          ),
                          DropdownMenuItem(
                            value: "size_desc",
                            child: Text("Largest"),
                          ),
                          DropdownMenuItem(
                            value: "newest",
                            child: Text("Newest"),
                          ),
                          DropdownMenuItem(
                            value: "oldest",
                            child: Text("Oldest"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => sortMode = value!);
                        },
                      ),
                      const SizedBox(width: 10),

                      // Filter dropdown
                      DropdownButton<String>(
                        value: filterType,
                        items: const [
                          DropdownMenuItem(value: "all", child: Text("All")),
                          DropdownMenuItem(
                            value: "images",
                            child: Text("Images"),
                          ),
                          DropdownMenuItem(
                            value: "videos",
                            child: Text("Videos"),
                          ),
                          DropdownMenuItem(value: "docs", child: Text("Docs")),
                        ],
                        onChanged: (value) {
                          setState(() => filterType = value!);
                        },
                      ),
                    ],
                  ),
                ),

                // FILE LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredFiles.length,
                    itemBuilder: (context, index) {
                      final file = filteredFiles[index];

                      return ListTile(
                        leading: Icon(
                          getFileIcon(file.name),
                          size: 32,
                          color: Colors.deepPurple,
                        ),
                        title: Text(file.name),
                        subtitle: Text(
                          "${formatSize(file.size)} • ${formatDate(file.modified)}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () => autoDownload(file.name),
                              child: const Text("Download"),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton(
                              onPressed: () => saveAs(file.name),
                              child: const Text("Save As…"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
