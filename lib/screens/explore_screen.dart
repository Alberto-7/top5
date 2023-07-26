import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top5_refactor/screens/profile_screen.dart';
import 'package:top5_refactor/viewmodel/profile_viewmodel.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/user.dart';

class ExploreScreen extends StatefulWidget {
  //final User user;
  //final String token;
  const ExploreScreen(
      {super.key}); //, required this.user, required this.token});

  static const id = 'explore_screen';

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // Future _getUserInfo(int id) async {
  //   var res = await http.get(Uri.parse('$url/get_info/$id'));

  //   if (res.statusCode == 200) {
  //     final Map parsed = jsonDecode(res.body);
  //     User user = User.fromJson(parsed);
  //     return user;
  //   }
  //   return null;
  // }

  @override
  Widget build(BuildContext context) {
    ProfileViewModel viewModel = context.watch<ProfileViewModel>();
    bool _tileExpanded = false;
    List<String> pics = [
      'prof_pic1.jpg',
      'prof_pic2.jpg',
      'prof_pic3.jpg',
      'prof_pic4.jpg',
      'prof_pic5.jpg'
    ];
    var _random = Random();
    var element = pics[_random.nextInt(pics.length)];
    return Scaffold(
      appBar: AppBar(title: Text("Explore")),
      body: SafeArea(
          child: Consumer<ProfileViewModel>(
              builder: (context, model, child) => ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(20),
                    itemBuilder: (context, index) => Card(
                      color: Colors.orange[200],
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: ExpansionTile(
                        expandedAlignment: Alignment.centerLeft,
                        title: Text(
                          //SNAPSHOT DATA
                          viewModel.recommendation[index][0],
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ), //TODO create func that gets same title/category
                        leading: CircleAvatar(
                          backgroundImage: Image.asset(
                                  'assets/images/${pics[_random.nextInt(pics.length)]}')
                              .image,
                          backgroundColor: Colors.black,
                          radius: 20,
                          child: GestureDetector(
                            onTap: () async {
                              // debugPrint((snapshot.data[index]
                              //         [snapshot.data[index].length - 1])
                              //     .toString());
                              await viewModel.getUserInfo(int.parse(viewModel
                                      .recommendation[index][
                                  viewModel.recommendation[index].length - 1]));
                              //viewModel.visitedUser = res;
                              Navigator.of(context).pushNamed(ProfileScreen.id);
                            },
                            child: CircleAvatar(
                              backgroundImage: Image.asset(
                                      'assets/images/${pics[_random.nextInt(pics.length)]}')
                                  .image,
                              radius: 18,
                            ),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ((viewModel.recommendation[index].length - 1) ~/
                                      2)
                                  .toString(),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Icon(Icons.star)
                          ],
                        ),
                        onExpansionChanged: (bool value) {
                          setState(() => _tileExpanded = value);
                        },
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(25.0, 0, 25, 0),
                            child: Text(
                              viewModel.recommendation[index][1],
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Slabo',
                                  fontWeight: FontWeight.w600),
                            ),
                          )
                        ],
                      ),
                    ),
                    separatorBuilder: (context, index) => SizedBox(
                      height: 60,
                    ),
                    itemCount: viewModel.recommendation.length,
                  ))),
    );
  }
}
