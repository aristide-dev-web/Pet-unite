import 'package:petping/petdex/pet_card_model.dart';

final List<PetCardModel> exoticCards = [
  PetCardModel(
    id: 2001,
    name: "Pappagallo Cenerino",
    species: "Uccello",
    rarity: PetRarity.rare,
    description: "Uno degli uccelli più intelligenti, capace di imitare la voce umana.",
    habitat: "Foreste pluviali, ora comune in casa",
  ),
  PetCardModel(
    id: 2002,
    name: "Iguana Dai Corni",
    species: "Rettile",
    rarity: PetRarity.epic,
    description: "Un rettile maestoso che sembra un piccolo drago preistorico.",
    habitat: "Zone tropicali",
  ),
  PetCardModel(
    id: 3001,
    name: "Axolotl",
    species: "Anfibio",
    rarity: PetRarity.mythic,
    description: "La salamandra messicana che sorride sempre e può rigenerare parti del corpo.",
    habitat: "Laghi del Messico",
  ),
];
