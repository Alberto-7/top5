import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top5_refactor/models/user.dart';

import 'package:top5_refactor/screens/review_screen.dart';
import 'package:top5_refactor/viewmodel/profile_viewmodel.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key, required this.user});
  final User? user;

  @override
  Widget build(BuildContext context) {
    ProfileViewModel viewModel = context.watch<ProfileViewModel>();
    return Expanded(
      child: ListView.separated(
        itemCount: viewModel
            .user!.categories.length, //viewModel.user.categories!.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        clipBehavior: Clip.none,
        separatorBuilder: (context, index) {
          return const SizedBox(
            height: 23,
          );
        },
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.fromLTRB(15, 0, 15, 10),
            elevation: 10,
            color: Colors.brown,
            child: ListTile(
              onTap: () {
                reviewApiCall(viewModel, index);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return ReviewScreen(user: viewModel.user, index: index);
                  }),
                );
              },
              //TODO: Delete category, -> toast message with undo
              onLongPress: () {
                viewModel.deleteCategory(
                    user!.categories[index]!.catid, user!.token);
              },
              leading: iconWidget(viewModel.user!.categories[index]!.title),
              title: Text(
                '${viewModel.user!.categories[index]!.title}',
                style: const TextStyle(color: Colors.white, fontSize: 23),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.thumb_up_rounded,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.thumb_down_alt_rounded,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
          );
        },
      ),
    );
  }
}

reviewApiCall(ProfileViewModel model, int index) async {
  await model.getReviewData(index, model.user!.categories[index]!.catid);
}

Widget iconWidget(String title) {
  switch (title) {
    case 'Songs':
      return Icon(color: Colors.white, Icons.music_note);

    case 'Video Games':
      return Icon(color: Colors.white, Icons.gamepad);

    case 'Movies':
      return Icon(color: Colors.white, Icons.movie);

    case 'Books':
      return Icon(color: Colors.white, Icons.book);

    case 'Series':
      return Icon(color: Colors.white, Icons.tv_sharp);
    default:
      return Icon(Icons.error);
  }
}
