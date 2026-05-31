import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dulceapp/models/postre.dart';

class FavoritosProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Set<String> _favoritosIds = {};

  Set<String> get favoritosIds => _favoritosIds;

  bool esFavorito(String postreId) => _favoritosIds.contains(postreId);

  Future<void> cargarFavoritos(String userId) async {
    final doc = await _db.collection('favoritos').doc(userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      _favoritosIds = Set<String>.from(data['postres'] ?? []);
    } else {
      _favoritosIds = {};
    }
    notifyListeners();
  }

  Future<void> toggleFavorito(String userId, String postreId) async {
    if (_favoritosIds.contains(postreId)) {
      _favoritosIds.remove(postreId);
    } else {
      _favoritosIds.add(postreId);
    }
    notifyListeners();
    await _db.collection('favoritos').doc(userId).set({
      'postres': _favoritosIds.toList(),
    });
  }

  Stream<List<Postre>> streamFavoritos(String userId) {
    return _db
        .collection('favoritos')
        .doc(userId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return [];
      final ids = List<String>.from(doc.data()?['postres'] ?? []);
      if (ids.isEmpty) return [];
      final snaps = await _db
          .collection('postres')
          .where(FieldPath.documentId, whereIn: ids)
          .get();
      return snaps.docs
          .map((d) => Postre.fromMap(d.data(), d.id))
          .toList();
    });
  }
}