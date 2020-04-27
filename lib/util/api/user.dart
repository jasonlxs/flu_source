
import 'package:flutter/cupertino.dart';

import '../../util/request.dart';


/**
 * 登录 
 * @param {type} 
 * @return: 
 */
Future login(Map<String, dynamic> data,BuildContext context,{dynamic url}){
    return HttpManager.getInstance(context,url).post("login", data);
}


/**
 * 获取用户信息 
 * @param {type} 
 * @return: 
 */
Future user_info(Map<String, dynamic> data,BuildContext context,{dynamic url}){
    return HttpManager.getInstance(context,url).post("user/info", data);
}
/**
 * 退出登录
 * @param {type} 
 * @return: 
 */
Future user_logout(Map<String, dynamic> data,BuildContext context,{dynamic url}){
    return HttpManager.getInstance(context,url).post("user/logout", data);
}