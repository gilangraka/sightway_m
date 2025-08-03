import 'package:flutter/material.dart';
import 'package:sightway_mobile/services/dio_client.dart';
import 'package:sightway_mobile/shared/constants/colors.dart';
import 'package:sightway_mobile/shared/widgets/cards/keluarga_pemantau_card.dart';
import 'package:sightway_mobile/modules/pemantau/widgets/keluarga_pemantau_empty.dart';
import 'package:sightway_mobile/shared/widgets/inputs/search_input_field.dart';
import 'package:sightway_mobile/shared/widgets/navigations/custom_app_bar.dart';
import 'package:dio/dio.dart';

class PemantauPenyandangPage extends StatefulWidget {
  const PemantauPenyandangPage({super.key});

  @override
  State<PemantauPenyandangPage> createState() => _PemantauPenyandangPageState();
}

class _PemantauPenyandangPageState extends State<PemantauPenyandangPage> {
  final TextEditingController _searchController = TextEditingController();

  Future<void> fetchPenyandangList() async {
    try {
      final res = await DioClient.client.get(
        '/mobile/pemantau/list-penyandang',
      );
      final List data = res.data['data'];

      final List<Map<String, String>> loadedList = data
          .map<Map<String, String>>((item) {
            return {
              'name': item['penyandang__user__name'] ?? '',
              'email': item['penyandang__user__email'] ?? '',
              'hubungan': '-', // jika tidak ada di response, bisa dikosongkan
              'lokasi': '-', // dummy karena tidak tersedia
              'status': item['status'] ?? '',
              'detail_status': item['detail_status'] ?? '',
            };
          })
          .toList();

      setState(() {
        _penyandangList.clear();
        _penyandangList.addAll(loadedList);
        _filteredList = List.from(_penyandangList);
      });
    } on DioException catch (e) {
      debugPrint('Gagal memuat penyandang: ${e.message}');
      // Optional: tampilkan error UI
    }
  }

  final List<Map<String, String>> _penyandangList = [];

  List<Map<String, String>> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _filteredList = List.from(_penyandangList);
    _searchController.addListener(_onSearchChanged);
    fetchPenyandangList();
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

  void _showSearchModal(BuildContext context) {
    final emailController = TextEditingController();
    final detailStatusController = TextEditingController();
    String? errorMessage;
    Map<String, dynamic>? penyandangData;
    String? selectedStatus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> searchPenyandang() async {
              try {
                final finalEmail = emailController.text.trim();
                final res = await DioClient.client.get(
                  '/mobile/pemantau/search-penyandang?email=$finalEmail',
                );
                final data = res.data['penyandang'];
                setModalState(() {
                  penyandangData = data;
                  errorMessage = null;
                });
              } on DioException catch (e) {
                if (e.response?.statusCode == 400) {
                  setModalState(() {
                    errorMessage = e.response?.data['detail'];
                    penyandangData = null;
                  });
                } else {
                  setModalState(() {
                    errorMessage = "Penyandang tidak ditemukan!";
                    penyandangData = null;
                  });
                }
              }
            }

            Future<void> sendInvitation() async {
              if (penyandangData == null || selectedStatus == null) return;

              try {
                await DioClient.client.post(
                  '/mobile/pemantau/add-invitation-penyandang',
                  data: {
                    "penyandang_id": penyandangData!['id'],
                    "status_pemantau": selectedStatus,
                    "detail_status_pemantau": detailStatusController.text
                        .trim(),
                  },
                );
                Navigator.of(context).pop(); // Close modal
                // TODO: Refresh data if needed
              } on DioException catch (e) {
                // Optional: handle server error here
              }
            }

            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16), // ✅ Border radius bagian atas
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cari Penyandang',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Penyandang',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: searchPenyandang,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                            ),
                            child: const Text('Cari'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (errorMessage != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 20.0),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                        if (penyandangData != null) ...[
                          const Divider(height: 24),
                          Text("Nama: ${penyandangData!['user__name']}"),
                          Text("Email: ${penyandangData!['user__email']}"),
                          const SizedBox(height: 16),
                          const Text('Status Pemantau'),
                          DropdownButton<String>(
                            isExpanded: true,
                            value: selectedStatus,
                            hint: const Text('Pilih status'),
                            items: ['Keluarga', 'Lainnya']
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setModalState(() {
                                selectedStatus = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: detailStatusController,
                            decoration: const InputDecoration(
                              labelText: 'Detail Status',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: sendInvitation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                              ),
                              child: const Text('Invite'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Penyandang yang Terhubung',
        showBackButton: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSearchModal(context),
        child: const Icon(Icons.add),
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
