import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Inyección de Providers y Pantallas
import 'providers/theme_provider.dart';
import 'providers/bill_provider.dart';
import 'providers/history_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    // 1. Envolvemos la App entera en un MultiProvider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()), // Nuevo Gestor de Base de Datos
      ],
      child: const SplitBillApp(),
    ),
  );
}

class SplitBillApp extends StatelessWidget {
  const SplitBillApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Escuchamos al ThemeProvider para redibujar la app si cambia el tema
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'SplitBillFriends',
      debugShowCheckedModeBanner: false, // Desactiva la etiqueta 'DEBUG' fea de arriba
      theme: themeProvider.currentThemeData, // Se inyecta la Data actual (Claro, Oscuro, Neon)
      home: const HomeScreen(), // La ruta inicial
    );
  }
}
