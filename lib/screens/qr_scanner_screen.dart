import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_theme.dart';
import '../data/species_data.dart';

/// Pantalla encargada de abrir la cámara y escanear códigos QR.
/// Si el QR tiene el formato válido (arenia://species/ID_ESPECIE),
/// redirige automáticamente a la pantalla del artículo correspondiente.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final String code = barcode.rawValue!;
        // Formato esperado: arenia://species/playero_arenero
        if (code.startsWith('arenia://species/')) {
          _isProcessing = true;
          controller.stop();
          final String speciesId = code.replaceFirst('arenia://species/', '');
          
          // Verificar si existe la especie
          final exists = speciesDatabase.any((s) => s.id == speciesId);
          if (exists) {
             Navigator.pushReplacementNamed(
               context,
               '/article',
               arguments: {
                 'fromCatalog': false,
                 'speciesId': speciesId,
               },
             );
          } else {
             _showError('Especie no encontrada en la base de datos.');
          }
          break;
        } else {
          _isProcessing = true;
          controller.stop();
          _showError('Código QR no válido para Humedal La Arenilla.');
          break;
        }
      }
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error de lectura'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isProcessing = false;
              });
              controller.start();
            },
            child: const Text('Intentar de nuevo'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Escanear QR', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          // Decoración superpuesta
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.cyan, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Apunta el código QR del panel',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
