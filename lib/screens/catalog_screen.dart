import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../data/species_data.dart';
import '../theme/app_theme.dart';

// ─── Icono / Emoji por categoría ──────────────────────────────────────────────
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

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _selectedCategory = 'all';
  List<Species> _allSpecies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSpecies();
  }

  Future<void> _loadSpecies() async {
    if (mounted) {
      setState(() {
        _allSpecies = speciesDatabase;
        _isLoading = false;
      });
    }
  }

  // Construir la lista de categorías dinámicamente desde la base de datos
  List<String> get _categories {
    final cats = _allSpecies.map((s) => s.category).toSet().toList()..sort();
    return ['all', ...cats];
  }

  List<Species> get _filteredSpecies {
    if (_selectedCategory == 'all' || _selectedCategory == 'Todas') return _allSpecies;
    return _allSpecies.where((s) => s.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
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
                  child: CustomScrollView(
                    slivers: [
                      // Fila de chips de filtro (Categorías)
                      SliverToBoxAdapter(
                        child: _isLoading 
                            ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                            : _buildFilterRow(),
                      ),
                      // Cuadrícula (Grid) de especies
                      if (!_isLoading)
                        SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index < _filteredSpecies.length) {
                                return _buildSpeciesCard(context, _filteredSpecies[index]);
                              }
                              return null;
                            },
                            childCount: _filteredSpecies.length,
                          ),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.76,
                          ),
                        ),
                      ),
                      // Tarjeta inferior de conservación
                      SliverToBoxAdapter(
                        child: _buildInfoCard(),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Encabezado (mismo estilo que HomeScreen) ─────────────────────────────
  Widget _buildHeader(BuildContext context) {
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
          const Icon(Icons.shield_rounded, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          Text(
            'catalog_title'.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Chips de filtro (Categorías) ─────────────────────────────────────────
  Widget _buildFilterRow() {
    return Container(
      height: 52,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.navy : Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? AppColors.navy : AppColors.navy.withOpacity(0.20),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withOpacity(isSelected ? 0.28 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cat != 'all' && cat != 'Todas') ...[
                    Text(
                      _categoryEmoji(cat),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    cat == 'all' || cat == 'Todas' ? 'all'.tr() : 'categories.$cat'.tr(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textNavy,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Tarjeta de especie ───────────────────────────────────────────────────
  Widget _buildSpeciesCard(BuildContext context, Species species) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/article',
        arguments: {
          'fromCatalog': true,
          'speciesId': species.id,
          'speciesList': _filteredSpecies.map((s) => s.id).toList(),
        },
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Imagen con insignia de categoría ─────────────────────────
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14)),
                    child: Builder(builder: (context) {
                      Widget errorWidget = Container(
                        color: AppColors.skyLight,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _categoryEmoji(species.category),
                                style: const TextStyle(fontSize: 36),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'no_image'.tr(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                      if (species.imageUrl.startsWith('http')) {
                        return Image.network(
                          species.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => errorWidget,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: AppColors.skyLight,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.cyan,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return Image.asset(
                          species.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => errorWidget,
                        );
                      }
                    }),
                  ),
                  // Insignia de categoría (Emoji)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _categoryEmoji(species.category),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Nombre + Nombre científico + Flecha ──────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'species.${species.id}.name'.tr(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textNavy,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            species.scientificName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Botón de flecha
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.skyLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.navy,
                        size: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tarjeta inferior de conservación (mismo diseño que HomeScreen) ────────
  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
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
          const Icon(Icons.eco_rounded, color: AppColors.cyan, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'home_subtitle'.tr(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'home_description'.tr(),
                  style: TextStyle(
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
}
