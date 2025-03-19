import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';

import '../model/guest_info.dart';

class GuestsProvider extends ChangeNotifier {
  List<GuestInfo> _guests = [];
  final _db = FirebaseDatabase.instance.ref("convidados");

  late StreamSubscription<DatabaseEvent> _guestsStream;

  List<GuestInfo> get guest => _guests;

  GuestsProvider() {
    _listenToGuests();
  }

  void _listenToGuests() {
    _guestsStream = _db
        .onValue
        .listen((event) async {
      if (event.snapshot.value != null) {
        final allGuests =
        Map<String, dynamic>.from(event.snapshot.value as dynamic);
        final List<GuestInfo> loadedItems = [];
        for (var entry in allGuests.entries) {
          final key = entry.key;
          final value = entry.value;
          loadedItems.add(GuestInfo(
            uid: key,
            name: value['name'],
            phone: value['phone'],
            payed: value['payed'],
            affiliated: value['affiliated'],
            checkedIn: value['checked_in'] ?? false,
          ));
        }
        _guests = loadedItems;
        notifyListeners();
      }
    });
  }

  void delete(GuestInfo guest) async {
    _db.child(guest.uid).remove();
    this.guest.removeWhere((item) => item.uid == guest.uid);
    notifyListeners();
  }

  @override
  void dispose() {
    _guestsStream.cancel();
    super.dispose();
  }

  void clearData() {
    _guests = [];
    notifyListeners();
  }
}