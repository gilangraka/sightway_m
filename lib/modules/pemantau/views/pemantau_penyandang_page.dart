import 'package:flutter/material.dart';
import 'package:sightway_mobile/shared/widgets/cards/keluarga_pemantau_card.dart';
import 'package:sightway_mobile/modules/pemantau/widgets/keluarga_pemantau_empty.dart';
import 'package:sightway_mobile/shared/widgets/inputs/search_input_field.dart';

class PemantauPenyandangPage extends StatefulWidget {
  const PemantauPenyandangPage({super.key});

  @override
  State<PemantauPenyandangPage> createState() => _PemantauPenyandangPageState();
}

class _PemantauPenyandangPageState extends State<PemantauPenyandangPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _penyandangList = [
    {
      'name': 'Ayu',
      'email': 'ayu@example.com',
      'hubungan': 'Adik',
      'lokasi': 'Bandung',
      'status': 'Aktif',
      'detail_status': 'Terhubung',
    },
    {
      'name': 'Bayu',
      'email': 'bayu@example.com',
      'hubungan': 'Keponakan',
      'lokasi': 'Semarang',
      'status': 'Tidak Aktif',
      'detail_status': 'Menunggu konfirmasi',
    },
  ];

  List<Map<String, String>> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _filteredList = List.from(_penyandangList);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredList = _penyandangList.where((item) {
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
      appBar: AppBar(
        title: const Text('Penyandang yang Terhubung'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
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
                ? const KeluargaPemantauEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) {
                      final item = _filteredList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: KeluargaPemantauCard(
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
