import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dio/dio.dart';
import 'package:sightway_mobile/services/dio_client.dart';
import 'package:sightway_mobile/shared/constants/colors.dart'; // Ubah sesuai path DioClient-mu

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  String scannedData = '';
  bool _isScanning = false;

  Future<void> handleDetection(Barcode barcode) async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      scannedData = barcode.rawValue ?? 'Tidak terbaca';
      debugPrint('Scanned Data: $scannedData');
    });

    await connectBlindstick(scannedData);

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() {
      _isScanning = false;
    });
  }

  Future<void> connectBlindstick(String macAddress) async {
    try {
      final response = await DioClient.client.post(
        '/mobile/penyandang/connect-blindstick',
        data: {"mac_address": macAddress},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Blindstick berhasil dikoneksikan"),
            backgroundColor: AppColors.successText,
          ),
        );

        Navigator.pop(context);
      }
    } on DioException catch (e) {
      String errorMessage = "❌ Gagal menghubungkan blindstick";
      if (e.response?.data is Map && e.response?.data['detail'] != null) {
        errorMessage = e.response?.data['detail'];
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Blindstick')),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              onDetect: (capture) {
                for (final barcode in capture.barcodes) {
                  handleDetection(barcode);
                  break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
