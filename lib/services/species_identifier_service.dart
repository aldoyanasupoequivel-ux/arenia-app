// lib/services/species_identifier_service.dart

import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

import '../data/species_data.dart';
import '../models/identification_result.dart';

class SpeciesIdentifierService {
  static Interpreter? _interpreter;
  static List<String>? _labels;

  /// Inicializa el modelo TFLite (TensorFlow Lite).
  /// Se llamará al arrancar la cámara.
  static Future<void> initializeModel() async {
    if (_interpreter != null) return;
    try {
      print('Intentando cargar modelo TFLite...');
      try {
        _interpreter = await Interpreter.fromAsset('assets/models/model_unquant.tflite');
      } catch (e) {
        print('Fallo ruta 1, intentando ruta 2...');
        _interpreter = await Interpreter.fromAsset('models/model_unquant.tflite');
      }
      
      print('Modelo cargado exitosamente. Cargando labels...');
      // Cargar labels
      final labelsData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelsData
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) {
            // El formato de Teachable Machine es "0 GARZA AZUL"
            // Extraemos todo el texto después del número, lo pasamos a minúsculas
            // y cambiamos espacios por guiones bajos para que coincida con nuestros IDs.
            final parts = line.split(' ');
            if (parts.length > 1) {
              final labelName = parts.sublist(1).join(' ').toLowerCase().trim();
              String formatted = labelName.replaceAll(' ', '_');
              if (formatted == 'cormoranes_neotropicales') {
                formatted = 'cormoran_neotropical';
              }
              return formatted;
            }
            return parts.last.trim().toLowerCase().replaceAll(' ', '_');
          }).toList();

      print('Modelo TFLite cargado con ${_labels?.length} etiquetas.');
    } catch (e) {
      print('Error al cargar el modelo TFLite o labels: $e');
    }
  }

  /// Identifica la especie en la imagen local usando el modelo TFLite.
  /// Retorna un [IdentificationResult] con la especie encontrada o null.
  /// 
  /// NOTA: Todo el procesamiento se hace 100% OFFLINE.
  static Future<IdentificationResult> identify(File imageFile) async {
    if (_interpreter == null || _labels == null) {
      return IdentificationResult.notFound(
        suggestedName: 'Error: El modelo no está cargado.',
      );
    }

    try {
      // 1. Leer y decodificar la imagen
      final imageBytes = await imageFile.readAsBytes();
      var originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('No se pudo decodificar la imagen.');
      }
      
      // Corregir la orientación si la foto fue tomada con el celular rotado
      originalImage = img.bakeOrientation(originalImage);

      // Recortar un cuadrado central para evitar distorsión (aplastamiento) de las aves
      int size = originalImage.width < originalImage.height ? originalImage.width : originalImage.height;
      var croppedImage = img.copyCrop(
        originalImage,
        x: (originalImage.width - size) ~/ 2,
        y: (originalImage.height - size) ~/ 2,
        width: size,
        height: size,
      );

      // 2. Redimensionar a 224x224 (formato requerido por MobileNetV2)
      final image = img.copyResize(croppedImage, width: 224, height: 224);

      // 3. Normalizar los píxeles a [-1, 1] y extraer RGB
      // El shape debe ser [1, 224, 224, 3]
      var input = List.generate(
        1,
        (i) => List.generate(
          224,
          (y) => List.generate(
            224,
            (x) {
              final pixel = image.getPixel(x, y);
              // Obtener valores RGB (0-255)
              num r = pixel.r;
              num g = pixel.g;
              num b = pixel.b;
              
              // Normalizamos a [-1.0, 1.0] porque hemos corregido el script
              // de Python para usar preprocess_input nativo de MobileNetV2.
              return [
                (r / 127.5) - 1.0,
                (g / 127.5) - 1.0,
                (b / 127.5) - 1.0
              ];
            },
          ),
        ),
      );

      // 4. Preparar array de salida [1, 4] (4 clases)
      var output = List.generate(1, (i) => List.filled(_labels!.length, 0.0));

      // 5. Ejecutar inferencia
      _interpreter!.run(input, output);
      
      final resultProbabilities = output[0];

      // 6. Encontrar la clase con mayor probabilidad
      int maxIndex = 0;
      double maxProb = resultProbabilities[0];
      for (int i = 1; i < resultProbabilities.length; i++) {
        if (resultProbabilities[i] > maxProb) {
          maxProb = resultProbabilities[i];
          maxIndex = i;
        }
      }

      final detectedId = _labels![maxIndex];
      dev.log('Predicción TFLite: $detectedId con probabilidad $maxProb');

      // Buscar la especie en la base de datos por su ID
      Species? matchedSpecies = speciesDatabase.cast<Species?>().firstWhere(
        (s) => s!.id == detectedId,
        orElse: () => null,
      );

      if (matchedSpecies != null) {
        return IdentificationResult(
          species: matchedSpecies,
          confidence: maxProb,
          suggestedName: '',
          scientificName: '',
        );
      } else {
        return IdentificationResult.notFound(
          suggestedName: 'Especie no registrada en la base de datos ($detectedId)',
        );
      }

    } catch (e) {
      return IdentificationResult.notFound(
        suggestedName: 'Error en modelo local: ${e.toString()}',
      );
    }
  }

  /// Libera los recursos del modelo TFLite al cerrar la cámara.
  static void disposeModel() {
    _interpreter?.close();
    _interpreter = null;
  }
}
