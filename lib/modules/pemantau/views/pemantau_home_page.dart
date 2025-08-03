import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sightway_mobile/services/dio_client.dart';
import 'package:sightway_mobile/services/firebase_service.dart';
import 'package:sightway_mobile/shared/widgets/cards/emergency_card.dart';
import 'package:sightway_mobile/shared/widgets/cards/keluarga_penyandang_card.dart';
import 'package:sightway_mobile/shared/widgets/navigations/custom_app_bar.dart';
import 'package:sightway_mobile/shared/widgets/users/welcome_header.dart';

class PemantauHomePage extends StatefulWidget {
  const PemantauHomePage({super.key});

  @override
  State<PemantauHomePage> createState() => _PemantauHomePageState();
}

class _PemantauHomePageState extends State<PemantauHomePage> {
  String userName = '';
  List<Map<String, dynamic>> penyandangList = [];
  bool _isLoading = true;
  String? _error;
  String? _penyandangDarurat;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchPenyandang();
    _getFirstPenyandangDarurat();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'Pemantau';
    });
  }

  Future<void> _getFirstPenyandangDarurat() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await DioClient.client.get(
        '/mobile/pemantau/list-penyandang',
      );
      final List<dynamic> data = response.data['data'];

      final List<int> penyandangIds = data
          .map<int>((item) => item['penyandang__user__id'] as int)
          .toList();

      final String? penyandangDarurat =
          await FirebaseService.getEmergencyPenyandang(penyandangIds);

      setState(() {
        _penyandangDarurat = penyandangDarurat;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error _getFirstPenyandangDarurat: $e');
    }
  }

  Future<void> _fetchPenyandang() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await DioClient.client.get(
        '/mobile/pemantau/list-penyandang?status_filter=keluarga',
      );

      final List<dynamic> data = response.data['data'];
      setState(() {
        penyandangList = data
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
      String errorMessage;
      if (e.response != null) {
        print(
          'DIO ERROR: Status ${e.response?.statusCode} - ${e.response?.data}',
        );
        errorMessage = 'Gagal memuat data (Error ${e.response?.statusCode})';
      } else {
        print('DIO ERROR: ${e.message}');
        errorMessage = 'Periksa koneksi internet Anda.';
      }
      setState(() {
        _error = errorMessage;
      });
    } catch (e) {
      print('UNEXPECTED ERROR: $e');
      setState(() {
        _error = 'Terjadi kesalahan tidak terduga.';
      });
    } finally {
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
                  role: "Pemantau",
                  name: userName,
                  mailOnClick: () {
                    Navigator.pushNamed(context, '/mail');
                  },
                ),
                const SizedBox(height: 30),

                _penampilanKartuDarurat(),

                const SizedBox(height: 30),

                const Text(
                  "Keluarga Penyandang",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 12),
                _buildPenyandangList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPenyandangList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (penyandangList.isEmpty) {
      return const Center(child: Text("Belum ada penyandang terhubung."));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: penyandangList.length,
      itemBuilder: (context, index) {
        final penyandang = penyandangList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: KeluargaPenyandangCard(
            name: penyandang['name'],
            status: penyandang['status'],
            detailStatus: penyandang['detail_status'],
            imgUrl:
                "https://yfgbsigquyriibzovooi.supabase.co/storage/v1/object/public/sightway/post/logo-blank.png",
          ),
        );
      },
    );
  }

  Widget _penampilanKartuDarurat() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_penyandangDarurat != null) {
      return EmergencyCard(nama: _penyandangDarurat!);
    } else {
      return const NoEmergencyCard();
    }
  }
}
