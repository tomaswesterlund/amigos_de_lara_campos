import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'shared/lara_button.dart';
import 'shared/lara_theme.dart';

// TODO: Replace with the actual Matilda El Musical trailer video ID before shipping.
const _matildaVideoId = 'K18cpp_-gP8';

class MatildaScreen extends StatelessWidget {
  const MatildaScreen({super.key});

  Future<void> _openTrailer() async {
    final url = Uri.parse('https://youtu.be/$_matildaVideoId');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎭 Matilda El Musical'),
        backgroundColor: const Color(0xFF6A0DAD),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: LaraGradients.party),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '🎭 ¡Matilda El Musical llega a México!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '¡Un espectáculo lleno de magia, canciones y aventura!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Decorative frame with play button
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6A0DAD), Color(0xFF9B59B6)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: LaraColors.magenta, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(0, 6),
                        blurRadius: 0,
                        color: Color(0xFF4A0080),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: const Color(0xFF1A0030),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_rounded,
                              color: Colors.white,
                              size: 72,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Tráiler en YouTube',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                LaraButton(
                  label: 'Ver tráiler en YouTube',
                  icon: Icons.play_arrow_rounded,
                  color: const Color(0xFF6A0DAD),
                  shadowColor: const Color(0xFF4A0080),
                  onPressed: _openTrailer,
                  fullWidth: true,
                ),

                const SizedBox(height: 16),

                // Sparkle decoration row
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('✨', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '¡Busca las entradas con un adulto!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('✨', style: TextStyle(fontSize: 22)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
