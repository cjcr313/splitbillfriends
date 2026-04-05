import 'package:flutter/material.dart';
import 'dart:math';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideTop;
  late Animation<Offset> _slideBottom;
  late Animation<double> _fade;
  late Animation<double> _flash;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    
    _slideTop = Tween<Offset>(begin: Offset.zero, end: const Offset(-0.05, -0.1)).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic))
    );
    _slideBottom = Tween<Offset>(begin: Offset.zero, end: const Offset(0.05, 0.1)).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic))
    );
    _fade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeOut))
    );
    _flash = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.elasticOut))
    );

    // Arrancar la espada samurai después de 1 segundo
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _controller.forward().then((_) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 800),
              pageBuilder: (_, __, ___) => const HomeScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String text = "KUNPAPP";
    const TextStyle textStyle = TextStyle(
      fontSize: 52,
      fontWeight: FontWeight.w900,
      letterSpacing: 8.0,
      color: Colors.white,
      shadows: [
        Shadow(color: Colors.cyanAccent, blurRadius: 20)
      ]
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A1128), // Azul Marino oscuro
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fade.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Mitad Superior
                  SlideTransition(
                    position: _slideTop,
                    child: ClipPath(
                      clipper: DiagonalClipper(isTopHalf: true),
                      child: const Text(text, style: textStyle),
                    ),
                  ),

                  // Mitad Inferior
                  SlideTransition(
                    position: _slideBottom,
                    child: ClipPath(
                      clipper: DiagonalClipper(isTopHalf: false),
                      child: const Text(text, style: textStyle),
                    ),
                  ),

                  // Relámpago de la Espada
                  if (_controller.value > 0.0 && _controller.value < 0.6)
                    Transform.rotate(
                      angle: -0.15, // Angulo de corte coincidente con el clipper
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8 * _flash.value,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: Colors.cyanAccent,
                          boxShadow: [
                            BoxShadow(color: Colors.cyan.withValues(alpha: 0.8), blurRadius: 10, spreadRadius: 3),
                            const BoxShadow(color: Colors.white, blurRadius: 20, spreadRadius: 5),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class DiagonalClipper extends CustomClipper<Path> {
  final bool isTopHalf;

  DiagonalClipper({required this.isTopHalf});

  @override
  Path getClip(Size size) {
    Path path = Path();
    
    // Corte sutil de izquierda (abajo) a derecha (arriba)
    double cutStart = size.height * 0.70;
    double cutEnd = size.height * 0.30;

    if (isTopHalf) {
      path.lineTo(0, cutStart);
      path.lineTo(size.width, cutEnd);
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
      path.close();
    } else {
      path.moveTo(0, cutStart);
      path.lineTo(size.width, cutEnd);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
