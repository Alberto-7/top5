import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top5_refactor/repository/ProfileRepository.dart';
import 'package:top5_refactor/screens/explore_screen.dart';
import 'package:top5_refactor/screens/login_screen.dart';
import 'package:top5_refactor/screens/profile_screen.dart';
import 'package:top5_refactor/viewmodel/profile_viewmodel.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => ProfileViewModel(profileRepo: ProfileRepository()),
    ),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: LoginScreen.id,
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        ProfileScreen.id: (context) => ProfileScreen(),
        ExploreScreen.id: (context) => ExploreScreen(),
      },
    );
  }
}
