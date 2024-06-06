class UserInfoA {
  String uid;
  String name;
  String phone;
  String payed;
  String affiliated;
  bool? checked_in = false;

  UserInfoA({
    required this.uid,
    required this.name,
    required this.phone,
    required this.payed,
    required this.affiliated,
    this.checked_in,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'phone': phone,
    'payed': payed,
    'affiliated': affiliated,
    'checked_in': checked_in,
  };

  factory UserInfoA.fromJson(Map<dynamic, dynamic> json, String a) => UserInfoA(
    uid: a,
    name: json['name'],
    phone: json['phone'],
    payed: json['payed'],
    affiliated: json['affiliated'],
    checked_in: json['checked_in'],
  );
}
