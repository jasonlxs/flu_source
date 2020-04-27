import 'dart:convert';

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_source/common/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import '../util/api/user.dart';
import '../util/api/source.dart';
import '../util/size.dart';
import '../util/toast.dart';

final _biggerFont = const TextStyle(fontSize: 18.0);
var selectStatus = 0; //0是摄像头 1是手机
var camera_id = 0;

TabController _tabController;

List<dynamic> cameras = [
  {
    "path":"phone/6TtPscM7B6uE0NwalWsdv2PzVxQbLuyYIkwN0ep4ks?watermark/2/text/57qs5bqmOjI3LjMy57uP5bqmOjExOS45OemrmOW6pjo0MTUKXw==/font/5b6u6L2v6ZuF6buR/fontsize/300/fill/I2ZmZmZmZg==/dissolve/100/gravity/NorthWest/dx/5/dy/50/",
    "url":"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=2070233707,3709105432&fm=26&gp=0.jpg"
  }
];
List<dynamic> phone = [
  {
    "path":"phone/6TtPscM7B6uE0NwalWsdv2PzVxQbLuyYIkwN0ep4ks?watermark/2/text/57qs5bqmOjI3LjMy57uP5bqmOjExOS45OemrmOW6pjo0MTUKXw==/font/5b6u6L2v6ZuF6buR/fontsize/300/fill/I2ZmZmZmZg==/dissolve/100/gravity/NorthWest/dx/5/dy/50/",
    "url":"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=2070233707,3709105432&fm=26&gp=0.jpg"
  }
];



class WayPage extends StatefulWidget {
  final Map arguments;
  WayPage({Key key, this.arguments});
  @override
  createState() => _WayPageState();
}

class _WayPageState extends State<WayPage> {
  List<dynamic> source_list = [];
  var _image;

  ///初始函数
  void initState() {
    //接收参数并请求接口
    print(widget.arguments);
  }

  /**
   * 添加摄像头图片
   * @param {type} 
   * @return: 
   */
  void _addCamera(dynamic item){
     setState(() {
        cameras.add(item);
     });
  }

  /**
   * 上传图片
   * @param {type} 
   * @return: 
   */
  _upLoadImage(File image) async {
    String path = image.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    FormData formData = new FormData.fromMap({
      "watermark": "10000024",
      "file": await MultipartFile.fromFile(path, filename:name)
    });
    capture_upload(formData,context).then((res){
       print(res);
       if(res['status'] == 10000){
            setState(() {
                phone.add(res['data']);
                _tabController.animateTo(1);
            });
       }else{
         Toast.toast(context,msg:res['info']);
       }
    }).catchError((err){
      Toast.toast(context,msg:"网络错误");
    });
   
  }

