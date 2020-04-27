
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../util/request.dart';


/**
 * 获取溯源流程
 * @param {type} 
 * @return: 
 */
Future source_process(Map<String, dynamic> data,BuildContext context,{dynamic url}){
    return HttpManager.getInstance(context,url).post("source/query/process/list", data);
}

/**
 * 获取摄像头列表
 * @param {type} 
 * @return: 
 */
Future camera_list(Map<String, dynamic> data,BuildContext context,{dynamic url}){
    return HttpManager.getInstance(context,url).post("monitor/query/devices", data);
}

/**
 * 调用本地摄像头
 * @param {type} 
 * @return: 
 */
Future local_camera(Map<String, dynamic> data,BuildContext context,{dynamic url}){
    return HttpManager.getInstance(context,url).post("camera/capture", data);
}

/**
 * 七牛图片上传
 * @param {type} 
 * @return: 
 */
Future capture_upload(FormData data,BuildContext context,{dynamic url}){
    return HttpManager.getInstance(context,url).post("common/source/capture/upload", data);
}

/**
 * @溯源多对一 
 * @param {type} 
 * @return: 
 */
Future source_mtoo(Map<String, dynamic> data,BuildContext context,{dynamic url}){
   return HttpManager.getInstance(context,url).post("source/confirm/MtoO", data);
}


/**
 * @溯源一对多
 * @param {type} 
 * @return: 
 */
Future source_otom(Map<String, dynamic> data,BuildContext context,{dynamic url}){
   return HttpManager.getInstance(context,url).post("source/confirm/OtoM", data);
}


/**
 * 溯源自对自
 * @param {type} 
 * @return: 
 */
Future source_stos(Map<String, dynamic> data,BuildContext context,{dynamic url}){
   return HttpManager.getInstance(context,url).post("source/confirm/self", data);
}

/**
 * 溯源绑定
 * @param {type} 
 * @return: 
 */
Future source_bind(Map<String, dynamic> data,BuildContext context,{dynamic url}){
   return HttpManager.getInstance(context,url).post("source/relate/batch", data);
}


