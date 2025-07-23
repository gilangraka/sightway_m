// lib/modules/penyandang/views/penyandang_index_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stts/stts.dart';
// [1] Ganti import ke service yang baru
import 'package:sightway_mobile/services/emergency_service.dart';

class PenyandangIndexPage extends StatefulWidget {
  const PenyandangIndexPage({super.key});

  @override
  State<PenyandangIndexPage> createState() => _PenyandangIndexPageState();
}

class _PenyandangIndexPageState extends State<PenyandangIndexPage> {
  // --- STTS ---
  final _stt = Stt();
  StreamSubscription? _stateSubscription;
  StreamSubscription? _resultSubscription;
  bool _isListening = false;

  // --- AI Service ---
  // [2] Deklarasikan EmergencyService, gunakan 'late' karena akan diinisialisasi di initState
  late EmergencyService _aiService;
  bool _isAIServiceInitialized = false;

  // --- State UI ---
  String _statusMessage = 'Menginisialisasi...';
  String _lastTranscription = '';
  String _predictionResult = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // 1. Inisialisasi service AI menggunakan factory method `create()`
    // [3] Ubah cara inisialisasi service
    _aiService = await EmergencyService.create();
    setState(() {
      _isAIServiceInitialized = true;
    });

    // 2. Minta izin dan setup listener STTS
    await _stt.hasPermission();

    _stateSubscription = _stt.onStateChanged.listen(
      (state) {
        setState(() {
          _isListening = state == SttState.start;
          if (_isListening) {
            _statusMessage = 'Mendengarkan...';
          } else {
            // Tetap 'Menunggu suara...' jika tidak sedang mendengarkan
            if (_statusMessage != 'Menganalisis teks...') {
              _statusMessage = 'Menunggu suara...';
            }
          }
        });
      },
      onError: (err) {
        setState(() {
          _statusMessage = 'Error STT: $err';
        });
      },
    );

    _resultSubscription = _stt.onResultChanged.listen((result) {
      final String transcribedText = result.text;

      if (transcribedText.trim().isNotEmpty) {
        setState(() {
          _lastTranscription = transcribedText;
          _statusMessage = 'Menganalisis teks...';
        });
        _runPrediction(transcribedText);
      }
    });

    // 3. Mulai mendengarkan secara terus-menerus
    _stt.start();
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _resultSubscription?.cancel();
    _stt.dispose();
    // [4] Hapus pemanggilan dispose, karena EmergencyService tidak memilikinya
    // _aiService.dispose();
    super.dispose();
  }

  Future<void> _runPrediction(String text) async {
    if (!_isAIServiceInitialized) return;

    // [5] Panggil predict dan tangani hasilnya yang berupa Map
    final Map<String, dynamic> prediction = await _aiService.predict(text);

    // Ambil nilai dari Map
    final double predictionValue = prediction['prediksi_nilai'];
    final String category = prediction['kategori'];
    final bool isEmergency = category == "darurat";

    setState(() {
      _predictionResult =
          'Prediksi: ${predictionValue.toStringAsFixed(3)} '
          '(${category.toUpperCase()})';

      // Kembalikan status setelah analisis selesai
      if (_isListening) {
        _statusMessage = 'Mendengarkan...';
      } else {
        _statusMessage = 'Menunggu suara...';
      }
    });

    if (isEmergency) {
      _showEmergencyAlert(text);
    }
  }

  void _showEmergencyAlert(String detectedText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚨 DETEKSI DARURAT! 🚨'),
        content: Text(
          'Kalimat terdeteksi:\n\n"$detectedText"\n\nSegera kirim notifikasi bantuan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abaikan'),
          ),
          FilledButton(
            onPressed: () {
              // Mengingat proyek Anda 'Sightway', ini adalah tempat logika
              // untuk mengirim notifikasi ke aplikasi web atau pemantau lainnya.
              print("MENGIRIM NOTIFIKASI BANTUAN DARI SIGHTWAY!");
              Navigator.of(context).pop();
            },
            child: const Text('Kirim Bantuan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sightway - Mode Pendengaran"),
        backgroundColor: _isListening ? Colors.red.shade100 : Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isListening ? Icons.mic : Icons.mic_off, // Icon lebih sesuai
                size: 80,
                color: _isListening ? Colors.red : Colors.blueGrey,
              ),
              const SizedBox(height: 24),
              Text(
                _statusMessage,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (_lastTranscription.isNotEmpty) ...[
                Text(
                  'Transkripsi Terakhir:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _lastTranscription,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (_predictionResult.isNotEmpty)
                Text(
                  _predictionResult,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _predictionResult.contains("DARURAT")
                        ? Colors.red
                        : Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
