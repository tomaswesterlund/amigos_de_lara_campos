import 'package:flutter/material.dart';

import 'shared/lara_audio.dart';
import 'shared/lara_theme.dart';

class ConcertScreen extends StatefulWidget {
  const ConcertScreen({super.key});

  @override
  State<ConcertScreen> createState() => _ConcertScreenState();
}

class _ConcertScreenState extends State<ConcertScreen> {
  @override
  void initState() {
    super.initState();
    LaraAudio.startBgm(LaraBgm.concert);
  }

  @override
  void dispose() {
    LaraAudio.stopBgm();
    super.dispose();
  }

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
              Color(0xFF8A0060),
              Color(0xFFCC0055),
              Color(0xFFFF5CA8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom app bar
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
                        '¡Concierto!',
                        style: TextStyle(
                          fontSize: 24,
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    children: [
                      // Hero card
                      _HeroCard(),
                      const SizedBox(height: 20),
                      // Info cards row
                      Row(
                        children: [
                          Expanded(
                            child: _InfoChip(
                              icon: Icons.calendar_today_rounded,
                              label: 'Fecha',
                              value: '28 de junio\n2025',
                              color: LaraColors.yellow,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoChip(
                              icon: Icons.access_time_rounded,
                              label: 'Hora',
                              value: '5:00 PM',
                              color: LaraColors.mint,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoChip(
                              icon: Icons.location_on_rounded,
                              label: 'Lugar',
                              value: 'Auditorio\nPachuca',
                              color: LaraColors.pink,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoChip(
                              icon: Icons.star_rounded,
                              label: 'Rating',
                              value: '⭐ ¡Para\ntoda la familia!',
                              color: LaraColors.rhenneGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Programme card
                      _ProgrammeCard(),
                      const SizedBox(height: 20),
                      // Buy button
                      _BuyButton(),
                      const SizedBox(height: 16),
                      // Fine print
                      Text(
                        '* Edades 3–12 años. Adultos acompañantes con boleto.',
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
            color: const Color(0xFF8A0060).withValues(alpha: 0.7),
          ),
        ],
      ),
      child: Column(
        children: [
          // Emoji headline
          const Text('🎤🎵✨', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text(
            '¡Lara Campos\nen Pachuca!',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
              shadows: [
                Shadow(
                  offset: Offset(0, 3),
                  blurRadius: 0,
                  color: Color(0xFF8A0060),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: LaraColors.yellow,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 3),
                  blurRadius: 0,
                  color: Color(0xFFB88800),
                ),
              ],
            ),
            child: const Text(
              '¡SOLD OUT en preventa!',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFF7A5000),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'El espectáculo más esperado del año — '
            'Rhenné, Galleta y todos los Amigos se unen '
            'a Lara en un show lleno de magia y canciones.',
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

class _ProgrammeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LaraColors.mint.withValues(alpha: 0.4), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🎶', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Programa del show',
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
                  Text(
                    item.$1,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
    ('Apertura con show de burbujas y confetti', LaraColors.mint),
    ('Canciones: "Rhenné", "Galleta" y "Corazón"', LaraColors.pink),
    ('Meet & Greet con personajes en el escenario', LaraColors.yellow),
    ('Finale especial: lluvia de corazones', LaraColors.corazonRed),
  ];
}

class _BuyButton extends StatefulWidget {
  @override
  State<_BuyButton> createState() => _BuyButtonState();
}

class _BuyButtonState extends State<_BuyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? 5 : 0, 0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [LaraColors.yellow, LaraColors.pink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, _pressed ? 0 : 5),
              blurRadius: 0,
              color: const Color(0xFF8A0060),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 26),
            SizedBox(width: 12),
            Text(
              '¡Compra tus boletos aquí!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(offset: Offset(0, 2), blurRadius: 0, color: Color(0xFF8A0060)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
