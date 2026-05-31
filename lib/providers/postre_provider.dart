import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dulceapp/models/postre.dart';

class PostreProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  Stream<List<Postre>> streamPostres() {
    return _db.collection('postres').snapshots().map((snap) =>
        snap.docs.map((d) => Postre.fromMap(d.data(), d.id)).toList());
  }

  Future<Postre?> obtenerPostre(String id) async {
    final doc = await _db.collection('postres').doc(id).get();
    if (!doc.exists) return null;
    return Postre.fromMap(doc.data()!, doc.id);
  }

  Future<void> agregarPostre(Postre postre) async {
    await _db.collection('postres').add(postre.toMap());
  }

  Future<void> actualizarPostre(Postre postre) async {
    await _db.collection('postres').doc(postre.id).update(postre.toMap());
  }

  Future<void> eliminarPostre(String id) async {
    await _db.collection('postres').doc(id).delete();
  }
}