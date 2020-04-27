import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../config/config.dart';
import 'loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpManager {
  static HttpManager _instance = HttpManager._internal();
  Dio _dio;
  static BuildContext ctx;

  factory HttpManager() => _instance;

  ///通用全局单例，第一次使用时初始化
  HttpManager._internal({String baseUrl}) {
    if (null == _dio) {
      _dio = new Dio(new BaseOptions(
          baseUrl: Configs.BASE_URL, 
          connectTimeout: 15000,
          receiveTimeout:3000
        ));
      _dio.interceptors.add(new LogsInterceptors(ctx:ctx));
    }
  }

  static HttpManager getInstance(BuildContext context,String baseUrl) {
    ctx = context;
    if (baseUrl == null) {
      return _instance._normal();
    } else {
      return _instance._baseUrl(baseUrl);
    }
  }

  //用于指定特定域名，比如cdn和kline首次的http请求
  HttpManager _baseUrl(String baseUrl) {
    if (_dio != null) {
      _dio.options.baseUrl = baseUrl;
    }
    return this;
  }

  //一般请求，默认域名
  HttpManager _normal() {
    if (_dio != null) {
      if (_dio.options.baseUrl != Configs.BASE_URL) {
        _dio.options.baseUrl = Configs.BASE_URL;
      }
    }
    return this;
  }

  ///通用的GET请求
  get(url, params, {noTip = false}) async {
    Response response;
  
    try {
      response = await _dio.get(url, queryParameters: params);
   
    } on DioError catch (e) {
      return e;
    }

    if (response.data is DioError) {
      return response.data['code'];
    }
    // print(response.data);
    return jsonDecode(response.data);
  }
  ///通用的POST请求
  post(url, params, {noTip = false}) async {
    Response response;

    try {
      response = await _dio.post(url, data: params);
    } on DioError catch (e) {
      return e;
    }

    // if (response.data is DioError) {
    //   return response.data['code'];
    // }

    return response.data;
  }
}


/**
 * 拦截器
 * @param {type} 
 * @return: 
 */
class LogsInterceptors extends InterceptorsWrapper {
  LogsInterceptors({this.ctx});
  BuildContext ctx;
  @override
  onRequest(RequestOptions options) async  {
     var cache = await SharedPreferences.getInstance();
     //将token写入头部请求中
     if(cache.getString('token') != null){
       options.headers['Authorization'] = "Bearer " + cache.getString('token');
     }
      // print("请求baseUrl：${options.baseUrl}");
      // print("请求url：${options.path}");
      // print('请求头: ' + options.headers.toString());
      // if (options.data != null) {
      //   print('请求参数: ' + options.data.toString());
      // }

    Loading.showLoading(ctx);
    return options;
  }

  @override
  onResponse(Response response) async {
    Loading.closeLoading();
    //token过期处理
    if( response.data['status'] == 50014 ){
      Navigator.pushReplacementNamed(ctx, '/');
    }
    // print(response);
    return response; // continue
  }

  @override
  onError(DioError err) async {
      Loading.closeLoading();
      print('请求异常: ' + err.toString());
      print('请求异常信息: ' + err.response?.toString() ?? "");
      return err;
  }
}