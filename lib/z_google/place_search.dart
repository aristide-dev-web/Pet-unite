import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:geocoding/geocoding.dart';
import 'package:easy_localization/easy_localization.dart';

const String kGoogleApiKey =
    "LA_TUA_API_KEY"; // Sostituisci con la tua vera API Key

class PlaceSearch extends StatelessWidget {
  const PlaceSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('map_search_hint'.tr())),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            var p = await PlacesAutocomplete.show(
              context: context,
              apiKey: kGoogleApiKey,
              mode: Mode.overlay,
              language: context.locale.languageCode,
              // components: [Component(Component.country, "it")], // Rimosso per compatibilità
            );

            if (p != null) {
              List<Location> locations = await locationFromAddress(
                p.description!,
              );
              if (locations.isNotEmpty) {
                final lat = locations.first.latitude;
                final lng = locations.first.longitude;

                debugPrint("Luogo selezionato: ${p.description}");
                debugPrint("Coordinate: $lat, $lng");
              }
            }
          },
          child: Text('map_search_hint'.tr()),
        ),
      ),
    );
  }
}