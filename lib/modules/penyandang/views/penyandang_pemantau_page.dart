import 'package:flutter/material.dart';
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

  final List<Map<String, String>> _pemantauList = [
    {
      'name': 'Dina',
      'email': 'dina@example.com',
      'hubungan': 'Kakak',
      'lokasi': 'Yogyakarta',
      'status': 'Aktif',
      'detail_status': 'Terhubung',
    },
    {
      'name': 'Fajar',
      'email': 'fajar@example.com',
      'hubungan': 'Teman',
      'lokasi': 'Jakarta Selatan',
      'status': 'Aktif',
      'detail_status': 'Menunggu konfirmasi',
    },
  ];

  List<Map<String, String>> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _filteredList = List.from(_pemantauList);
    _searchController.addListener(_onSearchChanged);
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
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
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
