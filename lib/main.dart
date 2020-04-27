import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'common/constants.dart';
import 'router/index.dart';



void main(){
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  runApp(
        MaterialApp(
          title: '微信',
          theme: ThemeData.light().copyWith(
            primaryColor: Color(AppColors.AppBarColor),
            cardColor: Color(AppColors.AppBarColor)
          ),
          initialRoute: '/',
          onGenerateRoute: onGenerateRoute,
        )
    );
  
}








