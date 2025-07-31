import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sightway_mobile/modules/penyandang/views/penyandang_home_page.dart';
import 'package:sightway_mobile/services/dio_service.dart';
import 'package:sightway_mobile/services/emergency_service.dart';
import 'package:sightway_mobile/shared/widgets/navigations/bottom_navigation.dart';
import 'package:stts/stts.dart';

// [PERUBAHAN] Import service yang diperlukan
import 'package:sightway_mobile/services/firebase_service.dart';
import 'package:sightway_mobile/services/token_storage.dart'; // Sesuaikan jika nama service berbeda

class PenyandangIndexPage extends StatefulWidget {
  const PenyandangIndexPage({super.key});

  @override
  State<PenyandangIndexPage> createState() => _PenyandangIndexPageState();
}

class _PenyandangIndexPageState extends State<PenyandangIndexPage> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  StreamSubscription<DatabaseEvent>? _monitoringSubscription;
  Timer? _locationUpdateTimer;

  // --- Services & State ---
  final _stt = Stt();
  final DioService _dioService = DioService();
  late EmergencyService _aiService;
  bool _isAIServiceInitialized = false;
  bool _isListening = false;
  bool _isProcessing = false;

  // [PERUBAHAN] Variabel untuk menyimpan data user yang sedang login
  String? _currentUserId;
  String? _currentUserName;

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
    // [PERUBAHAN] Muat data user terlebih dahulu
    await _loadUserData();

    if (_currentUserId != null) {
      final isMonitoredRef = _db.child(
        'penyandang/$_currentUserId/is_monitored',
      );
      _monitoringSubscription = isMonitoredRef.onValue.listen((event) {
        final value = event.snapshot.value;
        final isMonitored = value == true;

        if (isMonitored) {
          _startLocationUpdates();
        } else {
          _stopLocationUpdates();
        }
      });
    }

    _aiService = await EmergencyService.create();
    setState(() {
      _isAIServiceInitialized = true;
    });

    await _stt.hasPermission();

    // ... (sisa fungsi _initialize tidak berubah) ...
    _stateSubscription = _stt.onStateChanged.listen(
      (state) {
        if (!mounted) return;
        setState(() {
          _isListening = state == SttState.start;
        });

        if (_isListening) {
          _resetTimersAndState();
        } else {
          if (!_isProcessing && _lastTranscription.trim().isEmpty) {
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
        _restartListeningCycle();
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

  // [PERUBAHAN] Fungsi baru untuk memuat data pengguna dari storage
  Future<void> _loadUserData() async {
    // Asumsi TokenStorage memiliki metode untuk mengambil id dan nama user.
    // Sesuaikan dengan implementasi Anda.
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString("user_id");
    _currentUserName = prefs.getString("user_name");
    print("User Data Loaded: ID = $_currentUserId, Name = $_currentUserName");
  }

  void _startLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 5), (
      _,
    ) async {
      final position = await _getCurrentLocation();
      final ref = _db.child('penyandang/$_currentUserId');
      await ref.update({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
      print(
        '📍 Lokasi diperbarui: ${position.latitude}, ${position.longitude}',
      );
    });
  }

  void _stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    print('🛑 Lokasi berhenti diperbarui karena tidak lagi dimonitor.');
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Layanan lokasi tidak aktif');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen');
    }

    return await Geolocator.getCurrentPosition();
  }

  // ... (fungsi _resetTimersAndState, _startOrResetTimers, _finalizeAndPredict tidak berubah) ...
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
    if (_isProcessing || (_debounce == null && _maxDurationTimer == null))
      return;

    setState(() {
      _isProcessing = true;
    });

    _debounce?.cancel();
    _maxDurationTimer?.cancel();
    _debounce = null;
    _maxDurationTimer = null;

    if (text.trim().isEmpty) {
      print("Teks kosong, tidak ada yang diproses. Memulai ulang siklus...");
      _restartListeningCycle();
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

    // [PERUBAHAN UTAMA] Logika ketika darurat terdeteksi
    if (isEmergency) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🚨 Darurat terdeteksi! Memulai prosedur...')),
      );

      // Pastikan data user sudah dimuat sebelumnya
      if (_currentUserId != null && _currentUserName != null) {
        try {
          // Panggil fungsi darurat dari FirebaseService
          await FirebaseService.penyandangEmergencyFunction(
            userId: _currentUserId!,
            userName: _currentUserName!,
            detectedText: text,
            predictionValue: predictionValue,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Prosedur darurat berhasil dijalankan!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Gagal menjalankan prosedur: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Fallback jika data user karena suatu alasan tidak termuat
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Gagal: Data pengguna tidak dapat dimuat.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    Future.delayed(const Duration(seconds: 2), _restartListeningCycle);
  }

  void _restartListeningCycle() {
    print("Siklus selesai. Memulai ulang mode pendengaran...");
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
      if (!_isListening) {
        _stt.start();
      }
    }
  }

  // ... (sisa kode untuk navigasi tidak berubah) ...
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const PenyandangHomePage(),
    const Center(child: Text('Pemantau Page')),
    const Center(child: Text('Settings Page')),
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
        child: BottomNavbar(
          role: "penyandang",
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
