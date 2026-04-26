import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logotipo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 60,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Kumpa',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Versión 0.2.0',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 48),
              
              // Información de estudio
              Text(
                'Desarrollado por',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nautalab',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Propiedad de Nautalab',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 48),
              
              // Derechos de autor
              const Divider(),
              const SizedBox(height: 24),
              Text(
                '© 2026 Nautalab',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Todos los derechos reservados. El código, diseño y recursos gráficos de esta aplicación están protegidos por las leyes de derecho de autor y de propiedad intelectual internacionales de Nautalab.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
