class Memoria {
  final String titolo;
  final String descrizione;
  final String pathImmagine;
  final String categoria;
  final DateTime data;
  final String animaleId;

  Memoria({
    required this.titolo,
    required this.descrizione,
    required this.pathImmagine,
    required this.categoria,
    required this.data,
    required this.animaleId,
  });

  Memoria copyWith({
    String? titolo,
    String? descrizione,
    String? pathImmagine,
    String? categoria,
    DateTime? data,
    String? animaleId,
  }) {
    return Memoria(
      titolo: titolo ?? this.titolo,
      descrizione: descrizione ?? this.descrizione,
      pathImmagine: pathImmagine ?? this.pathImmagine,
      categoria: categoria ?? this.categoria,
      data: data ?? this.data,
      animaleId: animaleId ?? this.animaleId,
    );
  }

  Map<String, dynamic> toJson() => {
    'titolo': titolo,
    'descrizione': descrizione,
    'pathImmagine': pathImmagine,
    'categoria': categoria,
    'data': data.toIso8601String(),
    'animaleId': animaleId,
  };

  factory Memoria.fromJson(Map<String, dynamic> json) => Memoria(
    titolo: json['titolo'],
    descrizione: json['descrizione'],
    pathImmagine: json['pathImmagine'],
    categoria: json['categoria'],
    data: DateTime.parse(json['data']),
    animaleId: json['animaleId'],
  );
}