class ItemPedido {
  final String postreId;
  final String nombre;
  final double precio;
  final String imagenUrl;
  final int cantidad;

  ItemPedido({
    required this.postreId,
    required this.nombre,
    required this.precio,
    required this.imagenUrl,
    required this.cantidad,
  });

  Map<String, dynamic> toMap() => {
        'postreId': postreId,
        'nombre': nombre,
        'precio': precio,
        'imagenUrl': imagenUrl,
        'cantidad': cantidad,
      };

  factory ItemPedido.fromMap(Map<String, dynamic> map) => ItemPedido(
        postreId: map['postreId'] ?? '',
        nombre: map['nombre'] ?? '',
        precio: (map['precio'] as num).toDouble(),
        imagenUrl: map['imagenUrl'] ?? '',
        cantidad: map['cantidad'] ?? 1,
      );
}

class Pedido {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final List<ItemPedido> items;
  final double total;
  final DateTime fechaEntrega;
  final DateTime fechaPedido;
  final String estado;
  final String notas;

  Pedido({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.items,
    required this.total,
    required this.fechaEntrega,
    required this.fechaPedido,
    required this.estado,
    required this.notas,
  });

  Map<String, dynamic> toMap() => {
        'clienteId': clienteId,
        'clienteNombre': clienteNombre,
        'items': items.map((i) => i.toMap()).toList(),
        'total': total,
        'fechaEntrega': fechaEntrega.toIso8601String(),
        'fechaPedido': fechaPedido.toIso8601String(),
        'estado': estado,
        'notas': notas,
      };

  factory Pedido.fromMap(Map<String, dynamic> map, String id) => Pedido(
        id: id,
        clienteId: map['clienteId'] ?? '',
        clienteNombre: map['clienteNombre'] ?? '',
        items: (map['items'] as List<dynamic>? ?? [])
            .map((i) => ItemPedido.fromMap(i as Map<String, dynamic>))
            .toList(),
        total: (map['total'] as num).toDouble(),
        fechaEntrega: DateTime.parse(map['fechaEntrega']),
        fechaPedido: DateTime.parse(map['fechaPedido']),
        estado: map['estado'] ?? 'pendiente',
        notas: map['notas'] ?? '',
      );
}