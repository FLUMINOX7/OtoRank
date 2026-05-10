/// YouTube converter page.
library;

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../data/services/youtube_converter_service.dart';

class YouTubeDownloaderPage extends StatefulWidget {
  const YouTubeDownloaderPage({super.key});

  @override
  State<YouTubeDownloaderPage> createState() => _YouTubeDownloaderPageState();
}

class _YouTubeDownloaderPageState extends State<YouTubeDownloaderPage> {
  final _urlController = TextEditingController();
  final _converterService = YouTubeConverterService();
  
  String _selectedFormat = 'mp3';
  double _downloadProgress = 0.0;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  VideoInfo? _videoInfo;

  @override
  void dispose() {
    _urlController.dispose();
    _converterService.dispose();
    super.dispose();
  }

  Future<void> _fetchVideoInfo() async {
    final url = _urlController.text.trim();
    
    if (url.isEmpty) {
      setState(() => _errorMessage = 'Please enter a YouTube URL');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      _videoInfo = null;
    });

    try {
      final info = await _converterService.getVideoInfo(url);
      setState(() {
        _videoInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadAudio() async {
    if (_videoInfo == null) {
      setState(() => _errorMessage = 'Please load the video info first');
      return;
    }

    final url = _urlController.text.trim();
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      _downloadProgress = 0.0;
    });

    try {
      final filepath = await _converterService.downloadYouTubeAsAudio(
        youtubeUrl: url,
        format: _selectedFormat,
        onProgress: (progress) {
          setState(() => _downloadProgress = progress);
        },
      );

      // Vérifier que le fichier existe
      final file = File(filepath);
      if (await file.exists()) {
        setState(() {
          _successMessage = 'Download successful!\nFile: ${file.path}';
          _isLoading = false;
          _downloadProgress = 0.0;
        });

        // Show a snackbar.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Audio file downloaded successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception('The file could not be created');
      }
    } catch (e) {
      setState(() {
        // If the exception contains a stacktrace, keep only the first 3 lines to avoid flooding the UI
        final msg = e.toString();
        final firstLines = msg.split('\n').take(4).join('\n');
        _errorMessage = 'Download error: $firstLines';
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    setState(() {
      _urlController.clear();
      _videoInfo = null;
      _errorMessage = null;
      _successMessage = null;
      _downloadProgress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Converter'),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.download_for_offline,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'YouTube Converter',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Download the audio from your favorite YouTube videos\nand save it locally as MP3 or M4A.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // URL field
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'YouTube URL',
                hintText: 'https://www.youtube.com/watch?v=...',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabled: !_isLoading,
              ),
              readOnly: _isLoading,
            ),
            const SizedBox(height: 16),

            // Format selection
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFormat,
                    decoration: InputDecoration(
                      labelText: 'Output format',
                      prefixIcon: const Icon(Icons.audio_file),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'mp3', child: Text('MP3')),
                      DropdownMenuItem(value: 'm4a', child: Text('M4A')),
                    ],
                    onChanged: _isLoading ? null : (value) {
                      setState(() => _selectedFormat = value ?? 'mp3');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fetch info button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _fetchVideoInfo,
              icon: const Icon(Icons.info),
              label: const Text('Load video info'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Video info
            if (_videoInfo != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Video info',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _videoInfo!.thumbnailUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _videoInfo!.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Author: ${_videoInfo!.author}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (_videoInfo!.duration != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Duration: ${_formatDuration(_videoInfo!.duration!)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Success message
            if (_successMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Progress bar
            if (_isLoading && _downloadProgress > 0) ...[
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _downloadProgress,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ],

            // Actions
            if (_videoInfo != null && !_isLoading) ...[
              ElevatedButton.icon(
                onPressed: _downloadAudio,
                icon: const Icon(Icons.download),
                label: Text('Download as ${_selectedFormat.toUpperCase()}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _clearForm,
                icon: const Icon(Icons.clear),
                label: const Text('Reset'),
              ),
            ],

            if (_isLoading && _downloadProgress == 0) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading video info...'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

