import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:halofund/creat_campaign.dart';
import 'package:halofund/launch_screen.dart';
import 'package:halofund/login_view.dart';
import 'package:halofund/payment_view.dart';
import 'package:halofund/signup_view.dart';

import 'firebase_options.dart';
import 'home_view.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(home: LoginView()));
}
