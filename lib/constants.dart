import 'package:flutter/material.dart';
import 'package:top5_refactor/screens/profile_screen.dart';
import 'package:top5_refactor/viewmodel/profile_viewmodel.dart';

const url = 'http://127.0.0.1:5000/api';

var kLoginTextDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hintText: 'USERNAME',
    hintStyle: const TextStyle(fontWeight: FontWeight.bold),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)));

var kPwdTextDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  hintText: 'PASSWORD',
  hintStyle: const TextStyle(fontWeight: FontWeight.bold),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
);

Widget homeIconButton(BuildContext context, navigate) {
  //model.visitedUser = null;
  return IconButton(
      onPressed: navigate,
      /*() {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => ProfileScreen()),
            (route) => false);
        //Navigator.of(context).popUntil((ModalRoute.withName(ProfileScreen.id)));*/
      icon: const Icon(Icons.home));
}

Widget settingIconButton(BuildContext context) {
  return IconButton(onPressed: () {}, icon: const Icon(Icons.settings));
}

Widget exploreIconButton(BuildContext context, navigate) {
  return IconButton(onPressed: navigate, icon: const Icon(Icons.search));
}
