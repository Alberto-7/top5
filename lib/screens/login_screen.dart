import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top5_refactor/constants.dart';
import 'package:http/http.dart' as http;
import 'package:top5_refactor/screens/profile_screen.dart';
import 'package:top5_refactor/viewmodel/profile_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  static const id = 'login_screen';
  final TextEditingController usrNameController = TextEditingController();
  final TextEditingController pwdNameController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileViewModel viewModel = Provider.of<ProfileViewModel>(context,
        listen: false); //context.watch<ProfileViewModel>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: .0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            Text('TOP 5', style: TextStyle(fontSize: 80, color: Colors.orange)),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: TextFormField(
                controller: usrNameController,
                decoration: kLoginTextDecoration,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: TextFormField(
                controller: pwdNameController,
                obscureText: true,
                autofocus: true,
                decoration: kPwdTextDecoration,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () async {
                  //var res = await viewModel.getUser(
                  //  usrNameController.text, pwdNameController.text);
                  //KEEP API CALL UNTIL REFACTOR WORKS
                  await viewModel.getUser(
                      usrNameController.text, pwdNameController.text);

                  if (viewModel.userExists) {
                    viewModel.getCategories(viewModel.user!.id);
                    Navigator.pushNamed(context, ProfileScreen.id);
                  } else {
                    debugPrint("PROBLEM");
                  }
                }, //API CALL TO LOGIN
                child: const Text('LOGIN',
                    style: TextStyle(fontSize: 30, color: Colors.white))),
          ],
        ),
      ),
    );
  }
}
