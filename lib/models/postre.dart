class Postre {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagenUrl;
  final bool disponible;
  final double calificacionPromedio;
  final int totalResenas;

  Postre({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
    this.disponible = true,
    this.calificacionPromedio = 0.0,
    this.totalResenas = 0,
  });

  factory Postre.fromMap(Map<String, dynamic> map, String id) {
    return Postre(
      id: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      imagenUrl: map['imagenUrl'] ?? '',
      disponible: map['disponible'] ?? true,
      calificacionPromedio:
          (map['calificacionPromedio'] ?? 0.0).toDouble(),
      totalResenas: map['totalResenas'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagenUrl': imagenUrl,
      'disponible': disponible,
      'calificacionPromedio': calificacionPromedio,
      'totalResenas': totalResenas,
    };
  }

  Postre copyWith({
    String? nombre,
    String? descripcion,
    double? precio,
    String? imagenUrl,
    bool? disponible,
    double? calificacionPromedio,
    int? totalResenas,
  }) {
    return Postre(
      id: id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      disponible: disponible ?? this.disponible,
      calificacionPromedio:
          calificacionPromedio ?? this.calificacionPromedio,
      totalResenas: totalResenas ?? this.totalResenas,
    );
  }
}