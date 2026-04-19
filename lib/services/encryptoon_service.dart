import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  final key = Key.fromUtf8("12345678901234567890123456789012"); // 32 chars
  final iv = IV.fromLength(16);

  Uint8List encrypt(Uint8List data) {
    final aes = Encrypter(AES(key));
    return aes.encryptBytes(data, iv: iv).bytes;
  }

  Uint8List decrypt(Uint8List encrypted) {
    final aes = Encrypter(AES(key));
    return aes.decryptBytes(Encrypted(encrypted), iv: iv);
  }
}