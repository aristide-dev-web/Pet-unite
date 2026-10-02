import 'package:petping/petdex/pet_card_model.dart';

final List<PetCardModel> zebraCards = [
  PetCardModel(
    id: 24001,
    name: "Zebra delle Pianure (Burchell)",
    species: "Zebra",
    rarity: PetRarity.common,
    description: "La specie di zebra più diffusa, con strisce larghe che si estendono sotto il ventre.",
    habitat: "Savane e praterie dell'Africa orientale e meridionale",
  ),
  PetCardModel(
    id: 24002,
    name: "Zebra di Grevy",
    species: "Zebra",
    rarity: PetRarity.epic,
    description: "La più grande delle zebre, con strisce molto sottili e orecchie grandi e arrotondate.",
    habitat: "Zone aride di Etiopia e Kenya",
  ),
  PetCardModel(
    id: 24003,
    name: "Zebra di Montagna del Capo",
    species: "Zebra",
    rarity: PetRarity.rare,
    description: "Più piccola delle altre, vive in zone impervie e non ha strisce sul ventre.",
    habitat: "Regioni montuose del Sudafrica",
  ),
  PetCardModel(
    id: 24004,
    name: "Zebra di Hartmann",
    species: "Zebra",
    rarity: PetRarity.rare,
    description: "Sottospecie della zebra di montagna, agile arrampicatrice dei pendii rocciosi.",
    habitat: "Namibia e Angola",
  ),
  PetCardModel(
    id: 24005,
    name: "Quagga (Estinto/Ricreato)",
    species: "Zebra",
    rarity: PetRarity.mythic,
    description: "Una variante di zebra estinta nel XIX secolo, con strisce solo sulla parte anteriore del corpo.",
    habitat: "Sudafrica (Progetti di recupero in corso)",
  ),
  PetCardModel(
    id: 24006,
    name: "Zebra di Selous",
    species: "Zebra",
    rarity: PetRarity.uncommon,
    description: "Rara sottospecie nota per le sue strisce nere nette su sfondo bianco pulito.",
    habitat: "Sud-est dell'Africa",
  ),
];
