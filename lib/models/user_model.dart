enum UserRole { customer, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final UserRole role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone = '',
    this.role = UserRole.customer,
  });
}

