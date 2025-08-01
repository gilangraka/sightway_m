import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sightway_mobile/modules/penyandang/widgets/blindstick_empty.dart';
import 'package:sightway_mobile/services/dio_client.dart';
import 'package:sightway_mobile/shared/widgets/cards/keluarga_penyandang_card.dart';
import 'package:sightway_mobile/shared/widgets/navigations/custom_app_bar.dart';
import 'package:sightway_mobile/shared/widgets/users/welcome_header.dart';

class PenyandangHomePage extends StatefulWidget {
  const PenyandangHomePage({super.key});

  @override
  State<PenyandangHomePage> createState() => _PenyandangHomePageState();
}

class _PenyandangHomePageState extends State<PenyandangHomePage> {
  String userName = '';
  List<Map<String, dynamic>> keluargaList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchKeluarga();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'Pengguna';
    });
  }

  Future<void> _fetchKeluarga() async {
    // Reset state setiap kali fungsi ini dipanggil
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await DioClient.client.get(
        '/mobile/penyandang/list-pemantau?status_filter=keluarga',
      );

      final List<dynamic> data = response.data['data'];
      setState(() {
        keluargaList = data
            .map(
              (e) => {
                'name': e['penyandang__user__name'],
                'status': e['status'],
                'detail_status': e['detail_status'],
              },
            )
            .toList();
      });
    } on DioError catch (e) {
      // ---- INI BLOK YANG PALING PENTING ----
      // Secara spesifik menangkap error dari Dio
      String errorMessage;
      if (e.response != null) {
        // Jika server memberi respons error (404, 401, 503, dll)
        print(
          'KESALAHAN DIO: Status ${e.response?.statusCode} - Data: ${e.response?.data}',
        );
        errorMessage = 'Gagal memuat data (Error ${e.response?.statusCode})';
      } else {
        // Jika request tidak sampai ke server (tidak ada internet, DNS salah)
        print('KESALAHAN DIO (Request): ${e.message}');
        errorMessage = 'Periksa koneksi internet Anda.';
      }
      setState(() {
        _error = errorMessage;
      });
    } catch (e) {
      // Menangkap error lain di luar Dio (misal: error saat mapping data)
      print('KESALAHAN TAK TERDUGA: $e');
      setState(() {
        _error = 'Terjadi kesalahan tidak terduga.';
      });
    } finally {
      // Blok ini akan SELALU dieksekusi, baik sukses maupun gagal
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                  role: "Penyandang",
                  name: userName,
                  mailOnClick: () {
                    Navigator.pushNamed(context, '/mail');
                  },
                ),
                const SizedBox(height: 30),

                BlindstickEmpty(
                  mailOnClick: () {
                    Navigator.pushNamed(context, '/scan-qr');
                  },
                ),
                const SizedBox(height: 30),

                const Text(
                  "Keluarga Penyandang",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 12),

                _buildKeluargaList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeluargaList() {
    if (_isLoading) {
      // 1. Tampilkan loading jika sedang mengambil data
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      // 2. Tampilkan pesan error jika terjadi kegagalan
      return Center(child: Text(_error!));
    }

    if (keluargaList.isEmpty) {
      // 3. Tampilkan pesan jika data memang kosong
      return const Center(child: Text("Belum ada keluarga terhubung."));
    }

    // 4. ✅ Gunakan ListView.builder jika ada data
    return ListView.builder(
      shrinkWrap: true, // Penting di dalam SingleChildScrollView
      physics:
          const NeverScrollableScrollPhysics(), // Agar tidak ada double scroll
      itemCount: keluargaList.length,
      itemBuilder: (context, index) {
        final keluarga = keluargaList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: KeluargaPenyandangCard(
            name: keluarga['name'],
            status: keluarga['status'],
            detailStatus: keluarga['detail_status'],
            imgUrl:
                "https://yfgbsigquyriibzovooi.supabase.co/storage/v1/object/public/sightway/post/logo-blank.png",
          ),
        );
      },
    );
  }
}
