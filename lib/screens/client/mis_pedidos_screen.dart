import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dulceapp/providers/auth_provider.dart';
import 'package:dulceapp/models/pedido.dart';
import 'package:dulceapp/theme/app_theme.dart';

class MisPedidosScreen extends StatelessWidget {
  const MisPedidosScreen({super.key});

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'pendiente': return AppColors.amarillo;
      case 'confirmado': return AppColors.azul;
      case 'entregado': return Colors.green;
      case 'cancelado': return AppColors.rosa;
      default: return AppColors.textoGris;
    }
  }

  String _textoEstado(String estado) {
    switch (estado) {
      case 'pendiente': return '⏳ Pendiente';
      case 'confirmado': return '✅ Confirmado';
      case 'entregado': return '🎉 Entregado';
      case 'cancelado': return '❌ Cancelado';
      default: return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      appBar: AppBar(title: const Text('Mis pedidos 📋')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pedidos')
            .where('clienteId', isEqualTo: auth.usuario?.uid)
            .orderBy('fechaPedido', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.morado));
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📋', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text('Aún no tienes pedidos',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Haz tu primer pedido desde el catálogo',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }

          final pedidos = snap.data!.docs
              .map((d) =>
                  Pedido.fromMap(d.data() as Map<String, dynamic>, d.id))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pedidos.length,
            itemBuilder: (context, i) {
              final p = pedidos[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'Pedido #${p.id.substring(0, 6).toUpperCase()}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textoOscuro)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _colorEstado(p.estado)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(_textoEstado(p.estado),
                                style: TextStyle(
                                    color: _colorEstado(p.estado),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...p.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${item.cantidad}x ${item.nombre}',
                                    style: const TextStyle(
                                        color: AppColors.textoGris)),
                                Text(
                                    '\$${(item.precio * item.cantidad).toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        color: AppColors.textoGris)),
                              ],
                            ),
                          )),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:',
                              style:
                                  TextStyle(fontWeight: FontWeight.w600)),
                          Text('\$${p.total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.morado,
                                  fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 14, color: AppColors.textoGris),
                          const SizedBox(width: 4),
                          Text(
                            'Entrega: ${p.fechaEntrega.day}/${p.fechaEntrega.month}/${p.fechaEntrega.year}',
                            style: const TextStyle(
                                color: AppColors.textoGris, fontSize: 13),
                          ),
                        ],
                      ),
                      if (p.notas.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text('Nota: ${p.notas}',
                            style: const TextStyle(
                                color: AppColors.textoGris,
                                fontSize: 12,
                                fontStyle: FontStyle.italic)),
                      ],
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