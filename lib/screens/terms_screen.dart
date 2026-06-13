import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_theme.dart';

import 'package:provider/provider.dart';
import '../providers/accessibility_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class TermsScreen extends StatefulWidget {
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const TermsScreen({super.key, this.onAccept, this.onReject});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> with WidgetsBindingObserver {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

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
      await _audioPlayer.play(AssetSource('audio/politicas_$lang.mp3'));
    } catch (e) {
      await _audioPlayer.play(AssetSource('audio/politicas_es.mp3'));
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
    final isViewOnly = widget.onAccept == null;

    final items = [
      _ComplianceItem(
        icon: Icons.person_off_rounded,
        color: const Color(0xFF2563EB),
        title: 'terms_c1_title'.tr(),
        body: 'terms_c1_body'.tr(),
      ),
      _ComplianceItem(
        icon: Icons.lock_outline_rounded,
        color: const Color(0xFF0891B2),
        title: 'terms_c2_title'.tr(),
        body: 'terms_c2_body'.tr(),
      ),
      _ComplianceItem(
        icon: Icons.smart_toy_outlined,
        color: const Color(0xFF7C3AED),
        title: 'terms_c3_title'.tr(),
        body: 'terms_c3_body'.tr(),
      ),
      _ComplianceItem(
        icon: Icons.folder_open_rounded,
        color: const Color(0xFF059669),
        title: 'terms_c4_title'.tr(),
        body: 'terms_c4_body'.tr(),
      ),
      _ComplianceItem(
        icon: Icons.shield_rounded,
        color: const Color(0xFFDC2626),
        title: 'terms_c5_title'.tr(),
        body: 'terms_c5_body'.tr(),
      ),
      _ComplianceItem(
        icon: Icons.camera_alt_outlined,
        color: const Color(0xFFD97706),
        title: 'terms_c6_title'.tr(),
        body: 'terms_c6_body'.tr(),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FB),
      body: Column(
        children: [
          _buildHeader(context, isViewOnly),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta de introducción
                  _buildIntroCard(),
                  const SizedBox(height: 18),
                  // Elementos de cumplimiento normativo
                  ...items.map((item) => _buildComplianceCard(item)),
                  // Nota a pie de página
                  const SizedBox(height: 6),
                  _buildFooterNote(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          if (!isViewOnly) _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isViewOnly) {
    final accessibility = Provider.of<AccessibilityProvider>(context);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navyDark, AppColors.navy],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          if (isViewOnly)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          if (isViewOnly) const SizedBox(width: 12),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_rounded,
                color: AppColors.cyan, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'terms_title'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'terms_subtitle'.tr(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white60,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (accessibility.isAudioEnabled)
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded, size: 28, color: Colors.white),
              onPressed: () {
                if (_isPlaying) {
                  _audioPlayer.pause();
                } else {
                  _playAudio();
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A5F), AppColors.navy],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
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
                  'terms_intro_title'.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'terms_intro_body'.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceCard(_ComplianceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF22C55E), size: 20),
        ],
      ),
    );
  }

  Widget _buildFooterNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF22C55E).withOpacity(0.30), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded,
              color: Color(0xFF22C55E), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'terms_footer_note'.tr(),
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF166534),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: widget.onReject,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.navy.withOpacity(0.15), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    'terms_reject'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textNavy,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: widget.onAccept,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.navy, AppColors.navyMid],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'terms_accept'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceItem {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _ComplianceItem(
      {required this.icon,
      required this.color,
      required this.title,
      required this.body});
}
