import 'package:petping/petdex/pet_card_model.dart';
import 'dogs.dart';
import 'cats.dart';
import 'exotic.dart';
import 'small_pets.dart';
import 'horses.dart';
import 'birds.dart';
import 'reptiles.dart';
import 'farm.dart';
import 'fishes.dart';
import 'sharks.dart';
import 'whales.dart';
import 'rays.dart';
import 'seahorses.dart';
import 'bats.dart';
import 'rodents.dart';
import 'insects.dart';
import 'wildlife.dart';
import 'elephants.dart';
import 'giraffes.dart';
import 'zebras.dart';
import 'kangaroos.dart';
import 'big_cats.dart';
import 'primates.dart';
import 'raptors.dart';
import 'snakes.dart';
import 'turtles.dart';
import 'lizards.dart';
import 'amphibians.dart';

class PetDexRegistry {
  static final List<PetCardModel> allCards = [
    ...dogCards,
    ...catCards,
    ...birdCards,
    ...raptorCards,
    ...horseCards,
    ...smallPetCards,
    ...batCards,
    ...rodentCards,
    ...reptileCards,
    ...snakeCards,
    ...turtleCards,
    ...lizardCards,
    ...amphibianCards,
    ...farmCards,
    ...fishCards,
    ...sharkCards,
    ...whaleCards,
    ...rayCards,
    ...seahorseCards,
    ...insectCards,
    ...wildlifeCards,
    ...elephantCards,
    ...giraffeCards,
    ...zebraCards,
    ...kangarooCards,
    ...bigCatCards,
    ...primateCards,
    ...exoticCards,
  ];

  static PetCardModel? getCardById(int id) {
    try {
      return allCards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<PetCardModel> getCardsBySpecies(String species) {
    return allCards.where((card) => card.species == species).toList();
  }

  static List<String> getCategories() {
    // Ordine di visualizzazione desiderato per i Tab
    final priority = [
      "Cane", 
      "Gatto", 
      "Uccello", 
      "Cavallo", 
      "Piccoli Animali", 
      "Fattoria", 
      "Pesce", 
      "Anfibio",
      "Insetti", 
      "Selvatici", 
      "Rettile"
    ];
    
    List<String> cats = allCards.map((e) => e.species).toSet().toList();
    cats.sort((a, b) {
      int indexA = priority.indexOf(a);
      int indexB = priority.indexOf(b);
      if (indexA == -1) indexA = 99;
      if (indexB == -1) indexB = 99;
      return indexA.compareTo(indexB);
    });
    return cats;
  }
}
