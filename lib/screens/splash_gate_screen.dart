import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'terms_screen.dart';
import 'home_screen.dart';

/// Pantalla inicial ("Splash Screen") que actúa como puerta de entrada.
/// Se encarga de mostrar el logo al iniciar la app y verifica si el usuario
/// ya ha aceptado los términos y condiciones.
class SplashGateScreen extends StatefulWidget {
  const SplashGateScreen({super.key});

  @override
  State<SplashGateScreen> createState() => _SplashGateScreenState();
}

class _SplashGateScreenState extends State<SplashGateScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  bool _checked = false; // Indica si ya se verificaron los términos

  @override
  void initState() {
    super.initState();
    // Configuración de la animación de aparición (Fade-in)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    
    // Iniciar la verificación de términos en segundo plano
    _checkTerms();
  }

  /// Función asíncrona que revisa en el almacenamiento local (SharedPreferences)
  /// si el usuario ya aceptó las políticas de privacidad.
  Future<void> _checkTerms() async {
    // Pequeño retraso artificial para que la animación del logo sea visible
    await Future.delayed(const Duration(milliseconds: 900));
    
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool('terms_accepted') ?? false;
    
    if (!mounted) return; // Evita errores si la pantalla ya no está activa
    
    if (accepted) {
      // Si ya aceptó, ir directo al menú principal
      _goHome();
    } else {
      // Si no ha aceptado, cambiar el estado para mostrar la pantalla de términos
      setState(() => _checked = true);
    }
  }

  /// Navega hacia la pantalla principal reemplazando la actual,
  /// utilizando una transición suave de desvanecimiento.
  void _goHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  /// Función que se llama cuando el usuario acepta los términos.
  /// Guarda su decisión en la memoria local y lo redirige a Home.
  Future<void> _accept() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('terms_accepted', true);
    _goHome();
  }

  /// Función que se llama cuando el usuario rechaza los términos.
  /// Muestra un cuadro de diálogo advirtiendo que son obligatorios para usar la app.
  void _reject() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.cyan, size: 22),
            const SizedBox(width: 8),
            const Text(
              'Atención',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textNavy),
            ),
          ],
        ),
        content: const Text(
          'Para usar la aplicación debes aceptar los términos y condiciones.',
          style: TextStyle(fontSize: 13, color: AppColors.textNavy, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Leer de nuevo',
                style: TextStyle(color: AppColors.navy)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mientras verifica los términos, muestra la pantalla de carga (Splash)
    if (!_checked) {
      return Scaffold(
        backgroundColor: AppColors.navyDark,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyan.withOpacity(0.30),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset('assets/images/logo.png',
                        errorBuilder: (_, __, ___) => const Icon(
                              Icons.water_rounded,
                              color: AppColors.cyan,
                              size: 60,
                            )),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'HUMEDAL LA ARENILLA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gobierno Regional del Callao',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 40),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: AppColors.cyan,
                    strokeWidth: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Si ya verificó y no están aceptados, muestra la pantalla de Términos y Condiciones
    return TermsScreen(
      onAccept: _accept,
      onReject: _reject,
    );
  }
}
