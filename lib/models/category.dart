import 'package:top5_refactor/models/review.dart';

class Category {
  late int catid;
  late String title;
  late List<Review?> review = [];
  // Widget icon;

  Category({required this.title, required this.catid});

  Category.fromJson(json) {
    catid = json['id'];
    title = json['title'];
  }

  @override
  String toString() {
    // TODO: implement toString
    return '$catid + $title';
  }
}
