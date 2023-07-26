import '../models/category.dart';
import '../models/review.dart';
import '../models/user.dart';

abstract class abProfileRepository {
  Future<User?> loginUser(String userName, String password);
  Future<List<Category?>> getCategoryData(int userId);
  Future<Category?> createCategory(String categoryTitle, String token);
  Future<List<Review?>> getReviewData(int id);
  Future<Review?> createReview(
    int categoryId,
    String title,
    String desc,
    int rank,
    String? token,
  );
  Future<int> deleteReview(String title, String token);
  Future<int> deleteCategory(int categoryId, String? token);
  Future<int> follow(int id, String? token);
  Future<int> unfollow(int id, String? token);
  Future<bool> isFollowing(int id, String? token);

  //SHPULD THIS BE A DIFFERENT REPOSITORY?
  Future<void> getRecommendations(String? token);
}
