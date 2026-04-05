import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Inyección de Providers y Pantallas
import 'providers/theme_provider.dart';
import 'providers/bill_provider.dart';
import 'providers/history_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => BillProvider(prefs)),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: const KunpappApp(),
    ),
  );
}

class KunpappApp extends StatelessWidget {
  const KunpappApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Kunpapp',
      debugShowCheckedModeBanner: false, // Desactiva la etiqueta 'DEBUG' fea de arriba
      theme: themeProvider.currentThemeData, // Se inyecta la Data actual (Claro, Oscuro, Neon)
      home: const SplashScreen(), // La ruta inicial
    );
  }
}
