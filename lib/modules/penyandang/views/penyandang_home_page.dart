import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sightway_mobile/modules/penyandang/widgets/blindstick_empty.dart';
import 'package:sightway_mobile/shared/widgets/navigations/custom_app_bar.dart';
import 'package:sightway_mobile/shared/widgets/users/card_related_user.dart';
import 'package:sightway_mobile/shared/widgets/users/welcome_header.dart';

class PenyandangHomePage extends StatefulWidget {
  const PenyandangHomePage({super.key});

  @override
  State<PenyandangHomePage> createState() => _PenyandangHomePageState();
}

class _PenyandangHomePageState extends State<PenyandangHomePage> {
  String userName = "";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'Pengguna';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Home", showBackButton: false),
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
                name: userName,
                mailOnClick: () {
                  Navigator.pushNamed(context, '/mail');
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
