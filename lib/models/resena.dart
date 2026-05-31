class Resena {
  final String id;
  final String postreId;
  final String clienteId;
  final String clienteNombre;
  final double estrellas;
  final String comentario;
  final DateTime fecha;

  Resena({
    required this.id,
    required this.postreId,
    required this.clienteId,
    required this.clienteNombre,
    required this.estrellas,
    required this.comentario,
    required this.fecha,
  });

  factory Resena.fromMap(Map<String, dynamic> map, String id) {
    return Resena(
      id: id,
      postreId: map['postreId'] ?? '',
      clienteId: map['clienteId'] ?? '',
      clienteNombre: map['clienteNombre'] ?? '',
      estrellas: (map['estrellas'] ?? 0).toDouble(),
      comentario: map['comentario'] ?? '',
      fecha: DateTime.parse(map['fecha']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postreId': postreId,
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'estrellas': estrellas,
      'comentario': comentario,
      'fecha': fecha.toIso8601String(),
    };
  }
}