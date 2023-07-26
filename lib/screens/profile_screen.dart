import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top5_refactor/constants.dart';
import 'package:top5_refactor/screens/explore_screen.dart';
import 'package:top5_refactor/viewmodel/profile_viewmodel.dart';
import 'package:top5_refactor/widgets/categories.dart';
import 'package:top5_refactor/widgets/profile_pic.dart';

import '../widgets/follower_new.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const id = 'profile_screen';

  @override
  Widget build(BuildContext context) {
    ProfileViewModel viewModel = context.watch<ProfileViewModel>();

    const double profilePicHeight = 150.0 - 60.0;

    List<String> chooseCategory = [
      'Movies',
      'Video Games',
      'Series',
      'Songs',
      'Books'
    ];

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.teal,
          title: const Text(
            'TOP 5',
            style: TextStyle(fontFamily: 'Roboto', color: Colors.black),
          )),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        items: [
          navBarItem(
              homeIconButton(context, () => homeNavigation(viewModel, context)),
              'Home'),
          navBarItem(settingIconButton(context), 'Setting'),
          navBarItem(
              exploreIconButton(context, () async {
                await exploreNavigation(viewModel, context);
              }),
              'Explore'),
        ],
      ),
      body: SafeArea(
        child: Consumer<ProfileViewModel>(builder: (context, viewModel, child) {
          //var follow = beans(viewModel);
          return Container(
            color: Colors.teal,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(
                        (isCurrentUser(viewModel))
                            ? 'assets/images/${viewModel.user!.backgroundPic}'
                            : 'assets/images/${viewModel.visitedUser!.backgroundPic}',
                        fit: BoxFit.fill,
                        width: double.infinity,
                      ),
                      Positioned(
                        top: profilePicHeight,
                        child: ProfilePicWidget(
                          picLocation: (isCurrentUser(viewModel))
                              ? viewModel.user!.profilePic
                              : viewModel.visitedUser!.profilePic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
                Text(
                    (isCurrentUser(viewModel)
                        ? viewModel.user!.username
                        : viewModel.visitedUser!.username),
                    style: TextStyle(fontSize: 24)),
                Container(
                  alignment: Alignment.centerLeft,
                  //margin: EdgeInsets.only(bottom: 40),
                  padding: EdgeInsets.all(10),
                  height: 100,
                  width: double.infinity,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FollowWidgets(
                            data: (isCurrentUser(viewModel))
                                ? viewModel.user!.follower
                                : viewModel.visitedUser!.follower,
                            title: 'FOLLOWERS'),
                        FollowWidgets(
                            data: (isCurrentUser(viewModel))
                                ? viewModel.user!.following
                                : viewModel.visitedUser!.following,
                            title: 'FOLLOWING'),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            (isCurrentUser(viewModel))
                                ? PopupMenuButton<dynamic>(
                                    itemBuilder: (context) => [
                                      categoryPopUp(
                                          chooseCategory[0], viewModel),
                                      categoryPopUp(
                                          chooseCategory[1], viewModel),
                                      categoryPopUp(
                                          chooseCategory[2], viewModel),
                                      categoryPopUp(
                                          chooseCategory[3], viewModel),
                                      categoryPopUp(
                                          chooseCategory[4], viewModel),
                                    ],
                                  )
                                : Center(
                                    child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(90),
                                              side: BorderSide(width: 1)),
                                        ),
                                        onPressed: viewModel.following
                                            ? () => viewModel.unfollow(
                                                viewModel.visitedUser!.id,
                                                viewModel.user!.token)
                                            : () => viewModel.follow(
                                                viewModel.visitedUser!.id,
                                                viewModel.user!.token),
                                        child: viewModel.following
                                            ? const Text(
                                                'UNFOLLOW',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            : const Text('FOLLOW',
                                                style: TextStyle(
                                                    color: Colors.white))),
                                  )
                          ],
                        )
                      ]),
                ),
                CategoryList(user: viewModel.user),
              ],
            ),
          );
        }),
      ),
    );
  }
}

bool isCurrentUser(ProfileViewModel model) {
  return model.visitedUser == null;
}

exploreNavigation(ProfileViewModel viewModel, context) async {
  await viewModel.getRecommendations(viewModel.user!.token);
  Navigator.pushNamed(context, ExploreScreen.id);
}

homeNavigation(ProfileViewModel model, context) {
  model.visitedUser = null;
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => ProfileScreen()),
      (route) => false);
}

BottomNavigationBarItem navBarItem(Widget icon, String title) {
  return BottomNavigationBarItem(icon: icon, label: title);
}

categoryPopUp(String category, ProfileViewModel model) {
  return PopupMenuItem(
    child: Text(category),
    onTap: () {
      model.createCategory(category, model.user!.token!);
    },
  );
}
