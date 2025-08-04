import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:sightway_mobile/services/dio_client.dart';
import 'package:sightway_mobile/services/firebase_service.dart';
import 'package:sightway_mobile/shared/widgets/cards/invitation_card.dart';
import 'package:sightway_mobile/shared/widgets/cards/keluarga_penyandang_card.dart';
import 'package:sightway_mobile/modules/penyandang/widgets/keluarga_penyandang_empty.dart';
import 'package:sightway_mobile/shared/widgets/inputs/search_input_field.dart';
import 'package:sightway_mobile/shared/widgets/navigations/custom_app_bar.dart';

class PenyandangPemantauPage extends StatefulWidget {
  const PenyandangPemantauPage({super.key});

  @override
  State<PenyandangPemantauPage> createState() => _PenyandangPemantauPageState();
}

class _PenyandangPemantauPageState extends State<PenyandangPemantauPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _pemantauList = [];
  List<Map<String, dynamic>> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    fetchPemantauList();
    fetchInvitations();
  }

  List<Map<String, dynamic>> _invitations = [];

  Future<void> fetchInvitations() async {
    final data = await FirebaseService.getInvitations();
    if (!mounted) return;
    setState(() {
      _invitations = data;
    });
  }

  Future<void> fetchPemantauList() async {
    try {
      final res = await DioClient.client.get(
        '/mobile/penyandang/list-pemantau',
      );
      final List data = res.data['data'];

      final List<Map<String, String>> loadedList = data
          .map<Map<String, String>>((item) {
            return {
              'name': item['pemantau__user__name'] ?? '',
              'email': item['pemantau__user__email'] ?? '',
              'status': item['status'] ?? '',
              'detail_status': item['detail_status'] ?? '',
              'user_id': item['user_id'] ?? '',
            };
          })
          .toList();

      setState(() {
        _pemantauList.clear();
        _pemantauList.addAll(loadedList);
        _filteredList = List.from(_pemantauList);
      });
    } on DioException catch (e) {
      debugPrint('❌ Gagal mengambil pemantau: ${e.message}');
      // Optional: Tampilkan error UI atau snack bar
      setState(() {
        _pemantauList.clear();
        _filteredList.clear();
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredList = _pemantauList.where((item) {
        final name = item['name']?.toLowerCase() ?? '';
        final email = item['email']?.toLowerCase() ?? '';
        return name.contains(query) || email.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Pemantau yang Terhubung',
        showBackButton: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchInput(
              controller: _searchController,
              hint: 'Cari nama...',
            ),
          ),

          if (_invitations.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _invitations.length,
                itemBuilder: (context, index) {
                  final invitation = _invitations[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InvitationCard(
                      name: invitation['pemantau_name'] ?? '-',
                      email: invitation['pemantau_email'] ?? '-',
                      status: invitation['status_pemantau'] ?? '-',
                      detailStatus: invitation['detail_status'] ?? '-',
                      pemantau_id: invitation['user_id'] ?? '-',
                      onActionComplete: () => {
                        fetchInvitations(),
                        fetchPemantauList(),
                      },
                    ),
                  );
                },
              ),
            ),

          Expanded(
            child: _filteredList.isEmpty
                ? const KeluargaPenyandangEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) {
                      final item = _filteredList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: KeluargaPenyandangCard(
                          name: item['name'] ?? '',
                          status: item['status'] ?? '',
                          detailStatus: item['detail_status'] ?? '',
                          imgUrl:
                              'https://yfgbsigquyriibzovooi.supabase.co/storage/v1/object/public/sightway/post/logo-blank.png',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
