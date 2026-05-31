import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dulceapp/models/pedido.dart';
import 'package:dulceapp/theme/app_theme.dart';

class GestionProductosScreen extends StatelessWidget {
  const GestionProductosScreen({super.key});

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'pendiente': return AppColors.amarillo;
      case 'confirmado': return AppColors.azul;
      case 'entregado': return Colors.green;
      case 'cancelado': return AppColors.rosa;
      default: return AppColors.textoGris;
    }
  }

  Future<void> _cambiarEstado(String pedidoId, String nuevoEstado) async {
    await FirebaseFirestore.instance
        .collection('pedidos')
        .doc(pedidoId)
        .update({'estado': nuevoEstado});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      appBar: AppBar(title: const Text('Pedidos recibidos 📦')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pedidos')
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
                  const Text('📦', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text('Aún no hay pedidos',
                      style: Theme.of(context).textTheme.titleMedium),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.clienteNombre,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.textoOscuro)),
                              Text(
                                  '#${p.id.substring(0, 6).toUpperCase()}',
                                  style: const TextStyle(
                                      color: AppColors.textoGris,
                                      fontSize: 12)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _colorEstado(p.estado)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(p.estado.toUpperCase(),
                                style: TextStyle(
                                    color: _colorEstado(p.estado),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                              style: TextStyle(fontWeight: FontWeight.w600)),
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
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            'pendiente',
                            'confirmado',
                            'entregado',
                            'cancelado'
                          ]
                              .map((estado) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: p.estado != estado
                                          ? () => _cambiarEstado(p.id, estado)
                                          : null,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: p.estado == estado
                                              ? _colorEstado(estado)
                                              : _colorEstado(estado)
                                                  .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: _colorEstado(estado),
                                              width: 1),
                                        ),
                                        child: Text(
                                          estado[0].toUpperCase() +
                                              estado.substring(1),
                                          style: TextStyle(
                                            color: p.estado == estado
                                                ? Colors.white
                                                : _colorEstado(estado),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
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