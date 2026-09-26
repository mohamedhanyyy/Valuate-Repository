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
  final String? avatarPath;
  final bool isGuest;

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
    this.avatarPath,
    this.isGuest = false,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    if (name.isEmpty && isGuest) {
      return 'Guest User';
    }
    return name;
  }

  factory UserModel.guest({String currency = 'SAR', String unit = 'sqm'}) {
    return UserModel(
      id: 'guest_user',
      firstName: 'Guest',
      lastName: 'User',
      email: '',
      companyName: 'Valuate Intelligence',
      phone: '',
      token: 'val_guest_token',
      preferredCurrency: currency,
      preferredUnit: unit,
      isGuest: true,
    );
  }

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
      avatarPath: json['avatar_path'] ?? json['avatarPath'],
      isGuest: json['is_guest'] as bool? ?? false,
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
      'avatar_path': avatarPath,
      'is_guest': isGuest,
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
    String? avatarPath,
    bool? isGuest,
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
      avatarPath: avatarPath ?? this.avatarPath,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}
