import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_theme.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../providers/accessibility_provider.dart';
/// Pantalla que muestra la historia, biodiversidad y turismo ecológico del humedal.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with WidgetsBindingObserver {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Auto-play si está habilitado en accesibilidad
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accessibility = Provider.of<AccessibilityProvider>(context, listen: false);
      if (accessibility.isAudioEnabled) {
        _playAudio();
      }
    });
  }

  Future<void> _playAudio() async {
    String lang = context.locale.languageCode.toLowerCase();

    
    try {
      await _audioPlayer.play(AssetSource('audio/sobre_$lang.mp3'));
    } catch (e) {
      // Si no encuentra el archivo por alguna razón, intenta español
      await _audioPlayer.play(AssetSource('audio/sobre_es.mp3'));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _audioPlayer.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accessibility = Provider.of<AccessibilityProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8), // Fondo claro similar a la infografía
      appBar: AppBar(
        title: Text(
          'btn3Title'.tr(),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: AppColors.navyDark,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (accessibility.isAudioEnabled)
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded, size: 28),
              onPressed: () {
                if (_isPlaying) {
                  _audioPlayer.pause();
                } else {
                  _playAudio();
                }
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título Principal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Text(
                'about_title'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navyDark,
                  height: 1.2,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Sección: Historia
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'about_history_title'.tr(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navyDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'about_history_p1'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textNavy,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'about_history_p2'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textNavy,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  
                  const SizedBox(height: 32),
                  _buildDivider(),
                  const SizedBox(height: 32),

                  // Sección: Biodiversidad
                  Text(
                    'about_biodiv_title'.tr(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navyDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'about_biodiv_p1'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textNavy,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 32),
                  _buildDivider(),
                  const SizedBox(height: 32),

                  // Sección: Turismo Ecológico
                  Text(
                    'about_tourism_title'.tr(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navyDark,
                      height: 1.1,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'about_tourism_p1'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textNavy,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Línea divisoria elegante
  Widget _buildDivider() {
    return Container(
      height: 2,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.navyDark.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
