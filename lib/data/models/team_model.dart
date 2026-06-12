import 'package:marcadores_mundial_app/domain/entities/team.dart';

class TeamModel {
  final String id;
  final String nameEn;
  final String nameFa;
  final String flag;
  final String fifaCode;
  final String iso2;
  final String group;

  const TeamModel({
    required this.id,
    required this.nameEn,
    required this.nameFa,
    required this.flag,
    required this.fifaCode,
    required this.iso2,
    required this.group,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      nameFa: json['name_fa'] as String? ?? '',
      flag: json['flag'] as String? ?? '',
      fifaCode: json['fifa_code'] as String? ?? '',
      iso2: json['iso2'] as String? ?? '',
      group: json['groups'] as String? ?? '',
    );
  }

  Team toEntity() => Team(
        id: id,
        nameEn: nameEn,
        nameFa: nameFa,
        flag: flag,
        fifaCode: fifaCode,
        iso2: iso2,
        group: group,
      );
}
