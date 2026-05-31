class UserModel {
  final String uid;
  final String email;
  final String nombre;
  final String rol; // 'cliente' o 'dueno'
  final String? fotoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.rol,
    this.fotoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      nombre: map['nombre'] ?? '',
      rol: map['rol'] ?? 'cliente',
      fotoUrl: map['fotoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nombre': nombre,
      'rol': rol,
      'fotoUrl': fotoUrl,
    };
  }
}