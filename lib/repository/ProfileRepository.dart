import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:top5_refactor/models/review.dart';
import '../constants.dart';
import '../models/category.dart';
import '../models/user.dart';
import 'abProfileRepository.dart';

class ProfileRepository extends abProfileRepository {
  @override
  Future<User?> loginUser(String userName, String password) async {
    var loginUrl = '$url/login';
    try {
      var res = await http.post(Uri.parse(loginUrl),
          body: jsonEncode(<String, String>{
            'username': userName,
            'password': password,
          }));

      if (res.statusCode == 200) {
        final Map parsed = jsonDecode(res.body);
        var user = User.fromJson(parsed);
        return user;
      }
    } on HttpException catch (e) {
      print(e.message.toString());
    }
    return null;
  }

  @override
  Future<List<Category?>> getCategoryData(int userId) async {
    try {
      var res = await http.get(Uri.parse('$url/get_all_category/$userId'));

      if (res.statusCode == 200) {
        final parsed = jsonDecode(res.body);
        var data = parsed.map<Category>(Category.fromJson).toList();

        return data;
      }
    } on HttpException catch (e) {
      print(e.message.toString());
      return [];
    }
    return [];
  }

  @override
  Future<Category?> createCategory(String categoryTitle, String token) async {
    try {
      var res = await http.post(Uri.parse('$url/create'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(<String, String>{
            "title": categoryTitle,
          }));
      if (res.statusCode == 200) {
        var id = jsonDecode(res.body);
        return Category(title: categoryTitle, catid: id['Success']);
      }
    } catch (e) {}
    return null;
  }

  @override
  Future<List<Review?>> getReviewData(int id) async {
    try {
      var res = await http.get(Uri.parse('$url/get_cat_reviews/$id'));

      if (res.statusCode == 200) {
        var parsed = jsonDecode(res.body);
        List<Review> data = List<Review>.from(parsed.map((model) =>
            Review.fromJson(
                model))); //parsed.map<Review>(Review.fromJson).toList();

        return data;
      }
    } catch (e) {}
    return []; //TODO CHANGE TO API RESPONSE TYPE
  }

  @override
  Future<Review?> createReview(int categoryId, String title, String desc,
      int rank, String? token) async {
    try {
      var res = await http.post(Uri.parse('$url/create_review/$categoryId'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(<String, dynamic>{
            "title": title,
            "description": desc,
            "position": rank
          }));
      if (res.statusCode == 200) {
        return Review(
            categoryId: categoryId, title: title, description: desc, pos: rank);
      }
    } on HttpException catch (e) {
      print(e.message);
      return null;
    }
    return null;
  }

  @override
  Future<int> deleteReview(String title, String? token) async {
    try {
      var res =
          await http.delete(Uri.parse('$url/delete_review/$title'), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (res.statusCode == 200) {
        return 200;
      } else {
        return 404;
      }
    } catch (e) {}
    return 500;
  }

  @override
  Future<int> deleteCategory(int categoryId, String? token) async {
    try {
      var res = await http
          .delete(Uri.parse('$url/delete_category/$categoryId'), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (res.statusCode == 200) {
        return 200;
      } else {
        return 404;
      }
    } catch (e) {}
    return 500;
  }

  @override
  Future getRecommendations(String? token) async {
    var res = await http.get(
      Uri.parse('http://127.0.0.1:5000/api/get_recommended_users'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final parsed = jsonDecode(res.body);
    Map<String, dynamic> data = parsed['Recommended'];

    List l1 = [];
    for (var ele in data.entries) {
      ele.value.add(ele.key);
      l1.add(ele.value);
    }
    return l1;
  }

  @override
  Future<int> follow(int id, String? token) async {
    try {
      var res = await http
          .post(Uri.parse('http://127.0.0.1:5000/api/follow/$id'), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (res.statusCode == 200) {
        return 200;
      } else {
        return 404;
      }
    } catch (e) {}
    return 500;
  }

  Future getUserInfo(int id) async {
    var res = await http.get(Uri.parse('$url/get_info/$id'));

    if (res.statusCode == 200) {
      final Map parsed = jsonDecode(res.body);
      User user = User.fromJson(parsed);
      return user;
    }
    return null;
  }

  @override
  Future<int> unfollow(int id, String? token) async {
    try {
      var res = await http.delete(
        Uri.parse('http://127.0.0.1:5000/api/unfollow/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        return 200;
      } else {
        return 400;
      }
    } catch (e) {
      return 500;
    }
  }

  @override
  Future<bool> isFollowing(int id, String? token) async {
    var res = await http
        .get(Uri.parse('http://127.0.0.1:5000/api/is_following/$id'), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (res.statusCode == 200) {
      return true;
    } else if (res.statusCode == 201) {
      return false;
    }
    return false;
  }
}
