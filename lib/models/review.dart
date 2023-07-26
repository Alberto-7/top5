class Review {
  late int categoryId;
  late String title;
  late String description;
  late int pos;

  Review({
    required this.categoryId,
    required this.title,
    required this.description,
    required this.pos,
  });

  Review.fromJson(Map<dynamic, dynamic> json) {
    categoryId = json['category_id'];
    title = json['title'];
    description = json['description'];
    pos = json['position'];
  }

  @override
  String toString() {
    return '$categoryId + $description + $title + $pos';
  }
}
