class GuestInfo {
  String uid;
  String name;
  String phone;
  String payed;
  String affiliated;
  bool? checkedIn = false;

  GuestInfo({
    required this.uid,
    required this.name,
    required this.phone,
    required this.payed,
    required this.affiliated,
    this.checkedIn,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'phone': phone,
    'payed': payed,
    'affiliated': affiliated,
    'checked_in': checkedIn,
  };

  factory GuestInfo.fromJson(Map<dynamic, dynamic> json, String a) => GuestInfo(
    uid: a,
    name: json['name'],
    phone: json['phone'],
    payed: json['payed'],
    affiliated: json['affiliated'],
    checkedIn: json['checked_in'],
  );
}
