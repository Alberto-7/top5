import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top5_refactor/models/category.dart';
import 'package:top5_refactor/models/user.dart';
import 'package:top5_refactor/screens/profile_screen.dart';
import '../viewmodel/profile_viewmodel.dart';

class ReviewScreen extends StatefulWidget {
  final User? user;
  final int index;

  const ReviewScreen({super.key, required this.user, required this.index});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  @override
  Widget build(BuildContext context) {
    ProfileViewModel viewModel = context.watch<ProfileViewModel>();
    var categoryIndex = viewModel.user!.categories[widget.index];
    var isExpanded = false;
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryIndex!.title),
      ),
      body: SafeArea(
        child: Consumer<ProfileViewModel>(builder: (context, model, child) {
          var categoryIndex = model.user!.categories[widget.index];
          return ListView.separated(
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  child: GestureDetector(
                    onLongPress: () => model.deleteReview(
                        categoryIndex.review[index]!.title,
                        model.user?.token ?? '', //Again token cant be null
                        widget.index),
                    child: ExpansionTile(
                      title: Text(
                        model.user!.categories[widget.index]!.review[index]!
                            .title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      expandedAlignment: Alignment.centerLeft,
                      childrenPadding: const EdgeInsets.all(10),
                      leading: Text(
                        '${categoryIndex.review[index]!.pos}.',
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      onExpansionChanged: (bool expanded) {
                        setState(() => isExpanded != expanded);
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(25.0, 0, 25, 0),
                          child: Text(
                            categoryIndex.review[index]?.description ??
                                'No Description provided',
                            style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'Slabo',
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 10,
                );
              },
              itemCount: categoryIndex!.review.length);
        }),
      ),
      floatingActionButton: (isCurrentUser(viewModel))
          ? _getFab(viewModel, categoryIndex, widget.index)
          : Container(),
    );
  }

  //TODO:Currently spaghetti, cleanup
  Widget _getFab(ProfileViewModel viewModel, Category category, int index) {
    final formkey = GlobalKey<FormState>();
    TextEditingController reviewTitle = TextEditingController();
    TextEditingController reviewEditTitle = TextEditingController();
    TextEditingController reviewDesc = TextEditingController();
    TextEditingController pos = TextEditingController();
    if (viewModel.user!.token != '') {
      return FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Edit/Add Review'),
                scrollable: true,
                contentPadding: EdgeInsets.all(8),
                content: Form(
                  key: formkey,
                  child: Column(children: [
                    TextFormField(
                      controller: reviewEditTitle,
                      decoration: const InputDecoration(
                          labelText: 'Edit Review Title',
                          icon: Icon(Icons.notes)),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'PLEASE ENTER A TITLE';
                        }
                        return null;
                      },
                      controller: reviewTitle,
                      decoration: const InputDecoration(
                          labelText: 'Review Title', icon: Icon(Icons.notes)),
                    ),
                    TextFormField(
                      controller: reviewDesc,
                      decoration: const InputDecoration(
                          labelText: 'Description', icon: Icon(Icons.message)),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (!_isNumeric(value)) {
                          return 'Please enter a number';
                        }
                        return null;
                      },
                      controller: pos,
                      decoration: const InputDecoration(
                        labelText: 'Rank',
                        icon: Icon(Icons.numbers),
                      ),
                    )
                  ]),
                ),
                actions: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              if (formkey.currentState!.validate()) {
                                //TODO: add snackbar messages
                                var res = viewModel.createReview(
                                    index,
                                    category.catid,
                                    reviewTitle.text,
                                    reviewDesc.text,
                                    int.parse(pos.text),
                                    viewModel.user?.token ??
                                        ''); //Cant be null, workaround
                                formkey.currentState!.reset();
                              }
                            },
                            child: Text('ADD')),
                        ElevatedButton(
                            onPressed: () {
                              //TODO Edit REVIEW API
                              if (formkey.currentState!.validate()) {
                                // var res = _editReview(
                                //     reviewEditTitle.text,
                                //     reviewTitle.text,
                                //     reviewDesc.text,
                                //     int.parse(pos.text),
                                //     widget.token);
                                formkey.currentState!.reset();
                              }
                            },
                            child: Text('EDIT')),
                      ])
                ],
              );
            },
          );
        },
      );
    } else {
      return Container(); //Another users page. Hide button
    }
  }
}

bool _isNumeric(String? str) {
  if (str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}
