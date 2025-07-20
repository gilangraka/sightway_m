import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  String scannedData = '';
  bool _isScanning = false;

  void handleDetection(Barcode barcode) async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      scannedData = barcode.rawValue ?? 'Tidak terbaca';
      debugPrint('Scanned Data: $scannedData');
    });

    // Delay 3 detik sebelum bisa scan lagi
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isScanning = false;
    });
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
                  break; // cukup satu barcode
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
