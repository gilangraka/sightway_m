import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sightway_mobile/services/dio_client.dart';
import 'package:sightway_mobile/services/dio_service.dart';
import 'package:sightway_mobile/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class FirebaseService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Inisialisasi Firebase dan FCM
  static Future<void> init() async {
    await Firebase.initializeApp();
    await _requestPermission();
    await _initFCMToken();
    _listenForegroundMessages();
  }

  /// Minta izin notifikasi ke user
  static Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ Notifikasi diizinkan');
    } else {
      debugPrint('❌ Notifikasi tidak diizinkan');
    }
  }

  /// Ambil dan tampilkan token FCM
  static Future<void> _initFCMToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('📱 FCM Token: $token');
    } catch (e) {
      debugPrint('❌ Gagal mengambil token FCM: $e');
    }
  }

  /// Listener pesan ketika aplikasi foreground
  static void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔔 Pesan diterima saat foreground!');
      debugPrint('Judul: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
    });
  }

  /// Kirim data penyandang ke Realtime Database
  static Future<void> sendDataPenyandangToFirebase(
    String userId,
    String nama,
    String email,
    String fcmToken,
  ) async {
    try {
      final penyandangRef = _db.child('penyandang').child(userId);

      await penyandangRef.set({
        'status': 'normal',
        'nama': nama,
        'email': email,
        'fcm_token': fcmToken,
        'invitations': {},
        'emergency_logs': {},
      });

      debugPrint('✅ Data penyandang berhasil dikirim ke Firebase');
    } catch (e) {
      debugPrint('❌ Gagal mengirim data penyandang: $e');
      rethrow;
    }
  }

  static Future<void> sendInvitations(
    String penyandangUserId,
    String pemantauUserId,
    String pemantauName,
    String pemantauEmail,
    String statusPemantau,
    String detailStatus,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final invitationRef = _db
          .child('penyandang')
          .child(penyandangUserId)
          .child('invitations')
          .child(timestamp);

      await invitationRef.set({
        'user_id': pemantauUserId,
        'pemantau_name': pemantauName,
        'pemantau_email': pemantauEmail,
        'status_pemantau': statusPemantau,
        'detail_status': detailStatus,
        'status': 'pending',
      });

      debugPrint(
        '✅ Invitation berhasil ditambahkan ke penyandang $penyandangUserId',
      );
    } catch (e) {
      debugPrint('❌ Gagal menambahkan invitation: $e');
      rethrow;
    }
  }

  static Future<void> acceptOrDeclineInvitation({
    required String penyandangId,
    required String pemantauId,
    required String newStatus,
  }) async {
    try {
      final invitationsRef = _db
          .child('penyandang')
          .child(penyandangId)
          .child('invitations');

      final snapshot = await invitationsRef.get();

      if (snapshot.exists) {
        final invitations = snapshot.value as Map;

        for (final entry in invitations.entries) {
          final key = entry.key;
          final value = Map<String, dynamic>.from(entry.value);

          if (value['user_id'] == pemantauId) {
            final invitationRef = invitationsRef.child(key);
            await invitationRef.update({'status': newStatus});

            // Nanti disini ditambahkan, ketika status == accepted, maka hit API untuk menambah data penyandang_pemantau

            debugPrint('✅ Invitation berhasil diupdate: $newStatus');
            return;
          }
        }

        debugPrint('⚠️ Invitation dengan user_id $pemantauId tidak ditemukan');
      } else {
        debugPrint('⚠️ Tidak ada invitation untuk penyandang $penyandangId');
      }
    } catch (e) {
      debugPrint('❌ Gagal mengupdate invitation: $e');
      rethrow;
    }
  }

  static Future<void> sendDataPemantauToFirebase(
    String userId,
    String nama,
    String email,
    String fcmToken,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final pemantauRef = _db.child('pemantau').child(timestamp);

      await pemantauRef.set({
        'user_id': userId,
        'nama': nama,
        'email': email,
        'fcm_token': fcmToken,
      });

      debugPrint(
        '✅ Data pemantau berhasil dikirim ke Firebase dengan timestamp: $timestamp',
      );
    } catch (e) {
      debugPrint('❌ Gagal mengirim data pemantau: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getListPushNotification(
    String userId,
  ) async {
    try {
      final snapshot = await _db
          .child('push_notifications')
          .child(userId)
          .orderByChild('created_at')
          .get();

      if (!snapshot.exists) return [];

      // Ambil data dan konversi ke list Map, lalu urutkan dari terbaru
      final data = snapshot.value as Map<dynamic, dynamic>;
      final notifList = data.entries.map((e) {
        final val = Map<String, dynamic>.from(e.value);
        return {
          'title': val['title'] ?? '',
          'body': val['body'] ?? '',
          'created_at': val['created_at'] ?? '',
        };
      }).toList();

      // Urutkan dari created_at terbaru
      notifList.sort((a, b) => b['created_at'].compareTo(a['created_at']));

      return notifList;
    } catch (e) {
      print("Error fetching notifications: $e");
      return [];
    }
  }

  static Future<void> penyandangEmergencyFunction({
    required String userId,
    required String userName,
    required String detectedText,
    required double predictionValue,
  }) async {
    try {
      debugPrint('🚨 FUNGSI DARURAT DIMULAI UNTUK USER: $userId');

      // --- [0] Rekam Audio 5 Detik ---
      debugPrint('🎤 Merekam audio 5 detik...');
      final record = AudioRecorder();
      final tempDir = await getTemporaryDirectory();
      final audioPath = '${tempDir.path}/emergency_audio.m4a';

      if (await record.hasPermission()) {
        await record.start(const RecordConfig(), path: audioPath);
        await Future.delayed(Duration(seconds: 5));
        await record.stop();
      } else {
        debugPrint('❌ Tidak ada izin untuk merekam audio.');
      }

      // 1. Dapatkan daftar pemantau dari API
      debugPrint('🔄 [1/4] Mengambil daftar pemantau...');
      final response = await DioClient.client.get(
        '/mobile/penyandang/list-pemantau',
      );
      final List<dynamic> pemantauListApi = response.data['data'];
      final List<int> pemantauUserIds = pemantauListApi
          .map<int>((p) => p['pemantau__user__id'] as int)
          .toList();
      debugPrint('✅ [1/4] Ditemukan ${pemantauUserIds.length} pemantau.');

      if (pemantauUserIds.isEmpty) {
        debugPrint('⚠️ Tidak ada pemantau yang terhubung. Proses dihentikan.');
        return;
      }

      // 2. Update Realtime Database dengan log darurat
      debugPrint('🔄 [2/4] Mencatat log darurat di Firebase...');
      final emergencyId = DateTime.now().millisecondsSinceEpoch.toString();
      final Position position = await _getCurrentLocation();

      final supabaseService = SupabaseService(
        supabaseUrl: "https://yfgbsigquyriibzovooi.supabase.co",
        supabaseAnonKey:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlmZ2JzaWdxdXlyaWliem92b29pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0NzIyODMsImV4cCI6MjA2NzA0ODI4M30.HKx7X4wbq8O_qQ667apVDfcdrUkKPqYxohT_VsJ_9Q8",
        bucket: "sightway",
      );

      final List<String> photoUrls = await supabaseService
          .captureAndUploadPhotos(
            userId: userId,
            supabase: supabaseService.client,
            bucket: "sightway",
          );
      final folderBucket = photoUrls;

      // Upload audio
      String? lastAudioUrl;
      final audioFile = File(audioPath);
      if (await audioFile.exists()) {
        final fileBytes = await audioFile.readAsBytes();
        final audioFilePath = 'emergency/$userId/$emergencyId/audio.m4a';

        await supabaseService.client.storage
            .from("sightway")
            .uploadBinary(
              audioFilePath,
              fileBytes,
              fileOptions: FileOptions(contentType: 'audio/m4a'),
            );

        lastAudioUrl = supabaseService.client.storage
            .from("sightway")
            .getPublicUrl(audioFilePath);
      }

      final emergencyLogRef = _db
          .child('penyandang')
          .child(userId)
          .child('emergency_logs')
          .child(emergencyId);

      await emergencyLogRef.set({
        'created_at': ServerValue.timestamp, // Menggunakan waktu server
        'latitude': position.latitude,
        'longitude': position.longitude,
        'folder_bucket_supabase': folderBucket,
        'kalimat_terdeteksi': detectedText,
        'probabilitas_darurat': predictionValue,
        'last_audio': lastAudioUrl,
      });
      debugPrint('✅ [2/4] Log darurat berhasil dicatat di RTDB.');

      // 3. Cari FCM token untuk setiap pemantau
      debugPrint('🔄 [3/4] Mencari FCM token para pemantau...');

      // 4. Kirim notifikasi FCM ke setiap pemantau
      debugPrint('🔄 [4/4] Mengirim notifikasi FCM...');
      try {
        await DioClient.client.get(
          '/mobile/penyandang/send-emergency-to-pemantau',
        );
        debugPrint('✅ Notifikasi berhasil terkirim');
      } catch (e) {
        debugPrint('❌ Gagal mengirim notifikasi: $e');
      }

      debugPrint('✅ [4/4] Proses pengiriman notifikasi selesai.');
    } catch (e) {
      debugPrint('❌ Terjadi kesalahan fatal pada fungsi darurat: $e');
      rethrow;
    }
  }

  static Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
