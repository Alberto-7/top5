import 'package:flutter/material.dart';
import 'package:top5_refactor/models/category.dart';
import 'package:top5_refactor/repository/Response.dart';

import '../models/user.dart';
import '../repository/ProfileRepository.dart';

class ProfileViewModel with ChangeNotifier {
  User? user;
  bool isLoading = false;
  List recommendation = [];
  User? visitedUser;
  bool following = false;
  final ProfileRepository profileRepo;

  bool get loading => isLoading;
  bool get userExists => user != null;

  ProfileViewModel({required this.profileRepo});

  //TODO: IMPLEMENT AFTER SUCCESSFUL API CALLS
  setLoading(bool loading) async {
    isLoading = loading;
    notifyListeners();
  }

  Future<void> getUser(String userName, String password) async {
    var result = await profileRepo.loginUser(userName, password);
    user = result;
    notifyListeners();
  }

  Future<void> getCategories(int id) async {
    var result = await profileRepo.getCategoryData(user!.id);
    user!.categories = result;
    notifyListeners();
  }

  Future<void> createCategory(String categoryTitle, String token) async {
    var catagory = await profileRepo.createCategory(categoryTitle, token);
    user!.categories.add(catagory);
    notifyListeners();
  }

  Future<void> getReviewData(int index, int id) async {
    var reviewList = await profileRepo.getReviewData(id);
    user!.categories[index]!.review = reviewList;
    notifyListeners();
  }

  Future<void> createReview(
    int index,
    int categoryId,
    String title,
    String desc,
    int rank,
    String token,
  ) async {
    var result =
        await profileRepo.createReview(categoryId, title, desc, rank, token);
    user!.categories[index]!.review.add(result);
    notifyListeners();
  }

  Future<void> deleteReview(
      String title, String token, int categoryIndex) async {
    var res = await profileRepo.deleteReview(title, token);
    if (res == 200) {
      user!.categories[categoryIndex]!.review
          .removeWhere((review) => review!.title == title);
      notifyListeners();
    } else {
      debugPrint("SOMETHING WENT WRONG IN DELETING");
    }
  }

  Future<void> deleteCategory(int categoryId, String? token) async {
    var res = await profileRepo.deleteCategory(categoryId, token);
    if (res == 200) {
      user!.categories.removeWhere((category) => category!.catid == categoryId);
      notifyListeners();
    } else {
      debugPrint("UNABLE TO DELETE");
    }
  }

  Future getRecommendations(String? token) async {
    var res = await profileRepo.getRecommendations(token);
    recommendation = res;
    notifyListeners();
  }

  Future<void> follow(int id, String? token) async {
    var res = await profileRepo.follow(id, token);
    if (res == 200) {
      user?.following++;
      visitedUser?.follower++;
      following = true;
      notifyListeners();
    }
  }

  Future<void> unfollow(int id, String? token) async {
    var res = await profileRepo.unfollow(id, token);
    if (res == 200) {
      user?.following--;
      visitedUser?.follower--;
      following = false;
      notifyListeners();
    }
  }

  Future<void> isFollowing(int id, String? token) async {
    var res = await profileRepo.isFollowing(id, token);
    following = res;
    notifyListeners();
  }

  Future<void> getUserInfo(int id) async {
    var res = await profileRepo.getUserInfo(id);
    visitedUser = res;
    notifyListeners();
  }
}
