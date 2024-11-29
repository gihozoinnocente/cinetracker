import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoCacheService {
  static final VideoCacheService _instance = VideoCacheService._internal();
  factory VideoCacheService() => _instance;
  VideoCacheService._internal();

  final Dio _dio = Dio();
  
  Future<String> get _cacheDir async {
    final directory = await getApplicationDocumentsDirectory();
    final cacheDir = '${directory.path}/video_cache';
    await Directory(cacheDir).create(recursive: true);
    return cacheDir;
  }

  Future<String?> getCachedVideoPath(String videoId) async {
    final dir = await _cacheDir;
    final filePath = '$dir/$videoId.mp4';
    if (await File(filePath).exists()) {
      return filePath;
    }
    return null;
  }

  Future<String?> cacheVideo(String videoId, String url) async {
    try {
      final dir = await _cacheDir;
      final filePath = '$dir/$videoId.mp4';
      final file = File(filePath);

      if (await file.exists()) {
        return filePath;
      }

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = "${(received / total * 100).toStringAsFixed(0)}%";
            print('Download progress: $progress');
          }
        },
      );

      // Generate thumbnail
      await generateThumbnail(videoId, filePath);

      return filePath;
    } catch (e) {
      print('Error caching video: $e');
      return null;
    }
  }

  Future<String?> generateThumbnail(String videoId, String videoPath) async {
    try {
      final dir = await _cacheDir;
      final thumbnailPath = '$dir/$videoId.jpg';

      if (await File(thumbnailPath).exists()) {
        return thumbnailPath;
      }

      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: thumbnailPath,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
      );

      return thumbnail;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      final dir = Directory(await _cacheDir);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}