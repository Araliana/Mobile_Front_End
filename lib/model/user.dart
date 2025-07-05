class User {
  String email;
  String? profilePic;
  String fullname;
  String countryCode;
  String dialCode;
  String phone;
  String password;
  String? birthDate;
  String? gender;
  int? rating;
  final DateTime createdAt = DateTime.now();
  double balance = 0;
  bool isMember = false;
  bool twoFactor = false;
  DateTime? memberSince;
  DateTime? memberUntil;

  User({
    required this.email,
    this.profilePic,
    required this.fullname,
    required this.countryCode,
    required this.dialCode,
    required this.phone,
    required this.password,
    DateTime? createdAt,
  });

  User call() {
    return this;
  }

  @override
  bool operator ==(Object other) {
    return other is User && other.email == email;
  }

  int changePassword(String oldPass, String newPass) {
    if (password != oldPass) return -1;
    if (password == newPass) return 0;
    password = newPass;
    return 1;
  }

  int resetPassword(String newPass) {
    if (password == newPass) return 0;
    password = newPass;
    return 1;
  }

  void rateApp(int rate) {
    rating = rate;
  }

  void setUp2Fac() {
    twoFactor = true;
  }

  void editProfile({
    required String newFullname,
    required String newEmail,
    required String newPhone,
    required String newCountryCode,
    required String newDialCode,
    String? newBirthDate,
    String? newGender,
    String? newProfilePic,
  }) {
    email = newEmail;
    fullname = newFullname;
    phone = newPhone;
    countryCode = newCountryCode;
    dialCode = newDialCode;
    birthDate = newBirthDate;
    gender = newGender;
    profilePic = newProfilePic;
  }

  int joinMember({required MemberType type, required double nominal}) {
    if (purchase(nominal) == -1) return -1;
    memberSince = DateTime.now();
    switch (type) {
      case MemberType.monthly:
        memberUntil = DateTime.now().add(Duration(days: 30));
        break;

      case MemberType.seasonal:
        memberUntil = DateTime.now().add(Duration(days: 90));
        break;

      case MemberType.annual:
        memberUntil = DateTime.now().add(Duration(days: 365));
        break;
    }
    isMember = true;
    return 1;
  }

  bool checkStatusMember() {
    if (memberUntil == null) {
      isMember = false;
      return false;
    }
    if (DateTime.now().isAfter(memberUntil!)) {
      isMember = false;
      return false;
    }
    isMember = true;
    return true;
  }

  void topUp(double nominal) {
    balance += nominal;
  }

  int purchase(double nominal, [bool allowedMinus = false]) {
    if (nominal > balance && !allowedMinus) {
      return -1;
    }
    balance -= nominal;
    return 1;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    data['email'] = email;
    data['fullname'] = fullname;
    data['countryCode'] = countryCode;
    data['dialCode'] = dialCode;
    data['phone'] = phone;
    data['password'] = password;
    data['createdAt'] = createdAt.toIso8601String();
    data['balance'] = balance;
    data['isMember'] = isMember;
    data['twoFactor'] = twoFactor;

    if (profilePic != null) data['profilePic'] = profilePic;
    if (birthDate != null) data['birthDate'] = birthDate;
    if (gender != null) data['gender'] = gender;
    if (rating != null) data['rating'] = rating;
    if (memberSince != null) {
      data['memberSince'] = memberSince!.toIso8601String();
    }
    if (memberUntil != null) {
      data['memberUntil'] = memberUntil!.toIso8601String();
    }

    return data;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final user = User(
      email: json['email'],
      profilePic: json['profilePic'],
      fullname: json['fullname'],
      countryCode: json['countryCode'],
      dialCode: json['dialCode'],
      phone: json['phone'],
      password: json['password'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
    );

    user.birthDate = json['birthDate'];
    user.gender = json['gender'];
    user.rating = json['rating'];
    user.balance = (json['balance'] as num?)?.toDouble() ?? 0;
    user.isMember = json['isMember'] ?? false;
    user.twoFactor = json['twoFactor'] ?? false;
    user.memberSince =
        json['memberSince'] != null
            ? DateTime.parse(json['memberSince'])
            : null;
    user.memberUntil =
        json['memberUntil'] != null
            ? DateTime.parse(json['memberUntil'])
            : null;

    return user;
  }
}

enum MemberType { monthly, seasonal, annual }
