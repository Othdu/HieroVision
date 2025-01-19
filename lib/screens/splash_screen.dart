import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/hieroglyphic_bloc.dart';
import '../main.dart';
import 'home_screen.dart';

// Egyptian theme colors from home screen
const egyptianGold = Color(0xFFD4AF37);
const pharaohBlue = Color(0xFF0F1E4E);
const deepGold = Color(0xFFC19B3C);
const papyrusBeige = Color(0xFFF7E7CE);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _rotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.1),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          final myAppState = context.findAncestorStateOfType<MyAppState>();
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => BlocProvider(
                create: (context) => HieroglyphicBloc(),
                child: FadeTransition(
                  opacity: animation,
                  child: HomeScreen(
                    onLocaleChange: myAppState?.setLocale ?? (_) {},
                  ),
                ),
              ),
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: papyrusBeige,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/grunge-background.jpg'),
            fit: BoxFit.cover,
            opacity: 0.08,
            colorFilter: ColorFilter.mode(
              pharaohBlue.withOpacity(0.1),
              BlendMode.multiply,
            ),
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Transform.rotate(
                  angle: _rotateAnimation.value,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    egyptianGold.withOpacity(0.15),
                                    deepGold.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: egyptianGold.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: egyptianGold.withOpacity(0.2),
                                    blurRadius: 12,
                                    spreadRadius: _pulseAnimation.value * 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.translate_rounded,
                                size: 48,
                                color: egyptianGold.withOpacity(0.9),
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(0, _slideAnimation.value * -0.5),
                            child: Column(
                              children: [
                                const SizedBox(height: 32),
                                Text(
                                  'HieroVision',
                                  style: GoogleFonts.cinzel(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: pharaohBlue,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: egyptianGold.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Ancient Wisdom Unveiled',
                                    style: GoogleFonts.crimsonText(
                                      fontSize: 16,
                                      color: pharaohBlue.withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),
                          Transform.scale(
                            scale: _pulseAnimation.value,
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(egyptianGold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 