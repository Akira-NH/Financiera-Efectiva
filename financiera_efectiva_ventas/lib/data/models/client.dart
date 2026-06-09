class Client {
  const Client({
    required this.name,
    required this.dni,
    required this.phone,
    required this.location,
    required this.age,
    required this.businessName,
    required this.businessType,
    required this.businessAge,
    required this.premises,
    required this.sbsRating,
    required this.totalDebt,
    required this.preScore,
    required this.segment,
    required this.renewalDate,
  });

  final String name;
  final String dni;
  final String phone;
  final String location;
  final int age;
  final String businessName;
  final String businessType;
  final String businessAge;
  final String premises;
  final String sbsRating;
  final String totalDebt;
  final int preScore;
  final String segment;
  final String renewalDate;

  factory Client.fromJson(Map<String, Object?> json) {
    return Client(
      dni: json['dni'] as String? ?? '',
      name: json['nombres'] as String? ?? '',
      phone: json['telefono'] as String? ?? '',
      location: json['ubicacion'] as String? ?? '',
      age: json['edad'] as int? ?? 0,
      businessName: json['negocio'] as String? ?? '',
      businessType: json['rubro'] as String? ?? '',
      businessAge: json['antiguedad_negocio'] as String? ?? '',
      premises: json['tenencia_local'] as String? ?? '',
      sbsRating: json['calificacion_sbs'] as String? ?? '',
      totalDebt: json['deuda_total'] as String? ?? '',
      preScore: json['score_preliminar'] as int? ?? 0,
      segment: json['segmento'] as String? ?? '',
      renewalDate: json['fecha_renovacion'] as String? ?? '',
    );
  }

  Map<String, Object?> toJson() {
    return {
      'dni': dni,
      'nombres': name,
      'telefono': phone,
      'ubicacion': location,
      'edad': age,
      'negocio': businessName,
      'rubro': businessType,
      'antiguedad_negocio': businessAge,
      'tenencia_local': premises,
      'calificacion_sbs': sbsRating,
      'deuda_total': totalDebt,
      'score_preliminar': preScore,
      'segmento': segment,
      'fecha_renovacion': renewalDate,
    };
  }
}
