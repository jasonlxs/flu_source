
import 'package:flutter/material.dart';
import '../pages/login.dart';
import '../pages/task.dart';
import '../pages/nfc.dart';
import '../pages/way.dart';


// 声明所有页面
final routes = {
    //登录页面
    '/': (BuildContext ctx, {arguments}) => new LoginPage(),
    //任务页面
    '/task': (BuildContext ctx, {arguments}) => new TaskPage(arguments: arguments),
    //NFC页面
    '/nfc': (BuildContext ctx, {arguments}) => new NfcPage(arguments: arguments),
     //拍照操作
    '/way': (BuildContext ctx, {arguments}) => new WayPage(arguments: arguments),
};



var onGenerateRoute = (RouteSettings settings) {
  // 获取声明的路由页面函数
  var pageBuilder = routes[settings.name];
  if (pageBuilder != null) {
    if (settings.arguments != null) {
      // 创建路由页面并携带参数
      return MaterialPageRoute(
          builder: (context) =>
              pageBuilder(context, arguments: settings.arguments));
    } else {
      return MaterialPageRoute(
          builder: (context) => pageBuilder(context));
    }
  }
  return MaterialPageRoute(builder: (context) => LoginPage());
};

