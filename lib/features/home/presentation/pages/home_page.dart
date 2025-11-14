/// Home page of the application
/// 
/// First page displayed when launching the application.
library;

import 'package:flutter/material.dart';
import 'dart:io';

/// Home page
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      const Color(0xFF7B1FA2), // Deep Purple
                      const Color(0xFFC62828), // Crimson Red
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // Logo
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _buildLogo(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // App name in Japanese
                    const Text(
                      '音ランク',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Music, Ranked',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 10),
                
                // Welcome section
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Organize, rank, and enjoy your music collection',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Feature cards
                _buildFeatureCard(
                  context,
                  icon: Icons.library_music,
                  title: 'Music Player',
                  description: 'Play and organize your local music library',
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4A148C).withOpacity(0.95), // Deep purple
                      const Color(0xFF6A1B9A).withOpacity(0.95),
                    ],
                  ),
                  route: '/music-player',
                ),
                const SizedBox(height: 16),
                
                _buildFeatureCard(
                  context,
                  icon: Icons.download_rounded,
                  title: 'YouTube Downloader',
                  description: 'Download music from YouTube',
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF7B1FA2).withOpacity(0.95), // Purple
                      const Color(0xFF9C27B0).withOpacity(0.95),
                    ],
                  ),
                  route: '/youtube-downloader',
                ),
                const SizedBox(height: 16),
                
                _buildFeatureCard(
                  context,
                  icon: Icons.audiotrack,
                  title: 'Audio Editor',
                  description: 'Edit and trim your audio files',
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF9C27B0).withOpacity(0.95), // Purple-red transition
                      const Color(0xFFC2185B).withOpacity(0.95),
                    ],
                  ),
                  route: '/audio-editor',
                ),
                const SizedBox(height: 16),
                
                _buildFeatureCard(
                  context,
                  icon: Icons.note_alt_outlined,
                  title: 'Notes',
                  description: 'Quick notes and reminders',
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFC2185B).withOpacity(0.95), // Pink-red
                      const Color(0xFFD32F2F).withOpacity(0.95),
                    ],
                  ),
                  route: '/notes',
                ),
                const SizedBox(height: 16),
                
                _buildFeatureCard(
                  context,
                  icon: Icons.timer,
                  title: 'Tabata Timer',
                  description: 'Workout and fitness timer',
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFD32F2F).withOpacity(0.95), // Red
                      const Color(0xFFE64A19).withOpacity(0.95),
                    ],
                  ),
                  route: '/tabata-timer',
                ),
                
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    // Try to load the logo from assets, fallback to icon
    try {
      if (File('assets/images/otorank_logo.png').existsSync()) {
        return Image.asset(
          'assets/images/otorank_logo.png',
          fit: BoxFit.cover,
        );
      }
    } catch (e) {
      // Fallback to asset
    }
    
    // Try asset first
    return Image.asset(
      'assets/images/otorank_logo.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Final fallback to icon
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF7B1FA2),
                const Color(0xFFC62828),
              ],
            ),
          ),
          child: const Icon(
            Icons.music_note,
            size: 80,
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Gradient gradient,
    required String route,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
