import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/splash_gate_screen.dart';
import 'screens/home_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/article_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/about_screen.dart';
import 'theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'providers/accessibility_provider.dart';/// Punto de entrada principal de la aplicación.
/// Inicializa la configuración de localización, bloquea la orientación
/// de la pantalla en modo vertical e inicia el ciclo de vida de Flutter.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos la librería para el manejo de múltiples idiomas
  await EasyLocalization.ensureInitialized();
  
  // Bloqueamos la orientación de la pantalla solo a modo vertical (portrait)
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
      ],
      child: EasyLocalization(
        // Lista de idiomas soportados por la aplicación
        supportedLocales: const [
          Locale('es'), // Español (Por defecto)
          Locale('qu'), // Quechua
          Locale('en'), // Inglés
          Locale('pt'), // Portugués
          Locale('fr'), // Francés
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('es'),
        child: const AreniaApp(),
      ),
    ),
  );
}

/// Delegado personalizado para manejar la falta de traducciones oficiales
/// de Material Design en idioma Quechua ('qu').
/// Si no encuentra la traducción en Quechua, utiliza el Español como respaldo.
class FallbackMaterialLocalizationDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationDelegate();
  
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'qu';
  
  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      await GlobalMaterialLocalizations.delegate.load(const Locale('es'));
      
  @override
  bool shouldReload(FallbackMaterialLocalizationDelegate old) => false;
}

/// Delegado personalizado para manejar la falta de traducciones oficiales
/// de Cupertino (estilo iOS) en idioma Quechua ('qu').
/// Si no encuentra la traducción en Quechua, utiliza el Español como respaldo.
class FallbackCupertinoLocalizationDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationDelegate();
  
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'qu';
  
  @override
  Future<CupertinoLocalizations> load(Locale locale) async =>
      await GlobalCupertinoLocalizations.delegate.load(const Locale('es'));
      
  @override
  bool shouldReload(FallbackCupertinoLocalizationDelegate old) => false;
}

/// Clase principal que construye la estructura base de la aplicación,
/// definiendo el tema global y el enrutamiento de las pantallas.
class AreniaApp extends StatelessWidget {
  const AreniaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        final accessibility = Provider.of<AccessibilityProvider>(context);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(accessibility.textScaleFactor),
          ),
          child: child!,
        );
      },
      localizationsDelegates: [
        const FallbackMaterialLocalizationDelegate(),
        const FallbackCupertinoLocalizationDelegate(),
        ...context.localizationDelegates,
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Humedal La Arenilla',
      theme: AppTheme.theme,
      initialRoute: '/', // Pantalla inicial
      routes: {
        '/':        (context) => const SplashGateScreen(),
        '/home':    (context) => const HomeScreen(),
        '/catalog': (context) => const CatalogScreen(),
        '/camera':  (context) => const CameraScreen(),
        '/article': (context) => const ArticleScreen(),
        '/terms':   (context) => const TermsScreen(),
        '/about':   (context) => const AboutScreen(),
      },
      // Oculta la etiqueta roja de "DEBUG" en la esquina superior derecha
      debugShowCheckedModeBanner: false,
    );
  }
}
