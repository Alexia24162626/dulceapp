import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dulceapp/models/postre.dart';
import 'package:dulceapp/models/resena.dart';
import 'package:dulceapp/providers/auth_provider.dart';
import 'package:dulceapp/providers/postre_provider.dart';
import 'package:dulceapp/providers/favoritos_provider.dart';
import 'package:dulceapp/providers/pedido_provider.dart';
import 'package:dulceapp/theme/app_theme.dart';

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
    height: height ?? 260,
    width: double.infinity,
    color: AppColors.moradoSuave,
    child: const Center(
      child: Text('🍰', style: TextStyle(fontSize: 80)),
    ),
  );
}

class DetallePostreScreen extends StatefulWidget {
  final String postreId;
  const DetallePostreScreen({super.key, required this.postreId});

  @override
  State<DetallePostreScreen> createState() => _DetallePostreScreenState();
}

class _DetallePostreScreenState extends State<DetallePostreScreen> {
  final _comentarioCtrl = TextEditingController();
  double _estrellas = 5;
  bool _enviandoResena = false;

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarResena(Postre postre) async {
    final auth = context.read<AuthProvider>();
    if (auth.usuario == null || _comentarioCtrl.text.trim().isEmpty) return;

    setState(() => _enviandoResena = true);
    final db = FirebaseFirestore.instance;
    final resena = Resena(
      id: '',
      postreId: postre.id,
      clienteId: auth.usuario!.uid,
      clienteNombre: auth.usuario!.nombre,
      estrellas: _estrellas,
      comentario: _comentarioCtrl.text.trim(),
      fecha: DateTime.now(),
    );

    await db.collection('resenas').add(resena.toMap());

    final snap = await db
        .collection('resenas')
        .where('postreId', isEqualTo: postre.id)
        .get();
    final total = snap.docs.length;
    final suma = snap.docs.fold<double>(
        0, (s, d) => s + (d.data()['estrellas'] as num).toDouble());
    await db.collection('postres').doc(postre.id).update({
      'calificacionPromedio': suma / total,
      'totalResenas': total,
    });

    if (mounted) {
      _comentarioCtrl.clear();
      setState(() => _enviandoResena = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Reseña enviada!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final postres = context.read<PostreProvider>();
    final favs = context.watch<FavoritosProvider>();
    final auth = context.read<AuthProvider>();
    final pedido = context.read<PedidoProvider>();

    return FutureBuilder<Postre?>(
      future: postres.obtenerPostre(widget.postreId),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(color: AppColors.morado)),
          );
        }
        final postre = snap.data!;
        final esFav = favs.esFavorito(postre.id);

        return Scaffold(
          backgroundColor: AppColors.fondoPrincipal,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: AppColors.morado,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildImagen(postre.imagenUrl, height: 260),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      esFav ? Icons.favorite : Icons.favorite_border,
                      color: esFav ? AppColors.rosa : Colors.white,
                    ),
                    onPressed: () {
                      if (auth.usuario != null) {
                        favs.toggleFavorito(auth.usuario!.uid, postre.id);
                      }
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(postre.nombre,
                                style:
                                    Theme.of(context).textTheme.displayMedium),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.morado,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '\$${postre.precio.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (postre.totalResenas > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: AppColors.amarillo, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${postre.calificacionPromedio.toStringAsFixed(1)} (${postre.totalResenas} reseñas)',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(postre.descripcion,
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: const Text('Agregar al pedido'),
                          onPressed: () {
                            pedido.agregarAlCarrito(postre);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${postre.nombre} agregado al pedido'),
                                action: SnackBarAction(
                                  label: 'Ver pedido',
                                  onPressed: () =>
                                      Navigator.of(context).pop(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text('Reseñas',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divisor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Deja tu reseña',
                                style:
                                    Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 12),
                            RatingBar.builder(
                              initialRating: _estrellas,
                              minRating: 1,
                              itemSize: 32,
                              itemBuilder: (_, __) => const Icon(
                                Icons.star,
                                color: AppColors.amarillo,
                              ),
                              onRatingUpdate: (r) =>
                                  setState(() => _estrellas = r),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _comentarioCtrl,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Escribe tu comentario...',
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _enviandoResena
                                    ? null
                                    : () => _enviarResena(postre),
                                child: _enviandoResena
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.morado),
                                      )
                                    : const Text('Enviar reseña'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('resenas')
                            .where('postreId', isEqualTo: postre.id)
                            .orderBy('fecha', descending: true)
                            .snapshots(),
                        builder: (context, snap) {
                          if (!snap.hasData || snap.data!.docs.isEmpty) {
                            return Center(
                              child: Text(
                                  'Sé el primero en reseñar este postre',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            );
                          }
                          return Column(
                            children: snap.data!.docs.map((doc) {
                              final r = Resena.fromMap(
                                  doc.data() as Map<String, dynamic>, doc.id);
                              return _ResenaCard(resena: r);
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResenaCard extends StatelessWidget {
  final Resena resena;
  const _ResenaCard({required this.resena});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divisor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(resena.clienteNombre,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textoOscuro)),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < resena.estrellas ? Icons.star : Icons.star_border,
                    color: AppColors.amarillo,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(resena.comentario,
              style: const TextStyle(
                  color: AppColors.textoGris, fontSize: 13)),
        ],
      ),
    );
  }
}