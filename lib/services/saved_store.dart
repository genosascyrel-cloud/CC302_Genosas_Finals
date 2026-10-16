import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/place.dart';

/// Holds the user's saved trip list and persists it on the device.
class SavedStore extends ChangeNotifier {
  static const _key = 'saved_places';
  final List<Place> _items = [];

  List<Place> get items => List.unmodifiable(_items);
  bool isSaved(String id) => _items.any((p) => p.id == id);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        _items
          ..clear()
          ..addAll((jsonDecode(raw) as List)
              .map((e) => Place.fromJson(e as Map<String, dynamic>)));
      }
    } catch (_) {}
    notifyListeners();
  }

  /// Returns true if the place is saved after the call.
  bool toggle(Place p) {
    if (isSaved(p.id)) {
      remove(p.id);
      return false;
    }
    add(p);
    return true;
  }

  void add(Place p) {
    _items.insert(0, p);
    _commit();
  }

  /// DELETE: returns the old index so the action can be undone.
  int remove(String id) {
    final i = _items.indexWhere((p) => p.id == id);
    if (i >= 0) {
      _items.removeAt(i);
      _commit();
    }
    return i;
  }

  void restore(Place p, int index) {
    _items.insert(index.clamp(0, _items.length), p);
    _commit();
  }

  void updateNote(String id, String note) {
    final i = _items.indexWhere((p) => p.id == id);
    if (i >= 0) {
      _items[i] = _items[i].copyWith(note: note);
      _commit();
    }
  }

  void _commit() {
    notifyListeners();
    _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_items.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }
}

final savedStore = SavedStore();
