import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:rtc_project/model/user_info.dart';

class CryptoManager {
  final encrypt.Key key;

  CryptoManager(String keyString)
      : key = encrypt.Key.fromUtf8(keyString);

  String encryptData(String plainText) {
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return iv.base64 + ':' + encrypted.base64;
  }

  String decryptData(String encryptedTextWithIv) {
    final parts = encryptedTextWithIv.split(':');
    final iv = encrypt.IV.fromBase64(parts[0]);
    final encryptedText = parts[1];
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final decrypted = encrypter.decrypt(encrypt.Encrypted.fromBase64(encryptedText), iv: iv);
    return decrypted;
  }

  String encryptUserInfo(String key) {
    String jsonUserInfo = jsonEncode(key);
    return encryptData(jsonUserInfo);
  }

  String decryptUserInfo(String encryptedUserInfo) {
    return decryptData(encryptedUserInfo);
    // return UserInfoA.fromJson(jsonDecode(decryptedJson));
  }
}
