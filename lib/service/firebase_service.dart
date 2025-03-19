import 'package:firebase_database/firebase_database.dart';

import '../model/guest_info.dart';

class FirebaseService {
  static String addGuest(
      String name, String phone, String payed, String affiliated) {
    FirebaseDatabase db = FirebaseDatabase.instance;

    Map<String, dynamic> guestData = {
      'name': name,
      'phone': phone,
      'payed': payed,
      'affiliated': affiliated,
      'checked_in': false,
    };

    var key = db.ref("convidados").push();

    key.set(guestData).then((value) => print("Cadastrado com sucesso!"));

    return key.key!;
  }

  static String editGuest(String uid, String name, String phone, String payed,
      String affiliated, bool checkedIn) {
    FirebaseDatabase db = FirebaseDatabase.instance;

    Map<String, dynamic> guestData = {
      'name': name,
      'phone': phone,
      'payed': payed,
      'affiliated': affiliated,
      'checked_in': checkedIn,
    };

    var key = db.ref("convidados").child(uid);

    key.set(guestData).then((value) => print("Cadastrado com sucesso!"));

    return key.key!;
  }
}