  void showDemoActionSheet({BuildContext context, Widget child}) {
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) => child,
    ).then((String value) async {
      if (value != null) {
        if (value == "Camera") {
          var image = await ImagePicker.pickImage(source: ImageSource.camera);
          _upLoadImage(image);
          // setState(() {
          //   print("Camera");
          //   _image = image;
          // });
        } else if (value == "Gallery") {
          var image = await ImagePicker.pickImage(source: ImageSource.gallery);
          print("Gallery");
          // setState(() {
          //   _image = image;
          // });
          _upLoadImage(image);
        } else if(value == "Cancel"){
           print(value);
        }else {
          //摄像头列表
          showCameraList(context,_addCamera);
        }
      }
    });
  }

  Widget build(BuildContext context) {
    SizeConfig().init(context);
    //渲染页面
    return new Scaffold(
      appBar: new AppBar(
        ///标题
        title:  new Text(widget.arguments['remark'] + '('+ AppDes.des[widget.arguments['mode']] + ")"),

        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              PopupMenuItem<String>(
                child: Text("退出",
                    style: TextStyle(color: Colors.white, fontSize: 15.0)),
                value: "logout",
              ),
            ],
            onSelected: (String action) {
              switch (action) {
                case "logout":
                  user_logout({}, context).then((res) async {
                    if (res['status'] == 10000) {
                      //删除缓存
                      var cache = await SharedPreferences.getInstance();
                      cache.remove("token");
                      cache.remove("role");
                      Navigator.of(context).pushReplacementNamed('login');
                    }
                  }).catchError((err) {
                    print(err);
                  });
                  break;
              }
            },
            onCanceled: () {
              print("onCanceled");
            },
          )
        ],
        centerTitle: true,
      ),
      body: Container(
          child: Container(
              height: double.infinity,
              child: ListView(
                children: [
                  new TopTab(),
                  FlatButton(
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal * 90,
                        height: SizeConfig.blockSizeVertical * 8,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12, width: 2),
                            borderRadius: BorderRadius.circular(20),
                            image: new DecorationImage(
                                  image: AssetImage("lib/assets/next.png"),
                                    //  fit: BoxFit.cover,
                                    //这里是从assets静态文件中获取的，也可以new NetworkImage(）从网络上获取
                                  centerSlice: new Rect.fromLTRB(270.0, 180.0, 1360.0, 730.0),
                            )
                        ),
                        child: Text("拍照", style: _biggerFont),
                      ),
                      onPressed: () {
                        showDemoActionSheet(
                          context: context,
                          child: CupertinoActionSheet(
                            actions: <Widget>[
                              CupertinoActionSheetAction(
                                child: const Text('摄像头列表'),
                                onPressed: () {
                                  Navigator.pop(context, 'List');
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: const Text('相机'),
                                onPressed: () {
                                  Navigator.pop(context, 'Camera');
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: const Text('相册'),
                                onPressed: () {
                                  Navigator.pop(context, 'Gallery');
                                },
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              child: const Text('取消'),
                              isDefaultAction: true,
                              onPressed: () {
                                Navigator.pop(context, 'Cancel');
                              },
                            ),
                          ),
                        );
                      }),
                  SizedBox(height: 5),
                  FlatButton(
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal * 90,
                        height: SizeConfig.blockSizeVertical * 8,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12, width: 2),
                            borderRadius: BorderRadius.circular(20),
                            image: new DecorationImage(
                                    image: AssetImage("lib/assets/next.png"),
                                        //  fit: BoxFit.cover,
                                        //这里是从assets静态文件中获取的，也可以new NetworkImage(）从网络上获取
                                    centerSlice: new Rect.fromLTRB(270.0, 180.0, 1360.0, 730.0),
                            )
                        ),
                        child: Text("上传", style: _biggerFont),
                      ),
                      onPressed: () async {
                        var path = [];
                        if(cameras.length == 0 && phone.length == 0){
                          Toast.toast(context,msg: "请上传图片");
                          return;
                        }
                        for(var camera in cameras){
                            path.add(camera.path);
                        }
                        for(var item in phone){
                            path.add(item.path);
                        }

                        var cache = await SharedPreferences.getInstance();
                        //组合参数
                        var datas = <String,dynamic>{
                          "append_shops_id":cache.getInt("shops_id"),
                          "camera_devices_id":camera_id,
                          "shop_processes_id":widget.arguments['shop_processes_id'],
                          "path":path
                        };
                        //调用接口
                        switch(widget.arguments['mode']){
                          case 1: //1对多
                            if(widget.arguments['prev'].length != 1){
                                Toast.toast(context,msg: "源容器只需要一个");
                                return;
                            }
                            datas['prev'] = widget.arguments['prev'];
                            datas['next'] = widget.arguments['next'];
                            source_otom(datas, context).then((res){
                               if(res['status'] == 10000){
                                   Toast.toast(context,msg: res['info']);
                                   Future.delayed(Duration(microseconds: 300), () {
                                    Navigator.pushNamed(context, '/task');
                                });
                               }else{
                                 Toast.toast(context,msg: res['info']);
                               }
                            }).catchError((err){
                               Toast.toast(context,msg: "网络异常");
                            });
                            break;
                          case 2:  //多对1
                              if(widget.arguments['next'].length != 1){
                                    Toast.toast(context,msg: "目标容器只需要一个");
                                    return;
                                }
                                datas['prev'] = widget.arguments['prev'];
                                datas['next'] = widget.arguments['next'];
                                source_mtoo(datas, context).then((res){
                                  if(res['status'] == 10000){
                                      Toast.toast(context,msg: res['info']);
                                      Future.delayed(Duration(microseconds: 300), () {
                                        Navigator.pushNamed(context, '/task');
                                    });
                                  }else{
                                    Toast.toast(context,msg: res['info']);
                                  }
                                }).catchError((err){
                                  Toast.toast(context,msg: "网络异常");
                                });
                            break;
                          case 3: //自对自
                                datas['next'] = widget.arguments['prev'];
                                source_stos(datas, context).then((res){
                                  if(res['status'] == 10000){
                                      Toast.toast(context,msg: res['info']);
                                      Future.delayed(Duration(microseconds: 300), () {
                                        Navigator.pushNamed(context, '/task');
                                    });
                                  }else{
                                    Toast.toast(context,msg: res['info']);
                                  }
                                }).catchError((err){
                                  Toast.toast(context,msg: "网络异常");
                                });
                            break;
                        }
                      }
                    )
                ],
              ))),
    );
  }
}

