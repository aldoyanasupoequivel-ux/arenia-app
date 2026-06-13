import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_theme.dart';
import 'terms_screen.dart';
import 'package:provider/provider.dart';
import '../providers/accessibility_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playWelcomeAudioOnce();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

bool _hasPlayedWelcomeAudio = false;

  Future<void> _playWelcomeAudioOnce() async {
    if (!_hasPlayedWelcomeAudio) {
      _hasPlayedWelcomeAudio = true;
      await _audioPlayer.play(AssetSource('audio/principal.mp3'));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _floatController.dispose();
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.navyDark,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // ── Foto de fondo ─────────────────────────────────────────
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/fondo.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                // ── Capa de degradado (Overlay) ───────────────────────────
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.30, 0.58, 1.0],
                        colors: [
                          Color(0x14C4E5F7),
                          Color(0x38C4E5F7),
                          Color(0x85C8E8FA),
                          Color(0xB8CDE8FC),
                        ],
                      ),
                    ),
                  ),
                ),
                // ── Contenido desplazable (Scroll) ────────────────────────
                SafeArea(
                  top: true,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 64, 20, 20),
                    child: Column(
                      children: [
                        _buildLogoCard(),
                        const SizedBox(height: 22),
                        _buildWelcomeSection(),
                        const SizedBox(height: 18),
                        _buildAccessibilityDashboard(),
                        const SizedBox(height: 22),
                        _buildActionButton(
                          title:    'btn1Title'.tr(),
                          subtitle: 'btn1Sub'.tr(),
                          icon:     Icons.travel_explore_rounded,
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [AppColors.navy, AppColors.navyMid],
                          ),
                          shadowColor: AppColors.navy.withOpacity(0.38),
                          onTap: () {
                            _audioPlayer.stop();
                            Navigator.pushNamed(context, '/catalog');
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          title:    'btn2Title'.tr(),
                          subtitle: 'btn2Sub'.tr(),
                          icon:     Icons.photo_camera_rounded,
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [AppColors.cyanDark, AppColors.cyan],
                          ),
                          shadowColor: AppColors.cyan.withOpacity(0.38),
                          onTap: () {
                            _audioPlayer.stop();
                            Navigator.pushNamed(context, '/camera');
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          title:    'btn3Title'.tr(),
                          subtitle: 'btn3Sub'.tr(),
                          icon:     Icons.nature_people_rounded,
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [AppColors.textGray, AppColors.textNavy],
                          ),
                          shadowColor: AppColors.textNavy.withOpacity(0.38),
                          onTap: () {
                            _audioPlayer.stop();
                            Navigator.pushNamed(context, '/about');
                          },
                        ),
                        const SizedBox(height: 18),
                        _buildInfoCard(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  // ── Tarjeta de Logotipo Flotante ───────────────────────────────────────────
  Widget _buildLogoCard() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: Container(
        width: 170,
        height: 170,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withOpacity(0.20),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.navy.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/humedal_logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // ── Título de Bienvenida ───────────────────────────────────────────────────
  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Text(
          'welcomePre'.tr().toUpperCase(),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textNavy,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'welcomeTitle'.tr().toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.textNavy,
            letterSpacing: 0.4,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        const Icon(Icons.eco_rounded, color: AppColors.cyan, size: 24),
      ],
    );
  }

  // ── Panel de Accesibilidad (Idioma, Texto, Audio) ──────────────────────────
  Widget _buildAccessibilityDashboard() {
    final accessibility = Provider.of<AccessibilityProvider>(context);
    
    return Column(
      children: [
        const Text(
          'Accesibilidad',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textNavy,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Idioma
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.navy.withOpacity(0.14), width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: context.locale.languageCode,
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textNavy, size: 16),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textNavy),
                  items: const [
                    DropdownMenuItem(value: 'es', child: Text('ES')),
                    DropdownMenuItem(value: 'qu', child: Text('QU')),
                    DropdownMenuItem(value: 'en', child: Text('EN')),
                    DropdownMenuItem(value: 'pt', child: Text('PT')),
                    DropdownMenuItem(value: 'fr', child: Text('FR')),
                  ],
                  onChanged: (v) {
                    if (v != null) context.setLocale(Locale(v));
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            
            // Texto Grande
            GestureDetector(
              onTap: accessibility.toggleTextSize,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: accessibility.isLargeText ? AppColors.cyan : Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.navy.withOpacity(0.14), width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.text_increase_rounded, size: 18, color: accessibility.isLargeText ? Colors.white : AppColors.textNavy),
                    const SizedBox(width: 4),
                    Text('Aa', style: TextStyle(fontWeight: FontWeight.bold, color: accessibility.isLargeText ? Colors.white : AppColors.textNavy)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            
            // Audio
            GestureDetector(
              onTap: accessibility.toggleAudio,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: accessibility.isAudioEnabled ? AppColors.navy : Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.navy.withOpacity(0.14), width: 1.5),
                ),
                child: Icon(
                  accessibility.isAudioEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  size: 20,
                  color: accessibility.isAudioEnabled ? Colors.white : AppColors.textNavy,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Botón de Acción Principal ──────────────────────────────────────────────
  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Círculo del icono
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            // Textos (Título y subtítulo)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.80),
                    ),
                  ),
                ],
              ),
            ),
            // Círculo con flecha indicadora
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tarjeta de Información / Conservación ──────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.eco_rounded, color: AppColors.cyan, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'infoTitle'.tr(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'infoText'.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Pie de Página (Footer) ─────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: AppColors.navyDark,
      padding: EdgeInsets.only(
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
        left: 16,
        right: 16,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_rounded, color: Colors.white60, size: 16),
              const SizedBox(width: 6),
              Text(
                'footer'.tr(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              _audioPlayer.stop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsScreen()),
              );
            },
            child: Text(
              'terms_link'.tr(),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.cyan,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.cyan,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
