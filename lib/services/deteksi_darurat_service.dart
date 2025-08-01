// lib/services/emergency_detection_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class EmergencyDetectionService {
  late Interpreter _interpreter;
  late Map<String, int> _vocabulary;
  late List<double> _idf;
  bool _isInitialized = false;

  final List<String> _safePhrases = [
    "tolong ambilkan",
    "tolong bawakan",
    "tolong bukakan",
    "tolong bantu ambilkan",
    "tolong ambilkan saya makan",
    "tolong buka pintu",
  ];

  // Method untuk inisialisasi model dan assets
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Load TFLite Model
    _interpreter = await Interpreter.fromAsset(
      'assets/ml/emergency_model.tflite',
    );

    // 2. Load Vocabulary JSON
    final vocabString = await rootBundle.loadString(
      'assets/ml/vocabulary.json',
    );
    _vocabulary = Map<String, int>.from(json.decode(vocabString));

    // 3. Load IDF JSON
    final idfString = await rootBundle.loadString('assets/ml/idf.json');
    _idf = List<double>.from(json.decode(idfString));

    _isInitialized = true;
    print("✅ EmergencyDetectionService berhasil diinisialisasi.");
  }

  /// Memproses teks input menjadi vektor fitur menggunakan TF-IDF
  List<double> _vectorizeText(String text) {
    // Ukuran vektor harus sama dengan ukuran vocabulary
    final vector = List<double>.filled(_vocabulary.length, 0.0);

    // Preprocessing sederhana: lowercase dan split
    final tokens = text.toLowerCase().split(RegExp(r'\s+'));

    if (tokens.isEmpty) {
      return vector;
    }

    // Hitung Term Frequency (TF) untuk teks ini
    final tf = <int, int>{};
    for (final token in tokens) {
      if (_vocabulary.containsKey(token)) {
        final index = _vocabulary[token]!;
        tf[index] = (tf[index] ?? 0) + 1;
      }
    }

    // Hitung TF-IDF dan masukkan ke dalam vektor
    tf.forEach((index, freq) {
      final tfValue = freq / tokens.length;
      final idfValue = _idf[index];
      vector[index] = tfValue * idfValue;
    });

    return vector;
  }

  /// Lakukan prediksi pada teks yang sudah ditranskripsi
  Future<double> predict(String text) async {
    if (!_isInitialized) {
      throw Exception(
        "Service belum diinisialisasi. Panggil initialize() dulu.",
      );
    }

    // --- Filter Frasa Aman ---
    final lowerText = text.toLowerCase();
    final List<String> _safePhrases = [
      "tolong ambilkan",
      "tolong bawakan",
      "tolong bukakan",
      "tolong bantu ambilkan",
      "tolong ambilkan saya makan",
      "tolong buka pintu",
    ];

    for (final phrase in _safePhrases) {
      if (lowerText.contains(phrase)) {
        print(
          "⚠️ Frasa aman terdeteksi: \"$phrase\" → dianggap bukan darurat.",
        );
        return 0.0; // Nilai prediksi paksa rendah
      }
    }

    // 1. Ubah teks menjadi vektor fitur (TF-IDF)
    final inputVector = _vectorizeText(text);

    // 2. Siapkan input dan output untuk model TFLite
    final input = [inputVector];
    final output = List.filled(1 * 1, 0.0).reshape([1, 1]);

    // 3. Jalankan interpreter
    _interpreter.run(input, output);

    // 4. Kembalikan hasil prediksi (nilai antara 0 dan 1)
    return output[0][0] as double;
  }

  void dispose() {
    _interpreter.close();
  }
}
