class ProfileModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? avatarBase64;
  final String address;
  final String website;
  final String company;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarBase64, required this.address,required this.website, required this.company
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final imageData = json['image_1920'];

    String? avatar;

    if (imageData is Map<String, dynamic>) {
      avatar = imageData['content'] is String
          ? imageData['content'] as String
          : null;
    } else if (imageData is String) {
      avatar = imageData;
    }

    return ProfileModel(
      id: json['id'] as int,
      name: json['name'] is String ? json['name'] : '',
      email: json['email'] is String ? json['email'] : '',
      phone: json['phone'] is String ? json['phone'] : '',
      address: json['address'] is String ? json['address'] : '',
      website: json['website'] is String ? json['website'] : '',
      company: json['commercial_company_name'] is String ? json['commercial_company_name'] : '',
      avatarBase64: avatar,
    );
  }

}
