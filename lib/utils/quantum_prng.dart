import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class QuantumPRNGService {
  static final _storage = FlutterSecureStorage();
  static final _hmac = Hmac.sha256();
  static const _quantumApi =
      'https://qrng.anu.edu.au/API/jsonI.php?length=1&type=hex16&size=32';

  // Generate atau ambil seed dari secure storage
  static Future<Uint8List> _getOrCreateSeed() async {
    final existingSeed = await _storage.read(key: 'quantum_seed');
    if (existingSeed != null) {
      return base64.decode(existingSeed);
    }

    final newSeed = await _fetchQuantumSeed();
    await _storage.write(
      key: 'quantum_seed',
      value: base64.encode(newSeed),
    );
    return newSeed;
  }

  // Ambil seed dari sumber kuantum
  static Future<Uint8List> _fetchQuantumSeed() async {
    try {
      final response = await http.get(Uri.parse(_quantumApi));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Uint8List.fromList(hex.decode(jsonData['data'][0] as String));
      }
      final fallbackSeed = await _generateFallbackSeed();
      return Uint8List.fromList(fallbackSeed);
    } catch (_) {
      final fallbackSeed = await _generateFallbackSeed();
      return Uint8List.fromList(fallbackSeed);
    }
  }

// Fallback ke CSPRNG
  static Future<List<int>> _generateFallbackSeed() async {
    // Step 1: Initialize HKDF with SHA-256
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    // Step 2: Generate a random 32-byte secret key
    final random = Random.secure();
    final randomBytes = List<int>.generate(32, (_) => random.nextInt(256));
    final secretKey = SecretKey(randomBytes);

    // Step 3: Derive a new key using HKDF
    final derivedKey = await hkdf.deriveKey(
      secretKey: secretKey,
      nonce: Uint8List(0),
    );

    // Step 4: Extract bytes from the derived key
    final seedBytes = await derivedKey.extractBytes();

    return seedBytes;
  }

  // Generate key untuk obfuscation
  static Future<List<int>> generateObfuscationKey() async {
    final seed = await _getOrCreateSeed();
    final mac = await _hmac.calculateMac(
      Uint8List.fromList(utf8.encode('OBFUSCATION_KEY')),
      secretKey: SecretKey(seed),
    );
    return mac.bytes;
  }

  // Obfuscasi data
  static Uint8List obfuscateData(Uint8List data, Uint8List key) {
    return Uint8List.fromList(
      List.generate(data.length, (i) => data[i] ^ key[i % key.length]),
    );
  }

  // Hapus seed saat logout
  static Future<void> clearQuantumSeed() async {
    await _storage.delete(key: 'quantum_seed');
  }
}
