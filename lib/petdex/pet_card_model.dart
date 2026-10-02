import 'dart:convert';

enum PetRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
  mythic
}

class PetCardModel {
  final int id;
  final String name;
  final String species;
  final PetRarity rarity;
  final String? description;
  final String? habitat;
  final String? capturedImagePath;
  final bool isCaptured;
  final DateTime? discoveryDate;

  PetCardModel({
    required this.id,
    required this.name,
    required this.species,
    required this.rarity,
    this.description,
    this.habitat,
    this.capturedImagePath,
    this.isCaptured = false,
    this.discoveryDate,
  });

  PetCardModel copyWith({
    String? name,
    String? species,
    PetRarity? rarity,
    String? description,
    String? habitat,
    String? capturedImagePath,
    bool? isCaptured,
    DateTime? discoveryDate,
  }) {
    return PetCardModel(
      id: this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      rarity: rarity ?? this.rarity,
      description: description ?? this.description,
      habitat: habitat ?? this.habitat,
      capturedImagePath: capturedImagePath ?? this.capturedImagePath,
      isCaptured: isCaptured ?? this.isCaptured,
      discoveryDate: discoveryDate ?? this.discoveryDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'rarity': rarity.index,
      'description': description,
      'habitat': habitat,
      'capturedImagePath': capturedImagePath,
      'isCaptured': isCaptured ? 1 : 0,
      'discoveryDate': discoveryDate?.millisecondsSinceEpoch,
    };
  }

  factory PetCardModel.fromMap(Map<String, dynamic> map) {
    return PetCardModel(
      id: map['id'],
      name: map['name'],
      species: map['species'],
      rarity: PetRarity.values[map['rarity'] ?? 0],
      description: map['description'],
      habitat: map['habitat'],
      capturedImagePath: map['capturedImagePath'],
      isCaptured: map['isCaptured'] == 1,
      discoveryDate: map['discoveryDate'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(map['discoveryDate']) 
        : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PetCardModel.fromJson(String source) => PetCardModel.fromMap(json.decode(source));
}
