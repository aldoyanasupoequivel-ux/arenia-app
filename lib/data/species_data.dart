// lib/data/species_data.dart

/// Archivo de datos estáticos que actúa como la base de datos local de la aplicación.
/// Contiene la información taxonómica, ecológica y multimedia de las especies
/// que habitan el Humedal La Arenilla.

// ─────────────────────────────────────────────────────────────────────────────
// Categorías disponibles para clasificación:
//   'Aves'        → Aves acuáticas, playeras, guaneras, etc.
//   'Crustáceos'  → Cangrejos, camarones, etc.
//   'Insectos'    → Libélulas, mariposas, escarabajos, etc.
//   'Plantas'     → Flora representativa del humedal
//   'Peces'       → Peces de aguas someras o estuarios
//   'Mamíferos'   → Mamíferos terrestres o marinos
//   'Reptiles'    → Lagartijas, tortugas marinas, etc.
//   'Otros'       → Cualquier otra forma de vida
// ─────────────────────────────────────────────────────────────────────────────

class Species {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final String category;   // ← Tipo principal para el filtrado en catálogo
  final String typeLabel;  // ← Etiqueta corta descriptiva (ej. "Ave acuática migratoria")
  final String habitat;    // ← Descripción del entorno donde reside o se alimenta
  final String diet;       // ← Principales fuentes de alimentación
  final String status;     // ← Estado de conservación o comportamiento migratorio

  // ── Enlaces a las imágenes (Assets). Soporta múltiples para generar un carrusel ──
  final List<String> imageUrls;

  // ── Ruta de audio opcional para reproducir el canto o sonido de la especie ──────
  // Puede dejarse como una cadena vacía ('') si la especie no cuenta con audio.
  final String audioUrl;

  const Species({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.imageUrls,
    required this.category,
    this.typeLabel = '',
    this.habitat   = '',
    this.diet      = '',
    this.status    = '',
    this.audioUrl  = '',   // ← deja '' si aún no tienes el audio
  });

  // Acceso rápido a la primera imagen (usada en el catálogo)
  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';
}

