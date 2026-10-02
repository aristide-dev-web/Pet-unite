import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class PrefixSelector extends StatefulWidget {
  final void Function(String prefix) onSelected;

  const PrefixSelector({super.key, required this.onSelected});

  // Lista statica per poter essere usata anche per il parsing dei dati salvati
  static final List<Map<String, String>> prefixes = [
    {"flag": "🇮🇹", "name": "Italia", "code": "+39"},
    {"flag": "🇫🇷", "name": "Francia", "code": "+33"},
    {"flag": "🇪🇸", "name": "Spagna", "code": "+34"},
    {"flag": "🇩🇪", "name": "Germania", "code": "+49"},
    {"flag": "🇬🇧", "name": "Regno Unito", "code": "+44"},
    {"flag": "🇺🇸", "name": "Stati Uniti", "code": "+1"},
    {"flag": "🇨🇦", "name": "Canada", "code": "+1"},
    {"flag": "🇯🇵", "name": "Giappone", "code": "+81"},
    {"flag": "🇰🇷", "name": "Corea del Sud", "code": "+82"},
    {"flag": "🇨🇳", "name": "Cina", "code": "+86"},
    {"flag": "🇧🇷", "name": "Brasile", "code": "+55"},
    {"flag": "🇲🇽", "name": "Messico", "code": "+52"},
    {"flag": "🇦🇺", "name": "Australia", "code": "+61"},
    {"flag": "🇮🇳", "name": "India", "code": "+91"},
    {"flag": "🇱🇻", "name": "Lettonia", "code": "+371"},
    {"flag": "🇦🇱", "name": "Albania", "code": "+355"},
    {"flag": "🇦🇩", "name": "Andorra", "code": "+376"},
    {"flag": "🇦🇹", "name": "Austria", "code": "+43"},
    {"flag": "🇧🇪", "name": "Belgio", "code": "+32"},
    {"flag": "🇧🇾", "name": "Bielorussia", "code": "+375"},
    {"flag": "🇧🇦", "name": "Bosnia ed Erzegovina", "code": "+387"},
    {"flag": "🇧🇬", "name": "Bulgaria", "code": "+359"},
    {"flag": "🇨🇾", "name": "Cipro", "code": "+357"},
    {"flag": "🇭🇷", "name": "Croazia", "code": "+385"},
    {"flag": "🇩🇰", "name": "Danimarca", "code": "+45"},
    {"flag": "🇪🇪", "name": "Estonia", "code": "+372"},
    {"flag": "🇫🇮", "name": "Finlandia", "code": "+358"},
    {"flag": "🇬🇷", "name": "Grecia", "code": "+30"},
    {"flag": "🇮🇪", "name": "Irlanda", "code": "+353"},
    {"flag": "🇮🇸", "name": "Islanda", "code": "+354"},
    {"flag": "🇽🇰", "name": "Kosovo", "code": "+383"},
    {"flag": "🇱🇮", "name": "Liechtenstein", "code": "+423"},
    {"flag": "🇱🇹", "name": "Lituania", "code": "+370"},
    {"flag": "🇱🇺", "name": "Lussemburgo", "code": "+352"},
    {"flag": "🇲🇰", "name": "Macedonia del Nord", "code": "+389"},
    {"flag": "🇲ᵗ", "name": "Malta", "code": "+356"},
    {"flag": "🇲🇩", "name": "Moldavia", "code": "+373"},
    {"flag": "🇲🇨", "name": "Monaco", "code": "+377"},
    {"flag": "🇲🇪", "name": "Montenegro", "code": "+382"},
    {"flag": "🇳🇴", "name": "Norvegia", "code": "+47"},
    {"flag": "🇳🇱", "name": "Paesi Bassi", "code": "+31"},
    {"flag": "🇵🇱", "name": "Polonia", "code": "+48"},
    {"flag": "🇵ᵗ", "name": "Portogallo", "code": "+351"},
    {"flag": "🇨🇿", "name": "Repubblica Ceca", "code": "+420"},
    {"flag": "🇷🇴", "name": "Romania", "code": "+40"},
    {"flag": "🇷🇺", "name": "Russia", "code": "+7"},
    {"flag": "🇸🇲", "name": "San Marino", "code": "+378"},
    {"flag": "🇷🇸", "name": "Serbia", "code": "+381"},
    {"flag": "🇸🇰", "name": "Slovacchia", "code": "+421"},
    {"flag": "🇸🇮", "name": "Slovenia", "code": "+386"},
    {"flag": "🇸🇪", "name": "Svezia", "code": "+46"},
    {"flag": "🇨🇭", "name": "Svizzera", "code": "+41"},
    {"flag": "🇺🇦", "name": "Ucraina", "code": "+380"},
    {"flag": "🇭🇺", "name": "Ungheria", "code": "+36"},
    {"flag": "🇻🇦", "name": "Città del Vaticano", "code": "+39"},
  ];

  /// Metodo di utilità per separare prefisso e numero da una stringa completa
  static Map<String, String> splitPhone(String fullPhone) {
    if (!fullPhone.startsWith('+')) return {"prefix": "+39", "number": fullPhone};
    
    // Ordiniamo i prefissi per lunghezza decrescente per evitare match parziali (es: +1 prima di +123)
    final sortedPrefixes = List<Map<String, String>>.from(prefixes)
      ..sort((a, b) => b["code"]!.length.compareTo(a["code"]!.length));

    for (var p in sortedPrefixes) {
      if (fullPhone.startsWith(p["code"]!)) {
        return {
          "prefix": p["code"]!,
          "number": fullPhone.substring(p["code"]!.length).trim(),
        };
      }
    }
    return {"prefix": "+39", "number": fullPhone};
  }

  @override
  State<PrefixSelector> createState() => _PrefixSelectorState();
}

class _PrefixSelectorState extends State<PrefixSelector> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final filtered = PrefixSelector.prefixes.where((p) {
      final s = query.toLowerCase();
      final nameMatches = p["name"]!.toLowerCase().contains(s);
      final codeMatches = p["code"]!.contains(s);
      return nameMatches || codeMatches;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text("prefix_select_title".tr(), 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "prefix_search_hint".tr(),
                prefixIcon: const Icon(Icons.search, color: Colors.orangeAccent),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) => setState(() => query = value),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => Divider(color: Colors.grey[100], height: 1),
              itemBuilder: (_, i) {
                final item = filtered[i];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.grey[50], shape: BoxShape.circle),
                    child: Text(item["flag"]!, style: const TextStyle(fontSize: 22)),
                  ),
                  title: Text(item["name"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  trailing: Text(item["code"]!, style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w900, fontSize: 16)),
                  onTap: () {
                    widget.onSelected(item["code"]!);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
