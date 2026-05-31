import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:dulceapp/providers/auth_provider.dart';
import 'package:dulceapp/providers/favoritos_provider.dart';
import 'package:dulceapp/models/postre.dart';
import 'package:dulceapp/theme/app_theme.dart';

Widget _buildImagen(String url, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  if (url.isEmpty) return _placeholder(width: width, height: height);
  if (url.startsWith('data:')) {
    try {
      final bytes = base64Decode(url.split(',')[1]);
      return Image.memory(bytes, width: width, height: height, fit: fit);
    } catch (_) {
      return _placeholder(width: width, height: height);
    }
  }
  return Image.network(url, width: width, height: height, fit: fit,
      errorBuilder: (_, __, ___) => _placeholder(width: width, height: height));
}

Widget _placeholder({double? width, double? height}) {
  return Container(
    width: width, height: height, color: AppColors.moradoSuave,
    child: const Center(child: Text('🍰', style: TextStyle(fontSize: 28))),
  );
}

class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final favs = context.read<FavoritosProvider>();

    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      appBar: AppBar(title: const Text('Mis favoritos ❤️')),
      body: StreamBuilder<List<Postre>>(
        stream: favs.streamFavoritos(auth.usuario?.uid ?? ''),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.morado));
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💜', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text('Aún no tienes favoritos', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Toca el corazón en cualquier postre', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snap.data!.length,
            itemBuilder: (context, i) {
              final postre = snap.data![i];
              return GestureDetector(
                onTap: () => context.push('/postre/${postre.id}'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.morado.withValues(alpha: 0.07),
                        blurRadius: 8, offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                        child: _buildImagen(postre.imagenUrl, width: 90, height: 90),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(postre.nombre,
                                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textoOscuro)),
                            const SizedBox(height: 4),
                            Text('\$${postre.precio.toStringAsFixed(0)}',
                                style: const TextStyle(color: AppColors.morado, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite, color: AppColors.rosa),
                        onPressed: () {
                          final uid = auth.usuario?.uid ?? '';
                          context.read<FavoritosProvider>().toggleFavorito(uid, postre.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}