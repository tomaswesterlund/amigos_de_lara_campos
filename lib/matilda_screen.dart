import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'shared/lara_theme.dart';

const _trailerUrl = 'https://www.youtube.com/watch?v=LkfCmSLD7CQ';

class MatildaScreen extends StatelessWidget {
  const MatildaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2D0057),
              Color(0xFF6A0DAD),
              Color(0xFF9B59B6),
              Color(0xFF4A0080),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const Expanded(
                      child: Text(
                        '¡Matilda El Musical!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20, 16, 20,
                    32 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    children: [
                      _HeroCard(),
                      const SizedBox(height: 20),
                      const _TrailerButton(),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoChip(
                              icon: Icons.theater_comedy_rounded,
                              label: 'Género',
                              value: 'Musical\nfamiliar',
                              color: LaraColors.mint,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoChip(
                              icon: Icons.star_rounded,
                              label: 'Clasificación',
                              value: '¡Para toda\nla familia!',
                              color: LaraColors.yellow,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoChip(
                              icon: Icons.music_note_rounded,
                              label: 'Canciones',
                              value: '+20 temas\nen vivo',
                              color: LaraColors.pink,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoChip(
                              icon: Icons.location_on_rounded,
                              label: 'Lugar',
                              value: 'México',
                              color: LaraColors.rhenneGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _HighlightsCard(),
                      const SizedBox(height: 20),
                      const _TrailerButton(),
                      const SizedBox(height: 16),
                      Text(
                        '* Pide a un adulto que te ayude a ver el tráiler.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.65),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 6),
            blurRadius: 0,
            color: const Color(0xFF4A0080).withValues(alpha: 0.7),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🎭✨🎶', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text(
            'Matilda El Musical\nllega a México',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
              shadows: [
                Shadow(
                  offset: Offset(0, 3),
                  blurRadius: 0,
                  color: Color(0xFF4A0080),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: LaraColors.magenta,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 3),
                  blurRadius: 0,
                  color: Color(0xFF6A0DAD),
                ),
              ],
            ),
            child: const Text(
              '¡El show del año!',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'La historia de una niña extraordinaria con poderes '
            'mágicos llega al escenario con canciones increíbles, '
            'escenografía espectacular y mucha magia.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 0,
            color: color.withValues(alpha: 0.4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: LaraColors.mint.withValues(alpha: 0.4), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🌟', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                '¿Qué vas a ver?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final item in _items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.$2,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.$1,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static const _items = [
    ('Matilda y sus poderes mágicos en escena', LaraColors.mint),
    ('Canciones pegajosas para toda la familia', LaraColors.pink),
    ('Escenografía y vestuario espectacular', LaraColors.yellow),
    ('Un final lleno de sorpresas y magia', LaraColors.corazonRed),
  ];
}

class _TrailerButton extends StatefulWidget {
  const _TrailerButton();

  @override
  State<_TrailerButton> createState() => _TrailerButtonState();
}

class _TrailerButtonState extends State<_TrailerButton> {
  bool _pressed = false;

  Future<void> _launch() async {
    final uri = Uri.parse(_trailerUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _launch();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? 5 : 0, 0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [LaraColors.magenta, LaraColors.pink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, _pressed ? 0 : 5),
              blurRadius: 0,
              color: const Color(0xFF4A0080),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Text(
              '¡Ver el tráiler en YouTube!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 0,
                      color: Color(0xFF4A0080)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
