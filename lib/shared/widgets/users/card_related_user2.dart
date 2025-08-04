import 'package:flutter/material.dart';
import 'package:sightway_mobile/services/firebase_service.dart';
import 'package:sightway_mobile/shared/constants/colors.dart';

class CardRelatedUser2 extends StatefulWidget {
  final String name;
  final String status;
  final String detailStatus;
  final String imgUrl;
  final String userId;

  const CardRelatedUser2({
    super.key,
    required this.name,
    required this.status,
    required this.detailStatus,
    required this.imgUrl,
    required this.userId,
  });

  @override
  State<CardRelatedUser2> createState() => _CardRelatedUser2State();
}

class _CardRelatedUser2State extends State<CardRelatedUser2> {
  String firebaseStatus = 'Memuat...';

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final String? result = await FirebaseService.getPenyandangStatus(
      widget.userId,
    );
    if (!mounted) return;
    setState(() {
      firebaseStatus = result ?? "Offline";
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    final String formattedStatus =
        '${widget.status[0].toUpperCase()}${widget.status.substring(1).toLowerCase()}';

    final String formattedFirebaseStatus =
        '${firebaseStatus[0].toUpperCase()}${firebaseStatus.substring(1).toLowerCase()}';

    return InkWell(
      onTap: () {
        if (firebaseStatus.toLowerCase() == "offline") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Penyandang sedang offline"),
              backgroundColor: Colors.grey[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          return; // Tidak melakukan navigasi
        }

        Navigator.pushNamed(
          context,
          '/pemantau/detail-penyandang/${widget.userId}',
        );
      },

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  formattedFirebaseStatus,
                  style: TextStyle(
                    fontSize: 12,
                    color: formattedFirebaseStatus.toLowerCase() == 'emergency'
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              "$formattedStatus - ${widget.detailStatus}",
              style: const TextStyle(
                color: AppColors.background,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
