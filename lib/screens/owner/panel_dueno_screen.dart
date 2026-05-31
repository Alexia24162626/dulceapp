import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:dulceapp/providers/auth_provider.dart';
import 'package:dulceapp/providers/postre_provider.dart';
import 'package:dulceapp/models/postre.dart';
import 'package:dulceapp/theme/app_theme.dart';

Widget _buildImagen(String url,
    {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  if (url.isEmpty) return _placeholder(width: width, height: height);
  if (url.startsWith('data:')) {
    try {
      final bytes = base64Decode(url.split(',')[1]);
      return Image.memory(bytes, width: width, height: height, fit: fit);
    } catch (_) {
      return _placeholder(width: width, height: height);
    }
  }
  return Image.network(url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _placeholder(width: width, height: height));
}

Widget _placeholder({double? width, double? height}) {
  return Container(
    width: width,
    height: height,
    color: AppColors.moradoSuave,
    child: const Center(child: Text('🍰', style: TextStyle(fontSize: 28))),
  );
}

class PanelDuenoScreen extends StatelessWidget {
  const PanelDuenoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postres = context.watch<PostreProvider>();

    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      appBar: AppBar(
        title: const Text('Panel del dueño 👑'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().cerrarSesion();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/agregar-postre'),
        backgroundColor: AppColors.morado,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Agregar postre',
            style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<List<Postre>>(
        stream: postres.streamPostres(),
        builder: (context, snap) {
          if (!snap.hasData || snap.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🍰', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text('No hay postres aún',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Toca "Agregar postre" para empezar',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: snap.data!.length,
            itemBuilder: (context, i) {
              final p = snap.data![i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.morado.withValues(alpha: 0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildImagen(p.imagenUrl, width: 60, height: 60),
                  ),
                  title: Text(p.nombre,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('\$${p.precio.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: AppColors.morado,
                          fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: AppColors.azul),
                        onPressed: () =>
                            context.push('/agregar-postre?id=${p.id}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.rosa),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('¿Eliminar postre?'),
                              content: Text(
                                  '¿Seguro que quieres eliminar "${p.nombre}"?'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(false),
                                    child: const Text('Cancelar')),
                                TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(true),
                                    child: const Text('Eliminar',
                                        style: TextStyle(
                                            color: AppColors.rosa))),
                              ],
                            ),
                          );
                          if (ok == true && context.mounted) {
                            await postres.eliminarPostre(p.id);
                          }
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