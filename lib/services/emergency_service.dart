import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class EmergencyService {
  late Interpreter _interpreter;
  late Map<String, double> _idf;
  late List<String> _vocabulary;

  // Constructor dibuat private
  EmergencyService._();

  // Metode factory untuk membuat instance secara async
  static Future<EmergencyService> create() async {
    final service = EmergencyService._();
    await service._loadModel();
    await service._loadVectorizer();
    return service;
  }

  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/ml/emergency_model.tflite',
    );
  }

  Future<void> _loadVectorizer() async {
    final vocabString = await rootBundle.loadString(
      'assets/ml/tfidf_vocab.json',
    );
    final idfString = await rootBundle.loadString('assets/ml/tfidf_idf.json');

    // --- Langkah 1: Proses tfidf_vocab.json sebagai MAP ---
    // Decode vocab sebagai Map<String, dynamic>
    final Map<String, dynamic> vocabMap = jsonDecode(vocabString);

    // Buat list kosong dengan ukuran yang tepat untuk menampung vocabulary
    final vocabList = List<String>.filled(vocabMap.length, '');

    // Isi list vocab berdasarkan urutan indeks dari map
    vocabMap.forEach((word, index) {
      if (index is int && index < vocabList.length) {
        vocabList[index] = word;
      }
    });
    _vocabulary =
        vocabList; // _vocabulary sekarang adalah List<String> yang terurut

    // --- Langkah 2: Proses tfidf_idf.json sebagai LIST ---
    // Decode IDF sebagai List<dynamic>
    final List<dynamic> idfJson = jsonDecode(idfString);
    // Konversi ke List<double>
    final idfList = idfJson.map((e) => (e as num).toDouble()).toList();

    // --- Langkah 3: Gabungkan keduanya menjadi _idf ---
    // Lakukan pengecekan untuk memastikan panjang keduanya sama
    if (_vocabulary.length != idfList.length) {
      throw StateError(
        'Jumlah kata di vocabulary tidak cocok dengan jumlah nilai IDF!',
      );
    }

    // Buat Map _idf dari dua list yang sudah terurut
    _idf = Map.fromIterables(_vocabulary, idfList);
  }

  // Fungsi _transform tidak perlu diubah
  Float32List _transform(String text) {
    // 1. Bersihkan teks dan pecah menjadi kata-kata tunggal (1-gram)
    final cleanText = text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    final singleWords = cleanText
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();

    // 2. Buat daftar gabungan yang akan berisi 1-gram dan 2-gram
    final List<String> allTerms = List.from(singleWords);

    // 3. Tambahkan pasangan kata (2-gram) ke dalam daftar
    for (int i = 0; i < singleWords.length - 1; i++) {
      allTerms.add('${singleWords[i]} ${singleWords[i + 1]}');
    }

    // 4. Hitung vektor TF-IDF berdasarkan `allTerms` yang sudah lengkap
    final vector = List.filled(_vocabulary.length, 0.0);
    for (int i = 0; i < _vocabulary.length; i++) {
      // _vocabulary[i] bisa berupa "tolong" atau "tolong ambilkan"
      final vocabTerm = _vocabulary[i];

      // Hitung frekuensi kemunculan term dari input pengguna
      final tf = allTerms.where((term) => term == vocabTerm).length.toDouble();

      // Jika term ditemukan, hitung nilai TF-IDF nya
      if (tf > 0 && _idf.containsKey(vocabTerm)) {
        vector[i] = tf * _idf[vocabTerm]!;
      }
    }
    return Float32List.fromList(vector);
  }

  Future<Map<String, dynamic>> predict(String kalimat) async {
    // 1. Siapkan input. Model biasanya mengharapkan batch, jadi kita bungkus
    //    hasil _transform ke dalam List. Bentuknya menjadi [1, panjang_vektor].
    final input = [_transform(kalimat)];

    // 2. Siapkan output. Berdasarkan kode lama, outputnya adalah satu nilai float
    //    dengan bentuk [1, 1]. Kita bisa buat List dengan struktur yang sama.
    final output = List.generate(1, (_) => List.filled(1, 0.0));

    // 3. Jalankan inferensi
    _interpreter.run(input, output);

    // 4. Ambil hasilnya dari List output
    final result = output[0][0];

    return {
      "model": "TFLite",
      "kalimat": kalimat,
      "prediksi_nilai": result,
      "kategori": result >= 0.5 ? "darurat" : "bukan darurat",
    };
  }
}
