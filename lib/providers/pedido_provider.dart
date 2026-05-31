import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dulceapp/models/pedido.dart';
import 'package:dulceapp/models/postre.dart';

class ItemCarrito {
  final String postreId;
  final String nombre;
  final double precio;
  final String imagenUrl;
  int cantidad;

  ItemCarrito({
    required this.postreId,
    required this.nombre,
    required this.precio,
    required this.imagenUrl,
    this.cantidad = 1,
  });

  Map<String, dynamic> toMap() => {
        'postreId': postreId,
        'nombre': nombre,
        'precio': precio,
        'imagenUrl': imagenUrl,
        'cantidad': cantidad,
      };
}

class PedidoProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final List<ItemCarrito> _carrito = [];
  bool _cargando = false;

  List<ItemCarrito> get carrito => _carrito;
  bool get cargando => _cargando;

  double get total => _carrito.fold(0, (s, i) => s + (i.precio * i.cantidad));

  void agregarAlCarrito(Postre postre) {
    final existe = _carrito.where((i) => i.postreId == postre.id);
    if (existe.isNotEmpty) {
      existe.first.cantidad++;
    } else {
      _carrito.add(ItemCarrito(
        postreId: postre.id,
        nombre: postre.nombre,
        precio: postre.precio,
        imagenUrl: postre.imagenUrl,
      ));
    }
    notifyListeners();
  }

  void eliminarDelCarrito(String postreId) {
    _carrito.removeWhere((i) => i.postreId == postreId);
    notifyListeners();
  }

  void cambiarCantidad(String postreId, int cantidad) {
    final item = _carrito.where((i) => i.postreId == postreId);
    if (item.isNotEmpty) {
      item.first.cantidad = cantidad;
      notifyListeners();
    }
  }

  void limpiarCarrito() {
    _carrito.clear();
    notifyListeners();
  }

  Future<void> crearPedido(Pedido pedido) async {
    _cargando = true;
    notifyListeners();
    try {
      await _db.collection('pedidos').add({
        'clienteId': pedido.clienteId,
        'clienteNombre': pedido.clienteNombre,
        'items': _carrito.map((i) => i.toMap()).toList(),
        'total': pedido.total,
        'fechaEntrega': pedido.fechaEntrega.toIso8601String(),
        'fechaPedido': pedido.fechaPedido.toIso8601String(),
        'estado': pedido.estado,
        'notas': pedido.notas,
      });
      limpiarCarrito();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}