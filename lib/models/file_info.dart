class FileInfo {
  final String name;
  final int size;
  final DateTime modified;

  FileInfo({required this.name, required this.size, required this.modified});

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      name: json['name'],
      size: json['size'],
      modified: DateTime.parse(json['modified']),
    );
  }
}
