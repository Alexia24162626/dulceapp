import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dulceapp/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _usuario;
  bool _cargando = false;
  String? _error;

  UserModel? get usuario => _usuario;
  bool get cargando => _cargando;
  String? get error => _error;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _usuario = null;
    } else {
      final doc = await _db.collection('usuarios').doc(firebaseUser.uid).get();
      if (doc.exists) {
        _usuario = UserModel.fromMap(doc.data()!, firebaseUser.uid);
      }
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _cargando = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mensajeError(e.code);
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registro(String nombre, String email, String password, String rol) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final nuevoUsuario = UserModel(
        uid: cred.user!.uid,
        email: email,
        nombre: nombre,
        rol: rol,
      );
      await _db
          .collection('usuarios')
          .doc(cred.user!.uid)
          .set(nuevoUsuario.toMap());
      _usuario = nuevoUsuario;
      _cargando = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mensajeError(e.code);
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
    _usuario = null;
    notifyListeners();
  }

  String _mensajeError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Ese correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'invalid-email':
        return 'El correo no es válido.';
      default:
        return 'Ocurrió un error. Intenta de nuevo.';
    }
  }
}