class TopTab extends StatefulWidget {
  @override
  createState() => _TopTab();
}

class _TopTab extends State<TopTab> with SingleTickerProviderStateMixin {
  // TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  Widget _buildRow(dynamic item, delete) {
    return new ListTile(
      title: new ListItem(item: item, del: delete),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _deletePic(dynamic item) {
    setState(() {
      if (selectStatus == 0) {
        cameras.remove(item);
      } else if (selectStatus == 1) {
        phone.remove(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
              height: SizeConfig.blockSizeVertical*6,
              decoration: BoxDecoration(
                  color: Color(0xFF99db6d),
                  boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 1.0)]
              ),
              child: SafeArea(
                child: TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  labelStyle: TextStyle(
                    fontSize: 18,
                  ),
                  controller: _tabController,
                  onTap: (index) {
                    selectStatus = index;
                  },
                  tabs: <Widget>[
                    Tab(text: "摄像头拍照"),
                    Tab(text: "手机拍照"),
                  ],
                ),
              )),
          Container(
              margin: EdgeInsets.only(bottom: 20),
              height: SizeConfig.blockSizeVertical * 55,
              child: SafeArea(
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    Container(
                        child: ListView.builder(
                      padding: const EdgeInsets.all(5.0),
                      itemCount: cameras.length,
                      itemBuilder: (context, i) {
                        return _buildRow(cameras[i], _deletePic);
                      },
                    )),
                    Container(
                        child: ListView.builder(
                      padding: const EdgeInsets.all(5.0),
                      itemCount: phone.length,
                      itemBuilder: (context, i) {
                        return _buildRow(phone[i], _deletePic);
                      },
                    ))
                  ],
                ),
              ))
        ],
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  ListItem({this.item, this.del});
  dynamic item, del;
  @override
  Widget build(BuildContext context) {
    // print(this.item);
    return Stack(
      children: [
        Image.network(this.item['url']),
        Positioned(
            right: 0,
            child: GestureDetector(
                child: Icon(Icons.highlight_off),
                onTap: () {
                  del(this.item);
                }))
      ],
    );
  }
}

/**
 * 获取摄像头列表
 * @param {type} 
 * @return: 
 */
