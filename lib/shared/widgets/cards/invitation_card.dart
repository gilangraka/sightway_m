import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sightway_mobile/shared/constants/colors.dart';
import 'package:sightway_mobile/services/firebase_service.dart';

class InvitationCard extends StatelessWidget {
  final String name;
  final String email;
  final String status;
  final String detailStatus;
  final String pemantau_id;
  final VoidCallback onActionComplete;

  const InvitationCard({
    super.key,
    required this.name,
    required this.email,
    required this.status,
    required this.detailStatus,
    required this.pemantau_id,
    required this.onActionComplete,
  });

  Future<void> _handleAction(BuildContext context, String newStatus) async {
    final pref = await SharedPreferences.getInstance();
    final penyandangId = pref.getString('user_id');

    if (penyandangId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User ID tidak ditemukan.')));
      return;
    }

    try {
      await FirebaseService.acceptOrDeclineInvitation(
        penyandangId: penyandangId,
        pemantauId: pemantau_id,
        newStatus: newStatus,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'accepted'
                ? 'Undangan berhasil diterima.'
                : 'Undangan berhasil ditolak.',
          ),
          backgroundColor: newStatus == 'accepted' ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      onActionComplete();

      // Trigger refresh invitation list (optional)
      // You can call a callback here if needed
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat memproses undangan.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade100,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(email, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Status: $status'),
            Text('Detail: $detailStatus'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleAction(context, 'rejected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleAction(context, 'accepted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Terima'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
