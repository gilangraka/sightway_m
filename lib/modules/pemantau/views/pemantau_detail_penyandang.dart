import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sightway_mobile/shared/constants/colors.dart';
import 'package:sightway_mobile/shared/widgets/navigations/custom_app_bar.dart';
import 'package:sightway_mobile/services/firebase_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import 'package:sightway_mobile/shared/widgets/audio_player_widget.dart';
import 'package:sightway_mobile/shared/widgets/image_gallery_viewer.dart';

class PemantauDetailPenyandangPage extends StatefulWidget {
  final String userId;

  const PemantauDetailPenyandangPage({super.key, required this.userId});

  @override
  State<PemantauDetailPenyandangPage> createState() =>
      _PemantauDetailPenyandangPageState();
}

class _PemantauDetailPenyandangPageState
    extends State<PemantauDetailPenyandangPage> {
  final _db = FirebaseDatabase.instance.ref();

  String? name;
  String? email;
  String? status;
  double? latitude;
  double? longitude;
  Map<String, dynamic>? emergencyLogs;
  StreamSubscription<DatabaseEvent>? _subscription;

  // DIHAPUS: Controller tidak lagi diperlukan untuk update otomatis
  // final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }
  // Ganti seluruh method ini di file Anda

  Widget _buildEmergencyLogs() {
    if (emergencyLogs == null || emergencyLogs!.isEmpty) {
      return const SizedBox.shrink(); // Tidak menampilkan apa-apa jika kosong
    }

    // Ubah map menjadi list dan urutkan berdasarkan timestamp (key) terbaru
    final sortedLogs = emergencyLogs!.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "🚨 Histori Darurat",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          itemCount: sortedLogs.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final logEntry = sortedLogs[index];
            final logData = Map<String, dynamic>.from(logEntry.value as Map);
            final timestamp = int.tryParse(logEntry.key) ?? 0;
            final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            final formattedDate = DateFormat(
              'd MMMM yyyy, HH:mm:ss',
              'id_ID',
            ).format(dateTime);
            final List<dynamic>? imageList =
                logData['folder_bucket_supabase'] as List<dynamic>?;
            final String? audioUrl = logData['last_audio'] as String?;

            // MODIFIKASI DI SINI: Ganti Card dengan Container
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(
                  4,
                ), // Samakan dengan _buildInfoCard
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Divider(),
                  _buildInfoRow(
                    label: "Kalimat",
                    valueWidget: Text(
                      logData['kalimat_terdeteksi']?.toString() ?? '-',
                    ),
                  ),
                  _buildInfoRow(
                    label: "Probabilitas",
                    valueWidget: Text(
                      logData['probabilitas_darurat']?.toString() ?? '-',
                    ),
                  ),
                  if (audioUrl != null && audioUrl.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      "Rekaman Suara:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    AudioPlayerWidget(audioUrl: audioUrl),
                  ],
                  if (imageList != null && imageList.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      "Foto Lingkungan:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageList.length,
                        itemBuilder: (ctx, imgIndex) {
                          final imageUrl = imageList[imgIndex].toString();
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageGalleryViewer(
                                    imageUrls: imageList,
                                    initialIndex: imgIndex,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Hero(
                                tag: imageUrl,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    imageUrl,
                                    width: 120,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.broken_image,
                                        size: 40,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _launchGoogleMaps() async {
    // Pastikan latitude dan longitude tidak null
    if (latitude == null || longitude == null) return;

    // Buat URL dengan format yang benar
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      // Coba buka URL
      await launchUrl(googleMapsUrl);
    } catch (e) {
      // Jika gagal, tampilkan pesan error
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tidak bisa membuka peta: $e')));
      }
    }
  }

  void _startMonitoring() async {
    await FirebaseService.openPemantauPenyandangDetail(widget.userId);
    _listenRealtimeData();
  }

  void _listenRealtimeData() {
    final stream = _db.child('penyandang').child(widget.userId).onValue;
    _subscription = stream.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null && mounted) {
        setState(() {
          name = data['nama']?.toString();
          email = data['email']?.toString();
          status = data['status']?.toString();
          latitude = double.tryParse(data['latitude']?.toString() ?? '');
          longitude = double.tryParse(data['longitude']?.toString() ?? '');

          if (status == 'emergency' && data['emergency_logs'] != null) {
            emergencyLogs = Map<String, dynamic>.from(
              data['emergency_logs'] ?? {},
            );
            print("Data emergensi : $emergencyLogs");
          } else {
            emergencyLogs = null;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    FirebaseService.closePemantauPenyandangDetail(widget.userId);
    super.dispose();
  }

  // ... (Sisa method _buildStatusBadge, _buildInfoRow, _buildInfoCard tidak berubah)

  Widget _buildStatusBadge(String? status) {
    Color color = Colors.grey;
    String label = status ?? 'offline';
    if (status == 'emergency') color = Colors.redAccent;
    if (status == 'normal') color = Colors.green;

    String sentenceCaseLabel = label.isNotEmpty
        ? '${label[0].toUpperCase()}${label.substring(1).toLowerCase()}'
        : label;

    return Chip(
      label: Text(
        sentenceCaseLabel,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      shape: const StadiumBorder(side: BorderSide(color: Colors.transparent)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildInfoRow({required String label, required Widget valueWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          valueWidget,
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildInfoRow(label: "Nama", valueWidget: Text(name ?? 'Memuat...')),
          const Divider(),
          _buildInfoRow(
            label: "Email",
            valueWidget: Text(email ?? 'Memuat...'),
          ),
          const Divider(),
          _buildInfoRow(
            label: "Status",
            valueWidget: _buildStatusBadge(status),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    if (latitude == null || longitude == null) {
      return Container(
        height: 250,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, color: Colors.grey, size: 48),
            SizedBox(height: 8),
            Text("Menunggu data lokasi..."),
          ],
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: FlutterMap(
        // DIHAPUS: Properti controller tidak lagi diberikan ke widget peta
        // mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(latitude!, longitude!),
          initialZoom: 16.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.flutter-map.example',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(latitude!, longitude!),
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Detail Penyandang"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildInfoCard(),
              const SizedBox(height: 16),
              _buildMapView(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.navigation_outlined),
                  label: const Text("Buka di Google Maps"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: (latitude == null || longitude == null)
                      ? null
                      : _launchGoogleMaps,
                ),
              ),
              const SizedBox(height: 16),
              if (status == 'emergency') _buildEmergencyLogs(),

              const SizedBox(height: 16),
              if (status == 'emergency')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text("Set Tidak Darurat"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      await FirebaseService.setNotEmergency(widget.userId);
                      // Tidak perlu setState di sini karena stream listener akan otomatis trigger
                    },
                  ),
                ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