Future getCameraList(BuildContext ctx, {dynamic mode}) async {
  var cache = await SharedPreferences.getInstance();
  var shops_id = cache.getInt("shops_id");
  var params = <String, dynamic>{"append_shops_id": shops_id, "all": 1};
  if (mode == 1) {
    params['common'] = 1;
  }
  return camera_list(params, ctx);
}


/**
 * 点击摄像头拍照
 * @param {type} 
 * @return: 
 */
Future clickCamera(BuildContext context,dynamic item) async{
    camera_id = item.id;
    var cache = await SharedPreferences.getInstance();
    cache.setString("camera", jsonEncode(item));
    return local_camera(<String,dynamic>{
      "serial":item['serial_no'],
      "watermark":"xxx"
    },context,url:item['camera_ip']);
}

/**
 * 显示摄像头列表
 * @param {type}N 
 * @return: 
 */
void showCameraList(BuildContext ctx,dynamic addCamera) async {
  List<Widget> items = [];

  var status = false;

  getCameraList(ctx).then((res) {
    // print(res['data']);
    if (res['status'] == 10000) {
      
      for (var list in res['data']) {
        items.add(SimpleDialogOption(
            child: Text(list["alias"]),
            onPressed: () {
              clickCamera(ctx,list).then((ress){
                  if( ress['status'] == 10000 ){
                      addCamera( ress['data']);
                      _tabController.animateTo(0);
                      Navigator.of(ctx).pop();
                  }
              }).catchError((err){
                 Toast.toast(ctx,msg:"网络异常");
              });
              
            }));
      }

      showDialog(
          context: ctx,
          barrierDismissible: false,
          builder: (ctx) {
            return StatefulBuilder(builder: (context, state) {
              return SimpleDialog(
                  title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              child: Icon(Icons.highlight_off),
                              onTap: () {
                                Navigator.of(ctx).pop();
                              },
                            ),
                            SizedBox(width: 20),
                            Text("摄像头列表"),
                          ],
                        ),
                        Row(children: [
                          Checkbox(
                            value: status,
                            activeColor: Colors.blue,
                            onChanged: (bool val) {
                             
                                if (val) {
                                  getCameraList(ctx, mode: 1).then((res) {
                                  
                                    if (res['status'] == 10000) {
                                       state.call(() {
                                          status = val;
                                          items = [];
                                          // List<dynamic>tmp = [];
                                          for (var list in res['data']) {
                                            items.add(SimpleDialogOption(
                                                child: Text(list["alias"]),
                                                onPressed: () {
                                                  clickCamera(ctx,list).then((ress){
                                                        if( ress['status'] == 10000 ){
                                                            addCamera( ress['data']);
                                                            _tabController.animateTo(0);
                                                            Navigator.of(ctx).pop();
                                                        }
                                                    }).catchError((err){
                                                      Toast.toast(ctx,msg:"网络异常");
                                                    });
                                                }));
                                          }
                                         
                                        });
                                    }
                                  });
                                } else {
                                  
                                  getCameraList(ctx).then((res) {
                                    if (res['status'] == 10000) {
                                     state.call(() {
                                       
                                      status = val;
                                      items = [];
                                      for (var list in res['data']) {
                                        
                                            items.add(SimpleDialogOption(
                                                child: Text(list["alias"]),
                                                onPressed: () {
                                                  clickCamera(ctx,list).then((ress){
                                                        if( ress['status'] == 10000 ){
                                                            addCamera( ress['data']);
                                                            _tabController.animateTo(0);
                                                            Navigator.of(ctx).pop();
                                                        }
                                                    }).catchError((err){
                                                      Toast.toast(ctx,msg:"网络异常");
                                                    });
                                                  
                                                }));
                                            }
                                      });
                                      
                                    }
                                  });
                                }
                            },
                          ),
                          Text("显示公共摄像头", style: TextStyle(fontSize: 12)),
                        ])
                      ]),
                  children: items);
            });
          });
    } else {
      Toast.toast(ctx, msg: res["info"]);
    }
  });
}
