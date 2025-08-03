import 'package:flutter/material.dart';
import 'package:sightway_mobile/shared/constants/colors.dart';

class CardRelatedUser extends StatelessWidget {
  final String name;
  final String status;
  final String detailStatus;
  final String imgUrl;

  const CardRelatedUser({
    super.key,
    required this.name,
    required this.status,
    required this.detailStatus,
    required this.imgUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Profile Picture
        // Container(
        //   width: 50,
        //   height: 50,
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(12),
        //     image: DecorationImage(
        //       image: NetworkImage(imgUrl),
        //       fit: BoxFit.cover,
        //     ),
        //   ),
        // ),
        // const SizedBox(width: 12),
        // Name and status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                status,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        // Detail status (like location tag)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            detailStatus,
            style: const TextStyle(
              color: AppColors.background,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
