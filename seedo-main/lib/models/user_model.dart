class UserModel {
  final int id;
  String firstName;
  String lastName;
  String email;
  String password;
  String uid;
  String date;
  String lieunaissance;
  String adress;
  String role;
  String profil;
  bool activated;
  bool notifiable;
  String phone;
  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.uid,
    required this.date,
    required this.lieunaissance,
    required this.adress,
    required this.role,
    required this.profil,
    required this.activated,
    required this.notifiable,
    required this.phone,
  });
  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      firstName: map['firstName'].toString(),
      lastName: map['lastName'].toString(),
      email: map['email'].toString(),
      password: map['password'].toString(),
      uid: map['uid'].toString(),
      date: map['date'].toString(),
      lieunaissance: map['lieunaissance'].toString(),
      adress: map['adress'].toString(),
      role: map['role'],
      profil: map['profil'],
      activated: map['activated'] ?? false,
      notifiable: map['notifiable'] ?? false,
      phone: map['phone'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'uid': uid,
      'date': date,
      'lieunaissance': lieunaissance,
      'adress': adress,
      'role': role,
      'profil': profil,
      'activated': activated,
      'notifiable': notifiable,
      'phone': phone,
    };
  }

  static List<UserModel> fromJsonList(List<dynamic> list) {
    return list.map((item) => UserModel.fromJson(item)).toList();
  }
}
