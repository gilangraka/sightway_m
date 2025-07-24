import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sightway_mobile/shared/constants/colors.dart';

Widget listNotificationCard(String title, String body, String createdAt) {
  final formattedDate = _formatDate(createdAt);

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 1,
          offset: const Offset(0, 0),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon container
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFD6D5F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.error_outline,
            color: Color(0xFF5C5CE0),
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris tanggal di kanan atas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 12, color: AppColors.text),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

String _formatDate(String isoDate) {
  try {
    final dt = DateTime.parse(isoDate);
    return DateFormat('dd MMMM yyyy - HH.mm').format(dt);
  } catch (e) {
    return isoDate;
  }
}
