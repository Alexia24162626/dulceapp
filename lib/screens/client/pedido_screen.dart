import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dulceapp/providers/auth_provider.dart';
import 'package:dulceapp/providers/pedido_provider.dart';
import 'package:dulceapp/models/pedido.dart';
import 'package:dulceapp/theme/app_theme.dart';

class PedidoScreen extends StatefulWidget {
  const PedidoScreen({super.key});

  @override
  State<PedidoScreen> createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  DateTime? _fechaSeleccionada;
  final _notasCtrl = TextEditingController();

  @override
  void dispose() {
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmarPedido() async {
    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una fecha de entrega')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final pedidoProvider = context.read<PedidoProvider>();

    if (auth.usuario == null || pedidoProvider.carrito.isEmpty) return;

    final pedido = Pedido(
      id: '',
      clienteId: auth.usuario!.uid,
      clienteNombre: auth.usuario!.nombre,
      items: [],
      total: pedidoProvider.total,
      fechaEntrega: _fechaSeleccionada!,
      fechaPedido: DateTime.now(),
      estado: 'pendiente',
      notas: _notasCtrl.text.trim(),
    );

    await pedidoProvider.crearPedido(pedido);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Pedido enviado exitosamente! 🎉')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedidoProvider = context.watch<PedidoProvider>();
    final carrito = pedidoProvider.carrito;

    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      appBar: AppBar(title: const Text('Mi pedido 🛍️')),
      body: carrito.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🛍️', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text('Tu pedido está vacío',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Agrega postres desde el catálogo',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Productos', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...carrito.map((item) => _ItemCarrito(
                        item: item,
                        onEliminar: () => pedidoProvider.eliminarDelCarrito(item.postreId),
                        onCambiarCantidad: (cantidad) =>
                            pedidoProvider.cambiarCantidad(item.postreId, cantidad),
                      )),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divisor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total:', style: Theme.of(context).textTheme.titleMedium),
                        Text('\$${pedidoProvider.total.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.morado)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Fecha de entrega',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divisor),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.now().add(const Duration(days: 1)),
                      lastDay: DateTime.now().add(const Duration(days: 30)),
                      focusedDay: _fechaSeleccionada ??
                          DateTime.now().add(const Duration(days: 1)),
                      selectedDayPredicate: (day) =>
                          isSameDay(_fechaSeleccionada, day),
                      onDaySelected: (selected, focused) {
                        setState(() => _fechaSeleccionada = selected);
                      },
                      calendarStyle: const CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: AppColors.morado,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: AppColors.moradoClaro,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                    ),
                  ),
                  if (_fechaSeleccionada != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.moradoSuave,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: AppColors.morado, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Entrega: ${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
                            style: const TextStyle(
                                color: AppColors.morado,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text('Notas adicionales (opcional)',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notasCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Ej: sin nueces, dedicatoria, etc.',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: pedidoProvider.cargando ? null : _confirmarPedido,
                      child: pedidoProvider.cargando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Confirmar pedido'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

class _ItemCarrito extends StatelessWidget {
  final ItemCarrito item;
  final VoidCallback onEliminar;
  final Function(int) onCambiarCantidad;

  const _ItemCarrito({
    required this.item,
    required this.onEliminar,
    required this.onCambiarCantidad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divisor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.imagenUrl.isNotEmpty
                ? item.imagenUrl.startsWith('data:')
                    ? Image.memory(
                        base64Decode(item.imagenUrl.split(',')[1]),
                        width: 60, height: 60, fit: BoxFit.cover)
                    : Image.network(item.imagenUrl,
                        width: 60, height: 60, fit: BoxFit.cover)
                : Container(
                    width: 60,
                    height: 60,
                    color: AppColors.moradoSuave,
                    child: const Center(
                        child: Text('🍰', style: TextStyle(fontSize: 24)))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('\$${item.precio.toStringAsFixed(0)} c/u',
                    style: const TextStyle(
                        color: AppColors.textoGris, fontSize: 12)),
                Text('\$${(item.precio * item.cantidad).toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: AppColors.morado,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: AppColors.morado),
                onPressed: () {
                  if (item.cantidad > 1) {
                    onCambiarCantidad(item.cantidad - 1);
                  } else {
                    onEliminar();
                  }
                },
              ),
              Text('${item.cantidad}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.morado),
                onPressed: () => onCambiarCantidad(item.cantidad + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}