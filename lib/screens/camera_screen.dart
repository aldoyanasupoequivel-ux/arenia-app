// lib/screens/camera_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../data/species_data.dart';
import '../models/identification_result.dart';
import '../services/species_identifier_service.dart';
import 'qr_scanner_screen.dart';
import 'package:provider/provider.dart';
import '../providers/accessibility_provider.dart';
import 'package:audioplayers/audioplayers.dart';

// ── Estados de Escaneo ───────────────────────────────────────────────────────
enum _ScanState { idle, analyzing, result, error }

/// Pantalla encargada de la detección de especies por Inteligencia Artificial (IA).
/// Utiliza la cámara del dispositivo o permite subir una foto de la galería
/// para enviarla al servicio de clasificación de TensorFlow Lite.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();

  _ScanState _state = _ScanState.idle;
  File? _imageFile;
  IdentificationResult? _result;
  String _errorMessage = '';

  // Animación de la línea del escáner
  late AnimationController _scanAnimController;
  late Animation<double> _scanLineAnim;

  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _scanLineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanAnimController, curve: Curves.easeInOut),
    );

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

    // Inicializar el modelo TFLite
    SpeciesIdentifierService.initializeModel();
  }

  Future<void> _playAudio() async {
    String lang = context.locale.languageCode.toLowerCase();

    try {
      await _audioPlayer.play(AssetSource('audio/escaner_$lang.mp3'));
    } catch (e) {
      await _audioPlayer.play(AssetSource('audio/escaner_es.mp3'));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanAnimController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    SpeciesIdentifierService.disposeModel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _audioPlayer.pause();
    }
  }

  // ── Seleccionar imagen de la cámara o galería ────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null) return; // el usuario canceló

      setState(() {
        _imageFile = File(picked.path);
        _state = _ScanState.analyzing;
        _result = null;
        _errorMessage = '';
      });

      // Iniciar animación del escáner
      _scanAnimController.repeat(reverse: true);

      // Enviar imagen a Gemini (IA)
      final result = await SpeciesIdentifierService.identify(_imageFile!);

      _scanAnimController.stop();

      if (!mounted) return;
      setState(() {
        _result = result;
        _state = _ScanState.result;
      });
    } on SocketException {
      _scanAnimController.stop();
      if (!mounted) return;
      setState(() {
        _state = _ScanState.error;
        _errorMessage = 'scan_no_internet'.tr();
      });
    } catch (e) {
      _scanAnimController.stop();
      if (!mounted) return;
      setState(() {
        _state = _ScanState.error;
        _errorMessage = '${'scan_error'.tr()}: ${e.toString()}';
      });
    }
  }

  void _reset() {
    setState(() {
      _state = _ScanState.idle;
      _imageFile = null;
      _result = null;
      _errorMessage = '';
    });
  }

  // ── Navegar a la pantalla del artículo ───────────────────────────────────────
  void _goToArticle(Species species) {
    Navigator.pushNamed(
      context,
      '/article',
      arguments: {
        'fromCatalog': false,
        'speciesId': species.id,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: Stack(
              children: [
                // ── Foto de fondo ───────────────────────────────────────────
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/fondo.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                // ── Capa de degradado (Overlay) ─────────────────────────────
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.25, 0.55, 1.0],
                        colors: [
                          Color(0x22C4E5F7),
                          Color(0x44C4E5F7),
                          Color(0x88C8E8FA),
                          Color(0xCCCDE8FC),
                        ],
                      ),
                    ),
                  ),
                ),
                // ── Contenido ───────────────────────────────────────────────
                SafeArea(
                  top: false,
                  child: _buildBody(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Barra Superior (App Bar) ─────────────────────────────────────────────────
  Widget _buildAppBar() {
    final accessibility = Provider.of<AccessibilityProvider>(context);
    return Container(
      width: double.infinity,
      color: AppColors.navyDark,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 10,
        left: 4,
        right: 16,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'scan_title'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('AI',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
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

  // ── Enrutador del contenido principal ────────────────────────────────────────
  Widget _buildBody() {
    switch (_state) {
      case _ScanState.idle:
        return _buildIdleState();
      case _ScanState.analyzing:
        return _buildAnalyzingState();
      case _ScanState.result:
        return _buildResultState();
      case _ScanState.error:
        return _buildErrorState();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // ESTADO INACTIVO (IDLE)
  // ══════════════════════════════════════════════════════════════════════════════
  Widget _buildIdleState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono de escáner
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withOpacity(0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.document_scanner_rounded,
                color: AppColors.cyan, size: 52),
          ),
          const SizedBox(height: 28),
          Text(
            'scan_instruction'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textNavy,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),

          // Botón de cámara
          _buildActionButton(
            icon: Icons.camera_alt_rounded,
            label: 'scan_take_photo'.tr(),
            color: AppColors.cyan,
            onTap: () => _pickImage(ImageSource.camera),
          ),
          const SizedBox(height: 14),

          // Botón de galería
          _buildActionButton(
            icon: Icons.photo_library_rounded,
            label: 'scan_from_gallery'.tr(),
            color: AppColors.navy,
            borderColor: AppColors.cyan.withValues(alpha: 0.40),
            onTap: () => _pickImage(ImageSource.gallery),
          ),

        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // ESTADO DE ANÁLISIS (ANALYZING)
  // ══════════════════════════════════════════════════════════════════════════════
  Widget _buildAnalyzingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Vista previa de la imagen con capa de escáner
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: double.infinity,
              height: 280,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen del usuario
                  if (_imageFile != null)
                    Image.file(_imageFile!, fit: BoxFit.cover),

                  // Capa oscura semi-transparente
                  Container(
                    color: Colors.black.withValues(alpha: 0.30),
                  ),

                  // Línea de escáner animada
                  AnimatedBuilder(
                    animation: _scanLineAnim,
                    builder: (context, child) {
                      return Positioned(
                        top: _scanLineAnim.value * 270,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.greenAccent.withValues(alpha: 0.0),
                                Colors.greenAccent,
                                Colors.greenAccent.withValues(alpha: 0.0),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.greenAccent.withValues(alpha: 0.60),
                                blurRadius: 12,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Esquinas marcadoras
                  _buildCornerBrackets(),

                  // Borde animado (Pulse)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.greenAccent.withValues(alpha: 0.50),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Indicador de carga y texto
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: Colors.greenAccent,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'scan_analyzing'.tr(),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'scan_analyzing_hint'.tr(),
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerBrackets() {
    const color = Colors.greenAccent;
    const size = 24.0;
    const thickness = 3.0;

    Widget corner({
      bool top = false,
      bool left = false,
    }) {
      return Positioned(
        top: top ? 8 : null,
        bottom: top ? null : 8,
        left: left ? 8 : null,
        right: left ? null : 8,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _CornerPainter(
              color: color,
              thickness: thickness,
              topLeft: top && left,
              topRight: top && !left,
              bottomLeft: !top && left,
              bottomRight: !top && !left,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        corner(top: true, left: true),
        corner(top: true, left: false),
        corner(top: false, left: true),
        corner(top: false, left: false),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // ESTADO DE RESULTADO (RESULT)
  // ══════════════════════════════════════════════════════════════════════════════
  Widget _buildResultState() {
    if (_result == null) return _buildErrorState();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          // Vista previa de la imagen analizada
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: double.infinity,
              height: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_imageFile != null)
                    Image.file(_imageFile!, fit: BoxFit.cover),
                  // Degradado inferior
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.70),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Insignia de estado (Status badge)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _result!.isInDatabase
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _result!.isInDatabase
                                ? Icons.check_circle_rounded
                                : Icons.help_outline_rounded,
                            color: Colors.black87,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _result!.isInDatabase
                                ? 'scan_species_found'.tr()
                                : 'scan_not_found'.tr(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tarjeta de resultados
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _result!.isInDatabase
                    ? Colors.greenAccent.withValues(alpha: 0.30)
                    : Colors.orangeAccent.withValues(alpha: 0.30),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre de la especie
                if (_result!.isInDatabase) ...[
                  Text(
                    _result!.species!.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _result!.species!.scientificName,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textGray,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Insignia de categoría (Emoji)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _result!.species!.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cyan,
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    _result!.suggestedName.isNotEmpty
                        ? _result!.suggestedName
                        : 'scan_unknown'.tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textNavy,
                    ),
                  ),
                  if (_result!.scientificName != null &&
                      _result!.scientificName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _result!.scientificName!,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: Colors.orangeAccent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'scan_not_in_db'.tr(),
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textGray,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Barra de confianza (probabilidad)
                _buildConfidenceBar(_result!.confidence),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Botones de acción
          if (_result!.isInDatabase)
            _buildActionButton(
              icon: Icons.article_rounded,
              label: 'scan_view_article'.tr(),
              color: AppColors.cyan,
              onTap: () => _goToArticle(_result!.species!),
            ),

          const SizedBox(height: 12),

          _buildActionButton(
            icon: Icons.refresh_rounded,
            label: 'scan_try_again'.tr(),
            color: AppColors.navy,
            borderColor: AppColors.cyan.withValues(alpha: 0.40),
            onTap: _reset,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildConfidenceBar(double confidence) {
    final percentage = (confidence * 100).toInt();
    Color barColor;
    if (confidence >= 0.75) {
      barColor = Colors.greenAccent;
    } else if (confidence >= 0.5) {
      barColor = Colors.orangeAccent;
    } else {
      barColor = Colors.redAccent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'scan_confidence'.tr(),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGray,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 15,
                color: barColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                color: AppColors.navy.withValues(alpha: 0.10),
              ),
              FractionallySizedBox(
                widthFactor: confidence.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: barColor.withValues(alpha: 0.50),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // ESTADO DE ERROR (ERROR)
  // ══════════════════════════════════════════════════════════════════════════════
  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            'scan_error'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textNavy,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          _buildActionButton(
            icon: Icons.refresh_rounded,
            label: 'scan_try_again'.tr(),
            color: AppColors.cyan,
            onTap: _reset,
          ),
        ],
      ),
    );
  }
}

// ─── Pintor de esquinas para el área del escáner ────────────────────────────
class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  _CornerPainter({
    required this.color,
    required this.thickness,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (topLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (topRight) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (bottomLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else if (bottomRight) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
