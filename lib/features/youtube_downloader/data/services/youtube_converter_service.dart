library;

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Service to convert YouTube videos into audio files.
class YouTubeConverterService {
  final _yt = YoutubeExplode();

  /// Downloads and converts a YouTube video to audio.
  /// Returns the saved file path.
  Future<String> downloadYouTubeAsAudio({
    required String youtubeUrl,
    required String format,
    required Function(double) onProgress,
  }) async {
    try {
      final videoId = _extractVideoId(youtubeUrl);
      if (videoId == null) {
        throw Exception('Invalid YouTube URL');
      }

      final video = await _yt.videos.get(videoId);
      final title = _sanitizeFilename(video.title);
      
      final appDir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${appDir.path}/downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final filename = '$title.$format';
      final filepath = '${downloadDir.path}/$filename';
      final outputFile = File(filepath);

      if (await outputFile.exists()) {
        await outputFile.delete();
      }

      // Fetch manifest once
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      
      // Build list of streams to try: audio-only first (prefer), then muxed
      final streamsToTry = <(dynamic streamInfo, String type)>[];
      
      // Add audio-only streams sorted by bitrate (highest first)
      if (manifest.audioOnly.isNotEmpty) {
        final sorted = manifest.audioOnly.toList()..sort((a, b) => b.bitrate.compareTo(a.bitrate));
        for (final stream in sorted) {
          streamsToTry.add((stream, 'audio-only'));
        }
      }
      
      // Add muxed streams sorted by bitrate (highest first)
      if (manifest.muxed.isNotEmpty) {
        final sorted = manifest.muxed.toList()..sort((a, b) => b.bitrate.compareTo(a.bitrate));
        for (final stream in sorted) {
          streamsToTry.add((stream, 'muxed'));
        }
      }
      
      if (streamsToTry.isEmpty) {
        throw Exception('No audio streams available for this video');
      }

      // Try each stream until one works
      String? lastError;
      for (final (streamInfo, streamType) in streamsToTry) {
        try {
          print('[YouTubeConverter] Attempting $streamType stream...');
          
          late final Stream<List<int>> audioStream;
          late final int totalBytes;
          
          // Safely try to get the stream
          try {
            audioStream = _yt.videos.streamsClient.get(streamInfo);
            totalBytes = streamInfo.size.totalBytes;
            if (totalBytes <= 0) {
              print('[YouTubeConverter] Stream has invalid size: $totalBytes, skipping...');
              continue;
            }
          } catch (streamError) {
            print('[YouTubeConverter] Stream info error ($streamType): $streamError');
            lastError = streamError.toString();
            continue;
          }

          // Try to download from this stream
          final output = outputFile.openWrite(mode: FileMode.writeOnly);
          var downloadedBytes = 0;

          try {
            await for (final chunk in audioStream) {
              downloadedBytes += chunk.length;
              if (totalBytes > 0) {
                onProgress(downloadedBytes / totalBytes);
              }
              output.add(chunk);
            }
            await output.flush();
            await output.close();
            print('[YouTubeConverter] ✓ Successfully downloaded using $streamType stream');
            return filepath;
          } catch (downloadError) {
            await output.close();
            print('[YouTubeConverter] Download error ($streamType): $downloadError');
            lastError = downloadError.toString();
            // Delete partial file and try next stream
            if (await outputFile.exists()) {
              await outputFile.delete();
            }
            continue;
          }
        } catch (e) {
          print('[YouTubeConverter] Stream attempt failed: $e');
          lastError = e.toString();
          continue;
        }
      }

      // All streams failed
      throw Exception('All download attempts failed. Last error: $lastError');
    } catch (e, st) {
      final trace = st.toString();
      throw Exception('Download failed: $e\n${trace}');
    }
  }

  /// Retrieves video metadata.
  Future<VideoInfo> getVideoInfo(String youtubeUrl) async {
    try {
      final videoId = _extractVideoId(youtubeUrl);
      if (videoId == null) {
        throw Exception('Invalid YouTube URL');
      }

      final video = await _yt.videos.get(videoId);
      final thumbnailUrl = _resolveThumbnailUrl(video);

      return VideoInfo(
        title: video.title,
        author: video.author,
        duration: video.duration,
        thumbnailUrl: thumbnailUrl,
      );
    } catch (e) {
      throw Exception('Failed to load video info: $e');
    }
  }

  /// Extracts a YouTube video ID from a URL.
  String? _extractVideoId(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      }
      return uri.queryParameters['v'];
    } catch (_) {
      return null;
    }
  }

  /// Sanitizes a filename.
  String _sanitizeFilename(String filename) {
    final sanitized = filename
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return sanitized.length > 100 ? sanitized.substring(0, 100) : sanitized;
  }

  String _resolveThumbnailUrl(Video video) {
    try {
      return video.thumbnails.highResUrl;
    } catch (_) {
      return 'https://img.youtube.com/vi/${video.id.value}/hqdefault.jpg';
    }
  }

  void dispose() {
    _yt.close();
  }
}

/// Video metadata.
class VideoInfo {
  final String title;
  final String author;
  final Duration? duration;
  final String thumbnailUrl;

  VideoInfo({
    required this.title,
    required this.author,
    required this.duration,
    required this.thumbnailUrl,
  });
}
