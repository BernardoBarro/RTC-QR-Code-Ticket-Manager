import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/user_info.dart';

class AnotationProvider extends ChangeNotifier {
  List<UserInfoA> _anotations = [];
  final _db = FirebaseDatabase.instance.ref("convidados");

  late StreamSubscription<DatabaseEvent> _anotationsStream;

  List<UserInfoA> get anotation => _anotations;

  AnotationProvider() {
    _listenToAnotations();
  }

  void _listenToAnotations() {
    _anotationsStream = _db
        .onValue
        .listen((event) async {
      if (event.snapshot.value != null) {
        final allAnotations =
        Map<String, dynamic>.from(event.snapshot.value as dynamic);
        final List<UserInfoA> loadedItems = [];
        for (var entry in allAnotations.entries) {
          final key = entry.key;
          final value = entry.value;
          loadedItems.add(UserInfoA(
            uid: key,
            name: value['name'],
            phone: value['phone'],
            payed: value['payed'],
            affiliated: value['affiliated'],
            checked_in: value['checked_in'] == null ? false : value['checked_in'],
          ));
        }
        loadedItems.sort((a, b) => _comparePriority(a, b));
        _anotations = loadedItems;
        notifyListeners();
      }
    });
  }

  int _comparePriority(UserInfoA a, UserInfoA b) {
    // Atribui pontos baseado nas condições
    int scoreA = _getPriorityScore(a);
    int scoreB = _getPriorityScore(b);
    return scoreA.compareTo(scoreB);
  }

  int _getPriorityScore(UserInfoA user) {
    if (user.checked_in! && user.payed == 'Não ⚠️') {
      return 1; // Maior prioridade
    } else if (!user.checked_in! && user.payed == 'Não ⚠️') {
      return 2;
    } else if (!user.checked_in! && user.payed == 'Sim ✅') {
      return 3;
    } else if (user.checked_in! && user.payed == 'Sim ✅') {
      return 4; // Menor prioridade
    }
    return 5; // Caso algum caso inesperado ocorra, coloca no fim
  }

  void delete(UserInfoA anotation) async {
    _db.child(anotation.uid!).remove();
    this.anotation.removeWhere((item) => item.uid == anotation.uid);
    notifyListeners();
  }

  @override
  void dispose() {
    _anotationsStream.cancel();
    super.dispose();
  }

  void clearData() {
    _anotations = [];
    notifyListeners();
  }
}