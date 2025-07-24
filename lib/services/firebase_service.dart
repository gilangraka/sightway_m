import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

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
}
