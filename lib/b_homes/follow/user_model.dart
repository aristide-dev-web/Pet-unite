class UserModel {
  final String id;
  final String nome;
  final String avatarUrl;
  bool seguito;

  UserModel({
    required this.id,
    required this.nome,
    required this.avatarUrl,
    this.seguito = false,
  });
}