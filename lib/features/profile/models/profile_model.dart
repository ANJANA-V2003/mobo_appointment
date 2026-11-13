class ProfileModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? avatarBase64;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarBase64,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int,
      name: json['name'] is String ? json['name'] : '',
      email: json['email'] is String? json['email']:'',
      phone: json['phone'] is String? json['phone']:'',
      avatarBase64: json['image_1920'] is String ? json['image_1920'] : null,
    );
  }
}
