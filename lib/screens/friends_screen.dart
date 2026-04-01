import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bill_provider.dart';
import 'items_screen.dart'; // NUEVA RUTA

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _addFriend() {
    final name = _nameController.text;
    if (name.isNotEmpty) {
      Provider.of<BillProvider>(context, listen: false).addFriend(name);
      _nameController.clear();
    }
  }

  void _addMe() {
    Provider.of<BillProvider>(context, listen: false).addFriend("Yo");
  }

  // Permite darle a un amigo un color de Avatar aleatorio pero constante basándose en su ID visual.
  Color _getRandomAvatarColor(String id) {
    final hue = (id.hashCode % 360).toDouble();
    return HSVColor.fromAHSV(1.0, hue, 0.7, 0.9).toColor();
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos de forma reactiva a la clase Bill para que los botones cambien automáticamente
    final billProvider = Provider.of<BillProvider>(context);
    final friends = billProvider.currentBill?.friends ?? [];
    
    // Verificador: Oculta el botón rápido de 'Yo' si ya me agregué.
    final hasMe = friends.any((f) => f.name.toLowerCase() == 'yo');
    final accentColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Con quién estás?'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Chip rápido que me sugeriste ("Añadirme a mí")
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: !hasMe 
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ActionChip(
                          avatar: const Icon(Icons.person, size: 16),
                          label: const Text('Agregarme a mí (Yo)'),
                          onPressed: _addMe,
                          backgroundColor: accentColor.withValues(alpha: 0.1),
                          side: BorderSide(color: accentColor.withValues(alpha: 0.5)),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              ),

              // 2. Campo input principal con su botón
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Ej. Ami 1, María, Juan...',
                        filled: true,
                        fillColor: Theme.of(context).cardTheme.color,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      onSubmitted: (_) => _addFriend(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    heroTag: 'addFriendBtn', // heroTag explícito para evitar bugs
                    mini: true,
                    onPressed: _addFriend,
                    elevation: 4,
                    child: const Icon(Icons.add),
                  )
                ],
              ),
              const SizedBox(height: 32),

              // 3. Grid dinámico de Burbujas / Avatares
              Expanded(
                child: friends.isEmpty
                    ? Center(
                        child: Text(
                          'Aún no hay nadie en la mesa... =(',
                          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5)),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8, // Forma ligeramente estirada de la tarjeta/grilla
                        ),
                        itemCount: friends.length,
                        itemBuilder: (context, index) {
                          final friend = friends[index];
                          final initial = friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?';
                          final dynamicColor = _getRandomAvatarColor(friend.id);

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundColor: dynamicColor.withValues(alpha: 0.15),
                                    child: Text(
                                      initial,
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: dynamicColor,
                                      ),
                                    ),
                                  ),
                                  // El mini botoncito 'X' para eliminar por error
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => billProvider.removeFriend(friend.id),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                friend.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis, // Si es largo (ej Alejandro Magno) le pone "..."
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              )
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      
      // 4. El Gran botón hacia el escáner (o items manuales), validando si hay amigos.
      floatingActionButton: friends.isNotEmpty
        ? FloatingActionButton.extended(
            heroTag: 'goDivideBtn',
            onPressed: () {
               // Navega a la siguiente pantalla (Items)
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (_) => const ItemsScreen()),
               );
            },
            icon: const Icon(Icons.receipt_long, size: 28),
            label: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('¡A Dividir!', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
        )
        : null, // Si es Null el botón desaparece de forma fluida (animación de Flutter)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
