import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class EmergencyService {
  late Interpreter _interpreter;
  late Map<String, double> _idf;
  late List<String> _vocabulary;

  EmergencyService._();

  static Future<EmergencyService> create() async {
    final service = EmergencyService._();
    await service._loadModel();
    await service._loadVectorizer();
    return service;
  }

  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('emergency_model.tflite');
  }

  Future<void> _loadVectorizer() async {
    final vocabString = await rootBundle.loadString('assets/tfidf_vocab.json');
    final idfString = await rootBundle.loadString('assets/tfidf_idf.json');

    _vocabulary = List<String>.from(jsonDecode(vocabString));
    final Map<String, dynamic> idfMap = jsonDecode(idfString);
    _idf = idfMap.map((key, value) => MapEntry(key, value.toDouble()));
  }

  Float32List _transform(String text) {
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // hilangkan tanda baca
        .split(RegExp(r'\s+'));

    final vector = List.filled(_vocabulary.length, 0.0);

    for (int i = 0; i < _vocabulary.length; i++) {
      final word = _vocabulary[i];
      final tf = words.where((w) => w == word).length.toDouble();
      if (tf > 0 && _idf.containsKey(word)) {
        vector[i] = tf * _idf[word]!;
      }
    }

    return Float32List.fromList(vector);
  }

  Future<Map<String, dynamic>> predict(String kalimat) async {
    final input = _transform(kalimat);

    // Gunakan TensorBuffer dari tflite_flutter_helper
    final inputBuffer = TensorBuffer.createFixedSize([
      1,
      input.length,
    ], TfLiteType.float32);
    inputBuffer.loadList(input, shape: [1, input.length]);

    final outputBuffer = TensorBuffer.createFixedSize([
      1,
      1,
    ], TfLiteType.float32);

    _interpreter.run(inputBuffer.buffer, outputBuffer.buffer);

    final result = outputBuffer.getDoubleValue(0);
    return {
      "model": "TFLite",
      "kalimat": kalimat,
      "prediksi_nilai": result,
      "kategori": result >= 0.5 ? "darurat" : "bukan darurat",
    };
  }
}
