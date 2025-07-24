import 'package:flutter/material.dart';
import 'package:sightway_mobile/shared/widgets/cards/list_notification_card.dart';
import 'package:sightway_mobile/shared/widgets/navigations/custom_app_bar.dart';
import 'package:sightway_mobile/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PenyandangMailPage extends StatefulWidget {
  const PenyandangMailPage({super.key});

  @override
  State<PenyandangMailPage> createState() => _PenyandangMailPageState();
}

class _PenyandangMailPageState extends State<PenyandangMailPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final firebaseService = FirebaseService();

    if (userId != null) {
      final data = await firebaseService.getListPushNotification(userId);
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _notifications = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Notifikasi"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _notifications.isEmpty
              ? const Center(child: Text("Belum ada notifikasi"))
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
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
