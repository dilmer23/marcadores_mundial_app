import 'package:marcadores_mundial_app/domain/entities/stadium.dart';

class StadiumModel {
  final String id;
  final String nameEn;
  final String nameFa;
  final String cityEn;
  final String cityFa;
  final String countryEn;
  final String countryFa;
  final int capacity;
  final String region;

  const StadiumModel({
    required this.id,
    required this.nameEn,
    required this.nameFa,
    required this.cityEn,
    required this.cityFa,
    required this.countryEn,
    required this.countryFa,
    required this.capacity,
    required this.region,
  });

  factory StadiumModel.fromJson(Map<String, dynamic> json) {
    return StadiumModel(
      id: (json['id'] as dynamic).toString(),
      nameEn: json['name_en'] as String? ?? '',
      nameFa: json['name_fa'] as String? ?? '',
      cityEn: json['city_en'] as String? ?? '',
      cityFa: json['city_fa'] as String? ?? '',
      countryEn: json['country_en'] as String? ?? '',
      countryFa: json['country_fa'] as String? ?? '',
      capacity: json['capacity'] as int? ?? 0,
      region: json['region'] as String? ?? '',
    );
  }

  Stadium toEntity() => Stadium(
        id: id,
        nameEn: nameEn,
        nameFa: nameFa,
        cityEn: cityEn,
        cityFa: cityFa,
        countryEn: countryEn,
        countryFa: countryFa,
        capacity: capacity,
        region: region,
      );
}
