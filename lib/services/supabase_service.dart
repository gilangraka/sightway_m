import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

class SupabaseService {
  final SupabaseClient client;
  final String bucket;

  SupabaseService({
    required String supabaseUrl,
    required String supabaseAnonKey,
    required this.bucket,
  }) : client = SupabaseClient(supabaseUrl, supabaseAnonKey);

  /// Upload file ke Supabase Storage dan return path-nya
  Future<String> upload(String sectionName, File file) async {
    final fileExt = file.path.split('.').last;
    final uniqueFileName =
        '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}.$fileExt';
    final filePath = '$sectionName/$uniqueFileName';

    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

    final storageResponse = await client.storage
        .from(bucket)
        .upload(
          filePath,
          file,
          fileOptions: FileOptions(contentType: mimeType),
        );

    try {
      final uploadedPath = await client.storage
          .from(bucket)
          .upload(
            filePath,
            file,
            fileOptions: FileOptions(contentType: mimeType),
          );

      return uploadedPath; // ini adalah path: String
    } on StorageException catch (e) {
      throw Exception('Supabase upload error: ${e.message}');
    }
  }

  /// Ambil public URL dari file path yang disimpan
  String getPublicUrl(String filePath) {
    final publicUrl = client.storage.from(bucket).getPublicUrl(filePath);
    return publicUrl;
  }

  Future<List<String>> captureAndUploadPhotos({
    required String userId,
    required SupabaseClient supabase,
    required String bucket,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final folderPath = 'emergency/$userId/$timestamp';

    // 1. Ambil kamera belakang
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
    );
    final controller = CameraController(backCamera, ResolutionPreset.medium);
    await controller.initialize();

    // 2. Ambil 3 foto
    final tempDir = await getTemporaryDirectory();
    final List<File> imageFiles = [];

    for (int i = 0; i < 3; i++) {
      final path = '${tempDir.path}/image_$i.jpg';
      await controller.takePicture().then((file) => file.saveTo(path));
      imageFiles.add(File(path));
      await Future.delayed(const Duration(milliseconds: 500)); // jeda singkat
    }

    await controller.dispose();

    // 3. Upload ke Supabase
    final List<String> urls = [];

    for (int i = 0; i < imageFiles.length; i++) {
      final file = imageFiles[i];
      final filePath = '$folderPath/photo_$i.jpg';
      final fileBytes = await file.readAsBytes();

      await supabase.storage.from(bucket).uploadBinary(filePath, fileBytes);
      final publicUrl = supabase.storage.from(bucket).getPublicUrl(filePath);
      urls.add(publicUrl);
    }

    return urls; // Kembalikan list URL public
  }
}
