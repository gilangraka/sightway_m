import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sightway_mobile/modules/penyandang/views/penyandang_home_page.dart';
import 'package:sightway_mobile/services/dio_service.dart';
import 'package:sightway_mobile/services/emergency_service.dart';
import 'package:sightway_mobile/shared/widgets/navigations/bottom_navigation.dart';
import 'package:stts/stts.dart';

class PenyandangIndexPage extends StatefulWidget {
  const PenyandangIndexPage({super.key});

  @override
  State<PenyandangIndexPage> createState() => _PenyandangIndexPageState();
}

class _PenyandangIndexPageState extends State<PenyandangIndexPage> {
  // --- Services & State ---
  final _stt = Stt();
  final DioService _dioService = DioService();
  late EmergencyService _aiService;
  bool _isAIServiceInitialized = false;
  bool _isListening = false;
  bool _isProcessing = false; // [PERUBAHAN] Flag untuk mengontrol alur

  // --- Timers & State UI ---
  Timer? _debounce;
  Timer? _maxDurationTimer;
  String _statusMessage = 'Menginisialisasi...';
  String _lastTranscription = '';
  String _predictionResult = '';

  // --- Subscriptions ---
  StreamSubscription? _stateSubscription;
  StreamSubscription? _resultSubscription;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _maxDurationTimer?.cancel();
    _stateSubscription?.cancel();
    _resultSubscription?.cancel();
    _stt.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    _aiService = await EmergencyService.create();
    setState(() {
      _isAIServiceInitialized = true;
    });

    await _stt.hasPermission();

    // [PERUBAHAN] Logika onStateChanged disederhanakan
    _stateSubscription = _stt.onStateChanged.listen(
      (state) {
        if (!mounted) return;
        setState(() {
          _isListening = state == SttState.start;
        });

        if (_isListening) {
          _resetTimersAndState();
        } else {
          // Jika STT berhenti DAN kita tidak sedang memproses hasil,
          // artinya ini adalah timeout/cancel. Maka mulai ulang.
          if (!_isProcessing && _lastTranscription.trim().isEmpty) {
            // <--- [PERBAIKAN]
            print(
              "STT berhenti tanpa hasil (timeout/cancel). Memulai ulang...",
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && !_isListening && !_isProcessing) {
                _stt.start();
              }
            });
          }
        }
      },
      onError: (err) {
        if (!mounted) return;
        setState(() {
          _statusMessage = 'Error STT: $err';
        });
        _restartListeningCycle(); // Coba mulai ulang jika ada error
      },
    );

    _resultSubscription = _stt.onResultChanged.listen((result) {
      if (!mounted) return;
      final transcribedText = result.text;
      setState(() {
        _lastTranscription = transcribedText;
      });

      if (transcribedText.trim().isEmpty) return;

      _startOrResetTimers(transcribedText);
    });

    _stt.start();
  }

  void _resetTimersAndState() {
    _debounce?.cancel();
    _maxDurationTimer?.cancel();
    _debounce = null;
    _maxDurationTimer = null;
    setState(() {
      _statusMessage = 'Mendengarkan...';
      _lastTranscription = '';
      _predictionResult = '';
    });
  }

  void _startOrResetTimers(String text) {
    // [PERUBAHAN] Sesuaikan durasi timer sesuai kebutuhan Anda
    if (_maxDurationTimer == null || !_maxDurationTimer!.isActive) {
      _maxDurationTimer = Timer(const Duration(seconds: 3), () {
        print("Batas waktu 3 detik tercapai!");
        _finalizeAndPredict(text);
      });
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 3), () {
      print("Pengguna berhenti bicara (jeda 2 detik).");
      _finalizeAndPredict(text);
    });
  }

  void _finalizeAndPredict(String text) {
    // [PERUBAHAN] Cek flag _isProcessing agar tidak dieksekusi ganda
    if (_isProcessing || (_debounce == null && _maxDurationTimer == null))
      return;

    // [PERUBAHAN] Set flag untuk menandakan proses dimulai
    setState(() {
      _isProcessing = true;
    });

    _debounce?.cancel();
    _maxDurationTimer?.cancel();
    _debounce = null;
    _maxDurationTimer = null;

    if (text.trim().isEmpty) {
      print("Teks kosong, tidak ada yang diproses. Memulai ulang siklus...");
      _restartListeningCycle(); // Langsung mulai ulang jika teks ternyata kosong
      return;
    }

    setState(() => _statusMessage = 'Menganalisis teks...');
    _runPrediction(text);
  }

  Future<void> _runPrediction(String text) async {
    if (!_isAIServiceInitialized) {
      _restartListeningCycle();
      return;
    }

    final prediction = await _aiService.predict(text);
    final predictionValue = prediction['prediksi_nilai'];
    final category = prediction['kategori'];
    final isEmergency = category == "darurat";

    if (mounted) {
      setState(() {
        _predictionResult =
            'Prediksi: ${predictionValue.toStringAsFixed(3)} (${category.toUpperCase()})';
      });
    }

    if (isEmergency) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mengirim laporan darurat: "$text"')),
      );

      try {
        await _dioService.sendEmergencyReport(text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Laporan berhasil dikirim!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red),
        );
      }
    }

    // [PERUBAHAN] Beri jeda sebelum memulai siklus baru
    Future.delayed(const Duration(seconds: 2), _restartListeningCycle);
  }

  // [PERUBAHAN] Fungsi baru untuk me-restart siklus pendengaran
  void _restartListeningCycle() {
    print("Siklus selesai. Memulai ulang mode pendengaran...");
    if (mounted) {
      setState(() {
        _isProcessing = false; // Reset flag
      });
      // Pastikan untuk memulai hanya jika belum mendengarkan
      if (!_isListening) {
        _stt.start();
      }
    }
  }

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const PenyandangHomePage(),
    Center(child: Text('Pemantau Page')),
    Center(child: Text('Settings Page')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SafeArea(
        // ⬅️ Ini penting!
        child: BottomNavbar(
          role: "penyandang",
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
