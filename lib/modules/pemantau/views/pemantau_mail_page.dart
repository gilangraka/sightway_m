import 'package:flutter/material.dart';
import 'package:sightway_mobile/shared/constants/colors.dart';
import 'package:sightway_mobile/shared/widgets/cards/list_notification_card.dart';
import 'package:sightway_mobile/shared/widgets/navigations/custom_app_bar.dart';

class PemantauMailPage extends StatelessWidget {
  const PemantauMailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Contoh data dummy (jika nanti ingin ditest tampilannya)
    final List<Map<String, String>> dummyNotifications = [
      {
        'title': 'Peringatan Darurat',
        'body': 'Penyandang Anda menekan tombol darurat.',
        'created_at': '2025-08-01 10:12:00',
      },
      {
        'title': 'Status Koneksi',
        'body': 'Koneksi Bluetooth berhasil tersambung.',
        'created_at': '2025-08-01 09:47:00',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(title: "Notifikasi"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: dummyNotifications.isEmpty
              ? const Center(child: Text("Belum ada notifikasi"))
              : ListView.builder(
                  itemCount: dummyNotifications.length,
                  itemBuilder: (context, index) {
                    final notif = dummyNotifications[index];
                    return listNotificationCard(
                      notif['title'] ?? '',
                      notif['body'] ?? '',
                      notif['created_at'] ?? '',
                    );
                  },
                ),
        ),
      ),
    );
  }
}
