/// Modelo de datos estático que representa una pieza de contenido adicional
/// (Infografías, Trípticos o Noticias) en la sección "Sobre el Humedal".
class ContenidoItem {
  final String titulo;
  final String tipo;
  final String imagenAsset;
  final String descripcion;

  const ContenidoItem({
    required this.titulo,
    required this.tipo,
    required this.imagenAsset,
    this.descripcion = '',
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Tipos disponibles:
//   'Infografia'  → mapas, infografías turísticas
//   'Triptico'    → trípticos informativos
//   'Noticia'     → noticias del humedal
//
// Para agregar contenido:
//   1. Coloca la imagen en assets/images/contenido/
//   2. Agrega la entrada en pubspec.yaml bajo assets
//   3. Agrega un nuevo ContenidoItem a la lista de abajo
// ─────────────────────────────────────────────────────────────────────────────

final List<ContenidoItem> contenidoDatabase = [
  const ContenidoItem(
    titulo: 'Mapa del Humedal',
    tipo: 'Infografia',
    imagenAsset: 'assets/images/fondo.png',
    descripcion: 'Mapa satelital del Humedal Costero Poza de la Arenilla.',
  ),
  const ContenidoItem(
    titulo: 'Tríptico Informativo 2024',
    tipo: 'Triptico',
    imagenAsset: 'assets/images/humedal_logo.png',
    descripcion: 'Información general sobre las aves migratorias.',
  ),
  const ContenidoItem(
    titulo: 'Proyecto de Conservación',
    tipo: 'Noticia',
    imagenAsset: 'assets/images/fondo.png',
    descripcion: 'Nuevos esfuerzos para limpiar las playas del humedal.',
  ),
];
