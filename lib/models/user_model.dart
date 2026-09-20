class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String companyName;
  final String phone;
  final String? token;
  final String preferredCurrency;
  final String preferredUnit;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.companyName,
    required this.phone,
    this.token,
    this.preferredCurrency = 'SAR',
    this.preferredUnit = 'sqm',
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      email: json['email'] ?? '',
      companyName: json['company_name'] ?? json['companyName'] ?? '',
      phone: json['phone'] ?? '',
      token: json['token'],
      preferredCurrency: json['preferred_currency'] ?? json['currency'] ?? 'SAR',
      preferredUnit: json['preferred_unit'] ?? json['unit'] ?? 'sqm',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'company_name': companyName,
      'phone': phone,
      'token': token,
      'preferred_currency': preferredCurrency,
      'preferred_unit': preferredUnit,
    };
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? companyName,
    String? phone,
    String? token,
    String? preferredCurrency,
    String? preferredUnit,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      token: token ?? this.token,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      preferredUnit: preferredUnit ?? this.preferredUnit,
    );
  }
}
