import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'category.dart';

class User {
  late int id;
  late String username;
  late int follower;
  late int following;
  late String? backgroundPic;
  late String? profilePic;
  late List<Category?> categories = [];
  String? token;

  User(
      {required this.id,
      required this.username,
      required this.follower,
      required this.following});

  User.fromJson(Map<dynamic, dynamic> json) {
    id = json['UID'];
    token = json['token'];
    username = json['username'];
    follower = json['followers'] ?? 0;
    following = json['following'] ?? 0;
    backgroundPic = json['background_pic'] ?? 'sunset_cliff.png';
    profilePic = json['prof_pic'] ?? 'prof_pic5.jpg';
  }

  @override
  String toString() {
    return 'Id: $id, UsrName: $username';
  }
}
