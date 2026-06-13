import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../providers/accessibility_provider.dart';
import '../data/species_data.dart';
import '../theme/app_theme.dart';

// ─── Función auxiliar para obtener el emoji de la categoría ─────────────────
String _categoryEmoji(String category) {
  switch (category) {
    case 'Aves':        return '🐦';
    case 'Crustáceos':  return '🦀';
    case 'Insectos':    return '🦋';
    case 'Plantas':     return '🌿';
    case 'Peces':       return '🐟';
    case 'Mamíferos':   return '🐾';
    case 'Reptiles':    return '🦎';
    default:            return '🔬';
  }
}

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> with WidgetsBindingObserver {
  bool _isFavorite = false;
  int  _photoIndex = 0;          // página actual del carrusel
  final PageController _pageController = PageController();

  // ── Estado del Audio (Archivos Locales) ───────────────────────────────────
  late AudioPlayer _audioPlayer;
  bool _isPlayingAudio = false;
  bool _hasAttemptedAutoplay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlayingAudio = state == PlayerState.playing);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasAttemptedAutoplay) {
      _hasAttemptedAutoplay = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final String speciesId = args?['speciesId'] ?? speciesDatabase.first.id;
      final species = speciesDatabase.firstWhere(
        (s) => s.id == speciesId,
        orElse: () => speciesDatabase.first,
      );
      
      final accessibility = Provider.of<AccessibilityProvider>(context, listen: false);
      if (accessibility.isAudioEnabled) {
        _playAudio(species);
      }
    }
  }

  Future<void> _playAudio(Species species) async {
    String lang = context.locale.languageCode.toLowerCase();

    try {
      await _audioPlayer.play(AssetSource('audio/${species.id}_$lang.mp3'));
    } catch (e) {
      await _audioPlayer.play(AssetSource('audio/${species.id}_es.mp3'));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _audioPlayer.pause();
    }
  }

  // ── Se ejecuta cuando el usuario presiona "Escuchar descripción" ────────────
  void _toggleAudio(Species species) {
    if (_isPlayingAudio) {
      _audioPlayer.pause();
    } else {
      _playAudio(species);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bool fromCatalog   = args?['fromCatalog']  ?? false;
    final String speciesId   = args?['speciesId']    ?? speciesDatabase.first.id;
    final List<String> speciesList =
        (args?['speciesList'] as List?)?.cast<String>() ?? [speciesId];

    final int currentSpeciesIndex =
        speciesList.indexOf(speciesId).clamp(0, speciesList.length - 1);

    final species = speciesDatabase.firstWhere(
      (s) => s.id == speciesId,
      orElse: () => speciesDatabase.first,
    );

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, species),
          Expanded(
            child: Stack(
              children: [
                // Foto de fondo
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/fondo.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                // Capa de degradado (Overlay)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.25, 0.60, 1.0],
                        colors: [
                          Color(0x22C4E5F7),
                          Color(0x55C4E5F7),
                          Color(0x99C8E8FA),
                          Color(0xCCCDE8FC),
                        ],
                      ),
                    ),
                  ),
                ),
                // Tarjeta desplazable (Scroll)
                SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.navy.withOpacity(0.14),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Carrusel o imagen única ─────────────────
                          _buildImageSection(species),

                          _buildNameRow(species),
                          _buildDescription(species),

                          if (species.habitat.isNotEmpty ||
                              species.diet.isNotEmpty ||
                              species.status.isNotEmpty)
                            _buildInfoCards(species),

                          _buildListenButton(species),

                          if (fromCatalog && speciesList.length > 1)
                            _buildSpeciesNavigation(
                              context,
                              currentSpeciesIndex,
                              speciesList,
                              fromCatalog,
                            ),

                          if (fromCatalog) _buildBackButton(context),

                          const SizedBox(height: 4),
                        ],
                      ),
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

  // ── Encabezado ───────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, Species species) {
    return Container(
      width: double.infinity,
      color: AppColors.navyDark,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 14,
        left: 16,
        right: 16,
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: -4,
            child: Icon(Icons.eco_rounded,
                color: AppColors.cyan.withOpacity(0.35), size: 60),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(species.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    Text(
                      species.typeLabel.isNotEmpty
                          ? species.typeLabel
                          : species.scientificName,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.75),
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Carrusel de Imágenes ───────────────────────────────────────────────────────────
  Widget _buildImageSection(Species species) {
    final photos = species.imageUrls;
    final hasMultiple = photos.length > 1;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SizedBox(
        width: double.infinity,
        height: 220,
        child: GestureDetector(
          onTap: () => _showFullScreenImage(context, species, hasMultiple, photos),
          child: Stack(
            fit: StackFit.expand,
          children: [
            // ── Carrusel (o imagen estática si solo hay 1) ────────
            hasMultiple
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: photos.length,
                    onPageChanged: (i) => setState(() => _photoIndex = i),
                    itemBuilder: (_, i) => _photoWidget(photos[i], species.category),
                  )
                : _photoWidget(
                    photos.isNotEmpty ? photos.first : '',
                    species.category,
                  ),

            // ── Indicador de puntos (solo si hay varias fotos) ─────────────────────
            if (hasMultiple)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(photos.length, (i) {
                    final active = i == _photoIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width:  active ? 18 : 7,
                      height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white
                            : Colors.white.withOpacity(0.50),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                          )
                        ],
                      ),
                    );
                  }),
                ),
              ),

            // ── Botón de favorito ──────────────────────────────────────────────
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => setState(() => _isFavorite = !_isFavorite),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Icon(
                    _isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _isFavorite ? Colors.red : AppColors.navy,
                    size: 20,
                  ),
                ),
              ),
            ),

            // ── Flechas indicadoras de deslizamiento (solo si > 1) ───────────────────
            if (hasMultiple && _photoIndex > 0)
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_left_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            if (hasMultiple && _photoIndex < photos.length - 1)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, Species species, bool hasMultiple, List<String> photos) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.95),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Center(
              child: hasMultiple
                  ? PageView.builder(
                      controller: PageController(initialPage: _photoIndex),
                      itemCount: photos.length,
                      onPageChanged: (i) {
                        setState(() => _photoIndex = i);
                      },
                      itemBuilder: (_, i) => InteractiveViewer(
                        child: _photoWidget(photos[i], species.category, fit: BoxFit.contain),
                      ),
                    )
                  : InteractiveViewer(
                      child: _photoWidget(
                        photos.isNotEmpty ? photos.first : '',
                        species.category,
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  // Widget para foto única con manejadores de carga y error
  Widget _photoWidget(String url, String category, {BoxFit fit = BoxFit.cover}) {
    if (url.isEmpty) {
      return Container(
        color: AppColors.skyLight,
        child: Center(
          child: Text(_categoryEmoji(category),
              style: const TextStyle(fontSize: 64)),
        ),
      );
    }
    Widget errorWidget = Container(
      color: AppColors.skyLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_categoryEmoji(category),
                style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 8),
            Text('image_unavailable'.tr(),
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      ),
    );

    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (_, __, ___) => errorWidget,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            color: AppColors.skyLight,
            child: const Center(
              child: CircularProgressIndicator(
                  color: AppColors.cyan, strokeWidth: 2.5),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        url,
        fit: fit,
        errorBuilder: (_, __, ___) => errorWidget,
      );
    }
  }

  // ── Fila del nombre ─────────────────────────────────────────────────────────────────
  Widget _buildNameRow(Species species) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: AppColors.skyLight, shape: BoxShape.circle),
            child: Center(
              child: Text(_categoryEmoji(species.category),
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('species.${species.id}.name'.tr(),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textNavy)),
                if (species.typeLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.skyLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.cyan.withOpacity(0.4), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flutter_dash,
                            color: AppColors.cyan, size: 14),
                        const SizedBox(width: 4),
                        Text('species.${species.id}.typeLabel'.tr(),
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.cyan)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Descripción ──────────────────────────────────────────────────────────────
  Widget _buildDescription(Species species) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Text('species.${species.id}.description'.tr(),
          textAlign: TextAlign.justify,
          style: const TextStyle(
              fontSize: 13.5, color: AppColors.textNavy, height: 1.6)),
    );
  }

  // ── Tarjetas de información ───────────────────────────────────────────────────────────────
  Widget _buildInfoCards(Species species) {
    final items = <Map<String, dynamic>>[
      if (species.habitat.isNotEmpty)
        {'icon': Icons.location_on_rounded,   'label': 'habitat'.tr(),       'value': 'species.${species.id}.habitat'.tr()},
      if (species.diet.isNotEmpty)
        {'icon': Icons.eco_rounded,            'label': 'diet'.tr(),  'value': 'species.${species.id}.diet'.tr()},
      if (species.status.isNotEmpty)
        {'icon': Icons.event_available_rounded,'label': 'status'.tr(),        'value': 'species.${species.id}.status'.tr()},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
      child: Row(
        children: items.map((item) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Row(
                      children: [
                        Icon(item['icon'] as IconData, color: AppColors.cyan, size: 26),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(item['label'] as String, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textNavy, fontSize: 18)),
                        ),
                      ],
                    ),
                    content: SingleChildScrollView(
                      child: Text(item['value'] as String, style: const TextStyle(color: AppColors.textNavy, height: 1.6, fontSize: 15)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('close'.tr(), style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.skyPale,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.cyan.withOpacity(0.18), width: 1),
              ),
              child: Column(
                children: [
                  Icon(item['icon'] as IconData,
                      color: AppColors.cyan, size: 22),
                  const SizedBox(height: 6),
                  Text(item['label'] as String,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textNavy),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(item['value'] as String,
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textGray,
                          height: 1.4),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── BOTÓN DE ESCUCHAR (Texto a Voz) ──────────────────────────────────────────────
  Widget _buildListenButton(Species species) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GestureDetector(
        onTap: () => _toggleAudio(species),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _isPlayingAudio ? AppColors.cyan : AppColors.navy,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: (_isPlayingAudio ? AppColors.cyan : AppColors.navy)
                    .withOpacity(0.30),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlayingAudio
                      ? Icons.pause_rounded
                      : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isPlayingAudio
                          ? 'pause_desc'.tr()
                          : 'play_desc'.tr(),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30, width: 1.5),
                ),
                child: Icon(
                  _isPlayingAudio
                      ? Icons.stop_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Navegación previa/siguiente de especies ──────────────────────────────────────────────
  Widget _buildSpeciesNavigation(
    BuildContext context,
    int currentIndex,
    List<String> speciesList,
    bool fromCatalog,
  ) {
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex < speciesList.length - 1;
    final dotsCount = speciesList.length.clamp(0, 6);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavArrowButton(
            icon: Icons.chevron_left_rounded,
            enabled: hasPrev,
            onTap: hasPrev
                ? () => _navigateTo(context,
                    speciesList[currentIndex - 1], speciesList, fromCatalog)
                : null,
          ),
          Row(
            children: List.generate(dotsCount, (i) {
              final active = i == currentIndex.clamp(0, dotsCount - 1);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width:  active ? 18 : 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.navy
                      : AppColors.cyan.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          _NavArrowButton(
            icon: Icons.chevron_right_rounded,
            enabled: hasNext,
            onTap: hasNext
                ? () => _navigateTo(context,
                    speciesList[currentIndex + 1], speciesList, fromCatalog)
                : null,
          ),
        ],
      ),
    );
  }

  void _navigateTo(
    BuildContext context,
    String newId,
    List<String> speciesList,
    bool fromCatalog,
  ) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ArticleScreen(),
        settings: RouteSettings(
          name: '/article',
          arguments: {
            'fromCatalog': fromCatalog,
            'speciesId':   newId,
            'speciesList': speciesList,
          },
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  // ── Volver al catálogo ───────────────────────────────────────────────────────────
  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.skyPale,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.navy.withOpacity(0.15), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.navy, size: 16),
              const SizedBox(width: 8),
              Text('back_to_catalog'.tr(),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Flecha de navegación reutilizable ───────────────────────────────────────────────────────
class _NavArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _NavArrowButton({
    required this.icon,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: enabled ? AppColors.cyan : AppColors.skyLight,
          shape: BoxShape.circle,
          boxShadow: enabled
              ? [BoxShadow(color: AppColors.cyan.withOpacity(0.30),
                  blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Icon(icon,
            color: enabled ? Colors.white : AppColors.textMuted, size: 22),
      ),
    );
  }
}
