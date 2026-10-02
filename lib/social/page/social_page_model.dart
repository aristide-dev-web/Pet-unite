import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'social_page_model.g.dart';

@HiveType(typeId: 6)
class SocialPage extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String creatorId;
  @HiveField(2)
  final String nome;
  @HiveField(3)
  final String categoria;
  @HiveField(4)
  final String? bio;
  @HiveField(5)
  final String? fotoProfilo;
  @HiveField(6)
  final String? fotoCopertina;
  @HiveField(7)
  final List<String> adminIds;
  @HiveField(8)
  final List<String> followerIds;
  @HiveField(9)
  final DateTime? createdAt;

  SocialPage({
    required this.id,
    required this.creatorId,
    required this.nome,
    required this.categoria,
    this.bio,
    this.fotoProfilo,
    this.fotoCopertina,
    required this.adminIds,
    required this.followerIds,
    this.createdAt,
  });

  factory SocialPage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SocialPage(
      id: doc.id,
      creatorId: data['creatorId'] ?? '',
      nome: data['nome'] ?? 'Nuova Pagina',
      categoria: data['categoria'] ?? 'Altro',
      bio: data['bio'],
      fotoProfilo: data['fotoProfilo'],
      fotoCopertina: data['fotoCopertina'],
      adminIds: List<String>.from(data['adminIds'] ?? []),
      followerIds: List<String>.from(data['followerIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'creatorId': creatorId,
      'nome': nome,
      'categoria': categoria,
      'bio': bio,
      'fotoProfilo': fotoProfilo,
      'fotoCopertina': fotoCopertina,
      'adminIds': adminIds,
      'followerIds': followerIds,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
