import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sightway_mobile/modules/penyandang/widgets/blindstick_empty.dart';
import 'package:sightway_mobile/services/dio_client.dart';
import 'package:sightway_mobile/shared/constants/const.dart'; // Asumsi Anda punya file ini untuk AppColors
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

  // --- STATE BARU UNTUK BLINDSTICK ---
  bool? _isBlindstickConnected; // null = loading, true = connected, false = not
  String? _blindstickMacAddress;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Menggabungkan semua pemanggilan data awal
  Future<void> _loadInitialData() async {
    // Memanggil semua fetch secara bersamaan untuk efisiensi
    await Future.wait([
      _loadUserName(),
      _fetchKeluarga(),
      _checkBlindstickStatus(),
    ]);

    // Set loading ke false setelah semua data selesai dimuat
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        userName = prefs.getString('user_name') ?? 'Pengguna';
      });
    }
  }

  // --- FUNGSI BARU UNTUK CEK STATUS BLINDSTICK ---
  Future<void> _checkBlindstickStatus() async {
    try {
      final response = await DioClient.client.get(
        '/mobile/penyandang/check-blindstick',
      );

      if (mounted) {
        setState(() {
          _isBlindstickConnected = response.data['connected'];
          if (_isBlindstickConnected == true) {
            _blindstickMacAddress = response.data['mac_address'];
          }
        });
      }
    } catch (e) {
      // Jika terjadi error (koneksi, server error, dll), anggap saja tidak terhubung
      print('KESALAHAN SAAT CEK BLINDSTICK: $e');
      if (mounted) {
        setState(() {
          _isBlindstickConnected = false;
        });
      }
    }
  }

  Future<void> _fetchKeluarga() async {
    // Tidak perlu setState _isLoading di sini karena sudah ditangani _loadInitialData
    setState(() {
      _error = null;
    });

    try {
      final response = await DioClient.client.get(
        '/mobile/penyandang/list-pemantau?status_filter=keluarga',
      );

      final List<dynamic> data = response.data['data'];
      if (mounted) {
        setState(() {
          keluargaList = data
              .map(
                (e) => {
                  'name': e['pemantau__user__name'],
                  'status': e['status'],
                  'detail_status': e['detail_status'],
                },
              )
              .toList();
        });
      }
    } on DioError catch (e) {
      String errorMessage;
      if (e.response != null) {
        print(
          'KESALAHAN DIO: Status ${e.response?.statusCode} - Data: ${e.response?.data}',
        );
        errorMessage =
            'Gagal memuat data keluarga (Error ${e.response?.statusCode})';
      } else {
        print('KESALAHAN DIO (Request): ${e.message}');
        errorMessage = 'Periksa koneksi internet Anda.';
      }
      if (mounted) {
        setState(() {
          _error = errorMessage;
        });
      }
    } catch (e) {
      print('KESALAHAN TAK TERDUGA: $e');
      if (mounted) {
        setState(() {
          _error = 'Terjadi kesalahan tidak terduga.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Home", showBackButton: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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

                      // --- MENGGUNAKAN WIDGET BUILDER KONDISIONAL ---
                      _buildBlindstickSection(),
                      const SizedBox(height: 30),

                      const Text(
                        "Keluarga Penyandang",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
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

  // --- WIDGET BUILDER BARU UNTUK KONDISIONAL BLINDSTICK ---
  Widget _buildBlindstickSection() {
    // 1. Tampilkan loading jika data blindstick belum ada
    if (_isBlindstickConnected == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Tampilkan card jika blindstick terhubung
    if (_isBlindstickConnected!) {
      return BlindstickConnectedCard(
        macAddress: _blindstickMacAddress ?? 'Alamat tidak tersedia',
      );
    }

    // 3. Tampilkan opsi untuk menghubungkan jika tidak terhubung
    return BlindstickEmpty(
      // 1. Jadikan callback ini async
      mailOnClick: () async {
        // 2. Tunggu sampai halaman QR Scanner ditutup
        await Navigator.pushNamed(context, '/scan-qr');
        if (mounted) {
          setState(() {
            _isBlindstickConnected = null;
          });
        }
        await _checkBlindstickStatus();
      },
    );
  }

  Widget _buildKeluargaList() {
    // Bagian ini tidak perlu menampilkan loading lagi
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (keluargaList.isEmpty) {
      return const Center(child: Text("Belum ada keluarga terhubung."));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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

// --- WIDGET CARD BARU UNTUK BLINDSTICK YANG TERHUBUNG ---
// Anda bisa letakkan ini di file terpisah (misal: blindstick_connected_card.dart) atau di bawah class ini.
class BlindstickConnectedCard extends StatelessWidget {
  final String macAddress;

  const BlindstickConnectedCard({super.key, required this.macAddress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors
            .primary, // Gunakan warna sukses atau warna lain yang sesuai
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline, // Ikon yang menandakan sukses/terhubung
            size: 40,
            color: AppColors.background,
          ),
          const SizedBox(height: 12),
          const Text(
            "Blindstick Terhubung",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.background,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            macAddress, // Tampilkan MAC address
            style: const TextStyle(fontSize: 12, color: AppColors.background),
          ),
        ],
      ),
    );
  }
}
