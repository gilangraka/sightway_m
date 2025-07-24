import 'package:flutter/material.dart';
import 'package:sightway_mobile/shared/widgets/users/card_related_user.dart';

class KeluargaPenyandangCard extends StatelessWidget {
  final String name;
  final String status;
  final String detailStatus;
  final String imgUrl;

  const KeluargaPenyandangCard({
    super.key,
    required this.name,
    required this.status,
    required this.detailStatus,
    required this.imgUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CardRelatedUser(
        name: name,
        status: status,
        detailStatus: detailStatus,
        imgUrl: imgUrl,
      ),
    );
  }
}
