import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:dulceapp/providers/auth_provider.dart';
import 'package:dulceapp/providers/postre_provider.dart';
import 'package:dulceapp/providers/favoritos_provider.dart';
import 'package:dulceapp/models/postre.dart';
import 'package:dulceapp/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().usuario;
      if (user != null) {
        context.read<FavoritosProvider>().cargarFavoritos(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final postres = context.watch<PostreProvider>();

    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DulceApp 🍰'),
            Text(
              'Hola, ${auth.usuario?.nombre.split(' ').first ?? ''}!',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
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
      body: StreamBuilder<List<Postre>>(
        stream: postres.streamPostres(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.morado),
            );
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🍰', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text('Pronto habrá postres disponibles',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            );
          }

          final lista = snap.data!;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text('Nuestros postres',
                      style: Theme.of(context).textTheme.displayMedium),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _PostreCard(postre: lista[i]),
                    childCount: lista.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }
}

Widget _buildImagen(String url, {double? height, BoxFit fit = BoxFit.cover}) {
  if (url.isEmpty) return _placeholderImagen(height: height);
  if (url.startsWith('data:')) {
    try {
      final bytes = base64Decode(url.split(',')[1]);
      return Image.memory(bytes,
          height: height, width: double.infinity, fit: fit);
    } catch (_) {
      return _placeholderImagen(height: height);
    }
  }
  return Image.network(url,
      height: height,
      width: double.infinity,
      fit: fit,
      errorBuilder: (_, __, ___) => _placeholderImagen(height: height));
}

Widget _placeholderImagen({double? height}) {
  return Container(
    height: height ?? 130,
    width: double.infinity,
    color: AppColors.moradoSuave,
    child: const Center(
      child: Text('🍰', style: TextStyle(fontSize: 48)),
    ),
  );
}

class _PostreCard extends StatelessWidget {
  final Postre postre;
  const _PostreCard({required this.postre});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritosProvider>();
    final auth = context.read<AuthProvider>();
    final esFav = favs.esFavorito(postre.id);

    return GestureDetector(
      onTap: () => context.push('/postre/${postre.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.morado.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  _buildImagen(postre.imagenUrl, height: 130),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () {
                        if (auth.usuario != null) {
                          favs.toggleFavorito(auth.usuario!.uid, postre.id);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          esFav ? Icons.favorite : Icons.favorite_border,
                          color: esFav ? AppColors.rosa : AppColors.textoGris,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(postre.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.textoOscuro,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(postre.descripcion,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textoGris),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${postre.precio.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.morado,
                          )),
                      if (postre.totalResenas > 0)
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: AppColors.amarillo, size: 13),
                            const SizedBox(width: 2),
                            Text(
                              postre.calificacionPromedio.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textoGris),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}