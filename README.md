📱 Quick & Easy Transfer (Flutter App)
A fast, modern, cross‑platform file transfer app built with Flutter.
Designed for simplicity and speed, Quick & Easy Transfer lets users upload and download files between devices using a clean UI and a secure FastAPI backend.

This is the official Flutter frontend for the File Transfer Server.

✨ Features
Cross‑platform Flutter UI (Windows, macOS, Linux, Web, Android)

Upload & download files with real‑time progress

Connects to FastAPI backend

Clean, modern purple‑themed interface

Simple navigation (Home → Upload → Download)

Secure HTTP requests

Lightweight, scalable architecture

📁 Project Structure
Code
lib/
│── main.dart
│── screens/
│     ├── home_screen.dart
│     ├── upload_screen.dart
│     └── download_screen.dart
│── services/
│     └── api_service.dart
│── widgets/
│     └── custom_button.dart
assets/
pubspec.yaml
screens/ — UI pages

services/ — API communication with FastAPI

widgets/ — Reusable UI components

main.dart — App entry point

🚀 Getting Started
1. Clone the repository
bash
git clone https://github.com/YOUR_USERNAME/quick_and_easy_transfer.git
cd quick_and_easy_transfer
2. Install dependencies
bash
flutter pub get
3. Run the app
bash
flutter run

🔌 Backend Connection
Update your API base URL inside:

Code
lib/services/api_service.dart
Example:

dart
static const String baseUrl = "https://your-fastapi-server-url.com";

📤 Uploading Files
The Upload screen allows users to:

Pick a file

Send it to the FastAPI /upload endpoint

View upload status

📥 Downloading Files
The Download screen allows users to:

Enter a filename

Request it from /download/{filename}

Save it locally

🎨 UI Theme
Quick & Easy Transfer uses:

Deep purple accents

Clean white backgrounds

Material 3 components

Simple, centered layout

Perfect for a professional, modern feel.

🌐 Supported Platforms
Windows

macOS

Linux

Android

Web (Chrome, Edge, Safari)

🛠️ Tech Stack
Flutter 3+

Dart

HTTP package

FastAPI backend

🧩 Future Enhancements
Drag‑and‑drop uploads

File previews

Multi‑file transfers

Authentication

Encrypted transfers

Device pairing

🤝 Contributing
Pull requests and feature suggestions are welcome.

⭐ Support the Project
If this app helps you, consider starring the repo — it boosts visibility and supports future development.
