import 'package:flutter/material.dart';
import 'package:sightway_mobile/shared/widgets/cards/keluarga_penyandang_card.dart';
import 'package:sightway_mobile/shared/widgets/navigations/custom_app_bar.dart';
import 'package:sightway_mobile/shared/widgets/users/welcome_header.dart';

class PemantauHomePage extends StatefulWidget {
  const PemantauHomePage({super.key});

  @override
  State<PemantauHomePage> createState() => _PemantauHomePageState();
}

class _PemantauHomePageState extends State<PemantauHomePage> {
  final String userName = "Pemantau"; // Placeholder sementara

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Home", showBackButton: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WelcomeHeader(
                  imgUrl:
                      "https://yfgbsigquyriibzovooi.supabase.co/storage/v1/object/public/sightway/post/logo-blank.png",
                  role: "Pemantau",
                  name: userName,
                  mailOnClick: () {
                    Navigator.pushNamed(context, '/mail');
                  },
                ),
                const SizedBox(height: 30),

                // Placeholder tampilan pemantauan lokasi penyandang
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Cek Lokasi Penyandang",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Tekan tombol di bawah ini untuk melihat posisi terbaru penyandang.",
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: null, // Akan diisi fungsi nanti
                        child: Text("Lihat Lokasi"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                const Text(
                  "Daftar Penyandang",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 12),

                // Placeholder data penyandang (statis sementara)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: KeluargaPenyandangCard(
                        name: "Penyandang ${index + 1}",
                        status: "Terhubung",
                        detailStatus: "Hubungan: Keluarga",
                        imgUrl:
                            "https://yfgbsigquyriibzovooi.supabase.co/storage/v1/object/public/sightway/post/logo-blank.png",
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