// ─────────────────────────────────────────────────────────────────────────────
// BASE DE DATOS DE ESPECIES - MVP HACKATÓN (Top 10 Especies)
// ─────────────────────────────────────────────────────────────────────────────
final List<Species> speciesDatabase = [
  const Species(
    id: "playero_arenero",
    name: "Playero Arenero",
    scientificName: "Calidris alba",
    description: "Ave playera pequeña muy activa, conocida por correr incansablemente a lo largo de la línea de las olas persiguiendo invertebrados marinos. Es una especie migratoria que se reproduce en el Ártico y llega a las costas peruanas durante el invierno boreal.",
    imageUrls: [
      "assets/images/imagenes/correlimos_menudillo.png",
      "assets/images/imagenes/correlimos_menudillo1.png",
      "assets/images/imagenes/correlimos_menudillo2.png"
    ],
    audioUrl: "",
    category: "Aves",
    typeLabel: "Ave migratoria",
    habitat: "Playas arenosas abiertas, estuarios y marismas.",
    diet: "Pequeños crustáceos, moluscos e invertebrados marinos arrastrados por las olas.",
    status: "Preocupación menor",
  ),

  const Species(
    id: "chorlo_semipalmeado",
    name: "Chorlo Semipalmeado",
    scientificName: "Charadrius semipalmatus",
    description: "Pequeña ave playera migratoria que se caracteriza por una banda oscura alrededor del pecho y un pico corto y grueso. Se alimenta en bancos de barro y playas, corriendo rápidamente en cortas distancias antes de detenerse repentinamente para buscar presas.",
    imageUrls: [
      "assets/images/imagenes/chorlitejo_semipalmeado.png",
      "assets/images/imagenes/chorlitejo_semipalmeado1.png",
      "assets/images/imagenes/chorlitejo_semipalmeado2.png"
    ],
    audioUrl: "",
    category: "Aves",
    typeLabel: "Ave playera",
    habitat: "Llanuras de lodo, humedales costeros y playas.",
    diet: "Insectos, crustáceos y gusanos pequeños.",
    status: "Preocupación menor",
  ),

  const Species(
    id: "playerito_semipalmado",
    name: "Playerito Semipalmado",
    scientificName: "Calidris pusilla",
    description: "Uno de los playeritos más comunes y pequeños. Durante la migración, forma enormes bandadas sincronizadas. Posee patas negras y se alimenta sondeando velozmente el lodo y la arena superficial con su pico corto.",
    imageUrls: [
      "assets/images/imagenes/correlimos_semipalmeado.png",
      "assets/images/imagenes/correlimos_semipalmeado1.png",
      "assets/images/imagenes/correlimos_semipalmeado2.png"
    ],
    audioUrl: "",
    category: "Aves",
    typeLabel: "Ave migratoria",
    habitat: "Humedales, orillas fangosas y estuarios.",
    diet: "Invertebrados acuáticos, pequeños moluscos y anfípodos.",
    status: "Casi amenazada",
  ),

  const Species(
    id: "zarapito_trinador",
    name: "Zarapito Trinador",
    scientificName: "Numenius phaeopus",
    description: "Ave playera de gran tamaño, fácilmente reconocible por su largo pico curvado hacia abajo y el distintivo patrón rayado en la cabeza. Su llamado es un característico trino rápido y silbante que se escucha a largas distancias.",
    imageUrls: [
      "assets/images/imagenes/zarapito_trinador_americano.png",
      "assets/images/imagenes/zarapito_trinador_americano1.png",
      "assets/images/imagenes/zarapito_trinador_americano2.png"
    ],
    audioUrl: "",
    category: "Aves",
    typeLabel: "Ave playera grande",
    habitat: "Marismas, llanuras de lodo y playas rocosas.",
    diet: "Cangrejos, caracoles, gusanos e insectos marinos.",
    status: "Preocupación menor",
  ),

  const Species(
    id: "gaviota_peruana",
    name: "Gaviota Peruana",
    scientificName: "Larus belcheri",
    description: "También conocida como Gaviota Simeón, es una especie costera grande y robusta, endémica de la corriente de Humboldt. Los adultos tienen un distintivo manto gris muy oscuro, cabeza blanca (en verano) y un pico amarillo con una notoria mancha roja y negra en la punta.",
    imageUrls: [
      "assets/images/imagenes/gaviota_simeon.png",
      "assets/images/imagenes/gaviota_simeon1.png",
      "assets/images/imagenes/gaviota_simeon2.png"
    ],
    audioUrl: "",
    category: "Aves",
    typeLabel: "Ave marina",
    habitat: "Costas del Pacífico, islas guaneras, playas y puertos.",
    diet: "Peces, crustáceos, moluscos y carroña.",
    status: "Preocupación menor",
  ),

  const Species(
    id: "gaviota_franklin",
    name: "Gaviota de Franklin",
    scientificName: "Leucophaeus pipixcan",
    description: "Una gaviota elegante, famosa por migrar miles de kilómetros desde las praderas norteamericanas hasta la costa del Pacífico sudamericano. Durante el verano austral, miles de estas gaviotas invaden las playas. Se reconocen por su capirote negro.",
    imageUrls: [
      "assets/images/imagenes/gaviota_pipizcan.png",
      "assets/images/imagenes/gaviota_pipizcan1.png",
      "assets/images/imagenes/gaviota_pipizcan2.png"
    ],
    audioUrl: "",
    category: "Aves",
    typeLabel: "Ave migratoria",
    habitat: "Lagos, humedales interiores y playas costeras.",
    diet: "Insectos, lombrices de tierra, peces pequeños e invertebrados.",
    status: "Preocupación menor",
  ),

  const Species(
    id: "cormoran_neotropical",
    name: "Cormorán Neotropical",
    scientificName: "Nannopterum brasilianum",
    description: "Ave acuática oscura y alargada, excelente buceadora. Es común verla nadando con el cuerpo sumergido y solo el cuello asomando, o posada en postes y rocas con las alas extendidas secando su plumaje.",
    imageUrls: [
      "assets/images/imagenes/cormoran_bigua.png",
      "assets/images/imagenes/cormoran_bigua1.png",
      "assets/images/imagenes/cormoran_bigua2.png"
    ],
    audioUrl: "",
    category: "Aves",
    typeLabel: "Ave acuática",
    habitat: "Ríos, lagos, humedales, manglares y estuarios costeros.",
    diet: "Peces, anfibios e invertebrados acuáticos pequeños.",
    status: "Preocupación menor",
  ),

  const Species(
    id: "piquero_peruano",
    name: "Piquero Peruano",
    scientificName: "Sula variegata",
    description: "Un ave marina icónica del litoral peruano. Se agrupa en bandadas inmensas y se zambulle espectacularmente en picada desde grandes alturas para pescar. Posee patas grises parduzcas y un dorso moteado blanco y pardo.",
    imageUrls: [
      "assets/images/imagenes/piquero_peruano.png",
      "assets/images/imagenes/piquero_peruano1.png",
      "assets/images/imagenes/piquero_peruano2.png"
    ],
    audioUrl: "",
    category: "Aves",
    typeLabel: "Ave marina guanera",
    habitat: "Océano costero, acantilados rocosos e islas marinas.",
    diet: "Anchoveta peruana, sardinas y peces pelágicos.",
    status: "Preocupación menor",
  ),

  const Species(
    id: "garza_blanca_grande",
    name: "Garza Blanca Grande",
    scientificName: "Ardea alba",
    description: "Una de las aves zancudas más altas y elegantes. Totalmente blanca con un imponente pico amarillo y largas patas negras. Acecha pacientemente inmóvil en aguas someras hasta que lanza un rápido arponazo con su cuello para capturar a su presa.",
    imageUrls: [
      "assets/images/imagenes/garceta_grande.png",
      "assets/images/imagenes/garceta_grande1.png",
      "assets/images/imagenes/garceta_grande2.png"
    ],
    audioUrl: "",
    category: "Aves",
    typeLabel: "Ave zancuda",
    habitat: "Lagos, humedales, riberas, marismas y pantanos.",
    diet: "Peces, ranas, culebras, crustáceos grandes y pequeños roedores.",
    status: "Preocupación menor",
  ),

  const Species(
    id: "ostrero_americano",
    name: "Ostrero Americano",
    scientificName: "Haematopus palliatus",
    description: "Ave costera inconfundible y ruidosa, de cabeza negra, lomo pardo y vientre blanco puro. Lo que más destaca es su larguísimo y fuerte pico rojo anaranjado brillante, que utiliza como herramienta perfecta para abrir moluscos bivalvos.",
    imageUrls: [
      "assets/images/imagenes/ostrero_pio_americano.png",
      "assets/images/imagenes/ostrero_pio_americano1.png",
      "assets/images/imagenes/ostrero_pio_americano2.png"
    ],
    audioUrl: "",
    category: "Aves",
    typeLabel: "Ave playera",
    habitat: "Costas rocosas, playas de arena y fango, islotes.",
    diet: "Ostras, mejillones, lapas y otros invertebrados con concha dura.",
    status: "Preocupación menor",
  ),

  const Species(
    id: "garza_azul",
    name: "Garza Azul",
    scientificName: "Egretta caerulea",
    description: "Una garza elegante de tamaño mediano. Los adultos tienen un plumaje gris azulado oscuro con cabeza y cuello violáceos. Suelen alimentarse sigilosamente en aguas poco profundas, capturando peces y anfibios con su pico en forma de daga.",
    imageUrls: [
      "assets/images/imagenes/garza_azul.jpg",
      "assets/images/imagenes/garza_azul1.jpg",
      "assets/images/imagenes/garza_azul2.jpg"
    ],
    audioUrl: "",
    category: "Aves",
    typeLabel: "Ave zancuda",
    habitat: "Estuarios, lagunas costeras, marismas y pantanos.",
    diet: "Peces, ranas, crustáceos e insectos acuáticos.",
    status: "Preocupación menor",
  ),

  const Species(
    id: "pelicano_peruano",
    name: "Pelícano Peruano",
    scientificName: "Pelecanus thagus",
    description: "Una de las aves marinas más grandes de la corriente de Humboldt. Inconfundible por su enorme pico con bolsa gular donde almacena los peces que captura lanzándose en picada espectacular desde el aire.",
    imageUrls: [
      "assets/images/imagenes/pelicano_peruano.jpg",
      "assets/images/imagenes/pelicano_peruano1.jpg",
      "assets/images/imagenes/pelicano_peruano2.jpg"
    ],
    audioUrl: "",
    category: "Aves",
    typeLabel: "Ave marina guanera",
    habitat: "Aguas costeras, puertos, muelles e islas marinas.",
    diet: "Principalmente anchoveta, sardinas y peces superficiales.",
    status: "Casi amenazada",
  )
];
