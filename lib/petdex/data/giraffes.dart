import 'package:petping/petdex/pet_card_model.dart';

final List<PetCardModel> giraffeCards = [
  PetCardModel(
    id: 23001,
    name: "Giraffa Reticolata",
    species: "Giraffa",
    rarity: PetRarity.rare,
    description: "La giraffa più comune negli zoo, nota per il suo mantello a macchie poligonali ben definite.",
    habitat: "Savane del Kenya e Somalia",
  ),
  PetCardModel(
    id: 23002,
    name: "Giraffa Masai",
    species: "Giraffa",
    rarity: PetRarity.rare,
    description: "La più grande delle sottospecie, con macchie sfrangiate che sembrano foglie di vite.",
    habitat: "Savane di Kenya e Tanzania",
  ),
  PetCardModel(
    id: 23003,
    name: "Giraffa di Rothschild",
    species: "Giraffa",
    rarity: PetRarity.epic,
    description: "Una delle più minacciate, si distingue perché non ha macchie sulla parte inferiore delle zampe.",
    habitat: "Uganda e Kenya",
  ),
  PetCardModel(
    id: 23004,
    name: "Giraffa dell'Angola",
    species: "Giraffa",
    rarity: PetRarity.uncommon,
    description: "Possiede macchie grandi che arrivano fino agli zoccoli.",
    habitat: "Namibia e Angola",
  ),
  PetCardModel(
    id: 23005,
    name: "Okapi",
    species: "Giraffa", // Tassonomicamente è l'unico parente vivente della giraffa
    rarity: PetRarity.mythic,
    description: "Il 'fossile vivente' della foresta, sembra un incrocio tra una giraffa e una zebra.",
    habitat: "Foreste pluviali del Congo",
  ),
];
