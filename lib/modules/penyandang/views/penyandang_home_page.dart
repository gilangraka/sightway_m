import 'package:flutter/material.dart';
import 'package:sightway_mobile/modules/penyandang/widgets/blindstick_empty.dart';
import 'package:sightway_mobile/shared/widgets/users/card_related_user.dart';
import 'package:sightway_mobile/shared/widgets/users/welcome_header.dart';

class PenyandangHomePage extends StatelessWidget {
  const PenyandangHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              WelcomeHeader(
                imgUrl:
                    "https://yfgbsigquyriibzovooi.supabase.co/storage/v1/object/public/sightway/post/logo-blank.png",
                role: "Penyandang",
                name: "Gilang Raka Ramadhan",
                mailOnClick: () {
                  // Aksi ketika email diklik
                  print("Email clicked");
                },
              ),

              const SizedBox(height: 30),

              // Blindstick section
              BlindstickEmpty(
                mailOnClick: () {
                  Navigator.pushNamed(context, '/scan-qr');
                },
              ),
              const SizedBox(height: 30),

              // Keluarga section
              const Text(
                "Keluarga Penyandang",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CardRelatedUser(
                  name: "Jijimon Jiji Jiji",
                  status: "Keluarga",
                  detailStatus: "Ayah",
                  imgUrl:
                      "https://yfgbsigquyriibzovooi.supabase.co/storage/v1/object/public/sightway/post/logo-blank.png",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
