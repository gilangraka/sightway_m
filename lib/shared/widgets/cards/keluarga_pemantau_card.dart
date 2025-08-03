import 'package:flutter/material.dart';
import 'package:sightway_mobile/shared/widgets/users/card_related_user.dart';
import 'package:sightway_mobile/shared/widgets/users/card_related_user2.dart';

class KeluargaPemantauCard extends StatelessWidget {
  final String name;
  final String status;
  final String detailStatus;
  final String imgUrl;
  final String penyandangUserId;

  const KeluargaPemantauCard({
    super.key,
    required this.name,
    required this.status,
    required this.detailStatus,
    required this.imgUrl,
    required this.penyandangUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CardRelatedUser2(
        name: name,
        status: status,
        detailStatus: detailStatus,
        imgUrl: imgUrl,
        userId: penyandangUserId,
      ),
    );
  }
}
