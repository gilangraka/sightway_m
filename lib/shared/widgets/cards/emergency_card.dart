import 'package:flutter/material.dart';

class EmergencyCard extends StatelessWidget {
  final String nama;
  const EmergencyCard({required this.nama, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // lebar 100%
      child: Card(
        elevation: 0,
        color: Colors.red.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "🚨 Darurat Terdeteksi!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Penyandang dengan nama $nama terdeteksi dalam kondisi darurat.",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoEmergencyCard extends StatelessWidget {
  const NoEmergencyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // lebar 100%
      child: Card(
        elevation: 0,
        color: Colors.green.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "✅ Tidak Ada Darurat",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text("Semua penyandang dalam kondisi normal."),
            ],
          ),
        ),
      ),
    );
  }
}
