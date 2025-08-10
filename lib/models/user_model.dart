// lib/models/user_model.dart
import 'package:hive/hive.dart';
part 'user_model.g.dart';

@HiveType(typeId: 3) // make sure 3 is unique in your project
class User extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String password; // store hashed in real apps

  User({required this.name, required this.email, required this.password});
}
