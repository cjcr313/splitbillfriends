import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/bill_provider.dart';
import '../providers/history_provider.dart';
import '../theme/app_theme.dart';
import 'friends_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _startNewBillFlow(BuildContext context) {
    Provider.of<BillProvider>(context, listen: false).startNewBill();
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FriendsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final historyProvider = Provider.of<HistoryProvider>(context);
    
    final themeMode = themeProvider.currentMode;
    final isNeon = themeMode == AppThemeMode.neon;
    final savedCount = historyProvider.savedBills.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kunpapp'),
        centerTitle: true,
        actions: [
          // Botón del Historial
          IconButton(
            icon: const Icon(Icons.history_edu),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
            tooltip: 'Ver Historial',
          ),
          // Botón para ciclar entre Claro, Oscuro y Neón
          IconButton(
            icon: Icon(
              themeMode == AppThemeMode.light 
                ? Icons.dark_mode_rounded 
                : (themeMode == AppThemeMode.dark ? Icons.bolt_rounded : Icons.light_mode_rounded),
            ),
            onPressed: () => themeProvider.cycleTheme(),
            tooltip: 'Cambiar Tema',
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (context, double val, child) {
                  return Transform.scale(
                    scale: val,
                    child: _buildFeaturedGraphic(context, isNeon),
                  );
                },
              ),
              
              const SizedBox(height: 48),
              
              Text(
                savedCount == 0 ? 'Sin deudas pendientes' : 'Tienes $savedCount cuentas en el archivo',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                savedCount == 0 
                  ? 'Tu historial está vacío.\n¿Listo para salir a compartir con amigos?'
                  : 'Revisa tu historial arriba a la derecha.\n¿Listo para una nueva aventura gástrica?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),
              
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewBillFlow(context),
        icon: const Icon(Icons.add_rounded, size: 28),
        label: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('NUEVA CUENTA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFeaturedGraphic(BuildContext context, bool isNeon) {
    Color accentColor = Theme.of(context).colorScheme.primary;
    
    return Center(
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          color: isNeon ? Colors.black : accentColor.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          boxShadow: isNeon 
            ? [BoxShadow(color: accentColor.withValues(alpha: 0.2), blurRadius: 60, spreadRadius: 20)]
            : [],
          border: isNeon 
            ? Border.all(color: accentColor, width: 2) 
            : null,
        ),
        child: Center(
          child: Icon(
            Icons.receipt_long_rounded,
            size: 90,
            color: isNeon ? accentColor : accentColor.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}
