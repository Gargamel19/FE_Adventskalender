import 'package:test_app/models/user.dart';

class Calender{
  final String id;
  final User owner;
  final String name;
  final String createdDate;
  final int year;

  Calender({
    required this.id,
    required this.owner,
    required this.name,
    required this.createdDate,
    required this.year,
  });

  factory Calender.fromJson(Map<String, dynamic> json){
    return Calender(
      id: json['id'],
      owner: User.fromJson(json['owner']),
      name: json['name'],
      createdDate: json['created_date'],
      year: json['year'],
    );
  }

}