import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants.dart' show AppDes;
import '../util/toast.dart';
import '../util/size.dart';
import '../util/api/user.dart';


List<dynamic> sources = ["A-00001-2"];
List<dynamic> goals = ["B-00001-2"];
final _biggerFont = const TextStyle(fontSize: 18.0);
var selectStatus = 1; //1源容器  2目标容器

String matchContent(String str){
        var strReg = RegExp(
            r"[A-Z]{1}-\d{5}-(1|2)");
      return strReg.stringMatch(str);
}

class NfcPage extends StatefulWidget{
   final Map arguments;
   NfcPage({Key key, this.arguments});
   @override
   createState()=> _NfcPage();
}


class _NfcPage extends State<NfcPage>{
  var status = false;
  //初始化
 void initState(){
  //  print(widget.arguments);
   if(widget.arguments["mode"] == 3)status = true;
   FlutterNfcReader.onTagDiscovered().listen((onData) {
          var content = matchContent(onData.content);
          if(content == null){
            Toast.toast(context,msg:"不是合法标签");
            return;
          }
          // print(onData.id);
          switch(selectStatus){
            case 1: //sources 校验是否存在
              if( sources.lastIndexOf(content) != -1   ){
                Toast.toast(context,msg:"标签已扫描过");
                return;
              }
              setState(() {
                  sources.add(content);
                  
              });
              
              break;
            case 2: // goals
              if( goals.lastIndexOf(content) != -1   ){
                Toast.toast(context,msg:"标签已扫描过");
                return;
              }
              setState(() {
                  goals.add(content);
                  print(goals);
              });
              break;
          }
          
    });
 }


 //弹窗
 void showCommonDialog(BuildContext context){
      dynamic val;
      dynamic tip = "请输入容器编码";
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context){
          return StatefulBuilder(
            builder: (context,state){
              return Dialog(
                child: Container(
                  padding: EdgeInsets.all(10),
                  height: 160,
                  child: Column(
                    mainAxisAlignment:MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10.0),
                          labelText: tip,
                          ),
                          onChanged: (String value) => val = value,
                      ),
                      // Text(tip,style: TextStyle(color: Colors.red)),
                      Container(
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RaisedButton(
                                child: Text("确定"),
                                onPressed: (){
                                  if(val == null){
                                    state.call((){
                                      setState(() {
                                        tip = "必填";
                                      });
                                     } 
                                    );
                                  }else if(matchContent(val) == null){
                                      state.call((){
                                          setState(() {
                                            tip = "格式不合法";
                                          });
                                        } 
                                      );
                                  }else{
                                      switch(selectStatus){
                                        case 1: //sources 校验是否存在
                                          if( sources.lastIndexOf(val) != -1   ){
                                            Toast.toast(context,msg:"标签已存在");
                                            return;
                                          }
                                          setState(() {
                                              sources.add(val);
                                          });
                                          
                                          break;
                                        case 2: // goals
                                          if( goals.lastIndexOf(val) != -1   ){
                                            Toast.toast(context,msg:"标签已存在");
                                            return;
                                          }
                                          setState(() {
                                              goals.add(val);
                                          });
                                          break;
                                      }
                                      Navigator.of(context).pop();
                                  }
                                }
                              ),
                              SizedBox(width: 20),
                              RaisedButton(
                                child: Text("取消"),
                                onPressed: (){
                                  Navigator.of(context).pop();
                                }
                              )
                            ],
                        ),
                      )
                     
                      
                    ],
                  ),
                ),
              );
            }
          );
        }
      );
 }

 Widget build(BuildContext context){


     SizeConfig().init(context);

      
     void _deleteList(dynamic value,type) {
        setState(() {
           if(type == 1){
                sources.remove(value);
            }else if(type == 2) {
                goals.remove(value);
            }
        });
      }

      Widget _buildRow(dynamic item,type) {
          return new ListTile(
            title: new ListItem(
              item:item,
              type:type,
              delete:_deleteList
            ),
          );
      }

      //渲染页面
     return new Scaffold(
       appBar: new AppBar(
        ///标题
         title: new Text(widget.arguments['remark'] + '('+ AppDes.des[widget.arguments['mode']] + ")"),
         actions: <Widget>[
          PopupMenuButton(
              itemBuilder: (BuildContext context) =>
              <PopupMenuItem<String>>[
                PopupMenuItem<String>(child: Text("扫一扫",style:TextStyle(color:Colors.white,fontSize: 15.0)), value: "scan",),
                PopupMenuItem<String>(child: Text("手动输入",style:TextStyle(color:Colors.white,fontSize: 15.0)), value: "input",),
                PopupMenuItem<String>(child: Text("退出",style:TextStyle(color:Colors.white,fontSize: 15.0)), value: "logout",),
              ],
              onSelected: (String action) async {
                switch (action) {
                  case "scan":
                    var result = await BarcodeScanner.scan(options: ScanOptions(
                      strings:{
                        "flash_on":"开灯",
                        "flash_off":"关灯",
                      },
                      android:AndroidOptions(
                        useAutoFocus:true,
                      )
                    ));
                    var content = matchContent(result.rawContent);
                      if(content == null){
                        Toast.toast(context,msg:"不是合法标签");
                        return;
                      }
                      
                      switch(selectStatus){
                        case 1: //sources 校验是否存在
                          if( sources.lastIndexOf(content) != -1   ){
                            Toast.toast(context,msg:"标签已扫描过");
                            return;
                          }
                          setState(() {
                              sources.add(content);
                              
                          });
                          
                          break;
                        case 2: // goals
                          if( goals.lastIndexOf(content) != -1   ){
                            Toast.toast(context,msg:"标签已扫描过");
                            return;
                          }
                          setState(() {
                              goals.add(content);
                              print(goals);
                          });
                          break;
                      }
                    break;
                  case "input":
                    showCommonDialog(context);
                    break;
                  case "logout":
                    user_logout({},context).then((res) async{
                        if(res['status'] == 10000){
                          //删除缓存
                          var cache = await SharedPreferences.getInstance();
                          cache.remove("token");
                          cache.remove("role");
                          Navigator.of(context).pushReplacementNamed('login');
                        }
                    }).catchError((err){
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
       body:Container(
          // padding:EdgeInsets.symmetric(horizontal: 10),
          height: double.infinity,
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                top:  0,
                child:Column(
                  children: [
                     //标题
                     Row(
                        children:[
                          GestureDetector(
                                child:  Container(
                                    padding: EdgeInsets.all(5.0),
                                    width: status?SizeConfig.blockSizeHorizontal * 100:SizeConfig.blockSizeHorizontal * 50,
                                    height: SizeConfig.blockSizeVertical*6,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12,width: 1),
                                      color: selectStatus == 1?Colors.black12:Color(0xFFffffff),
                                      // borderRadius: BorderRadius.circular(20)
                                    ),
                                    child:Text("源容器",style: _biggerFont),
                                ),
                               onTap: (){
                                    setState(() {
                                      selectStatus = 1;
                                    });
                                }, 
                            ),
                            Offstage(
                              offstage:status,
                              child: GestureDetector(
                                child:  Container(
                                    padding: EdgeInsets.all(5.0),
                                    width: SizeConfig.blockSizeHorizontal * 50,
                                    height: SizeConfig.blockSizeVertical*6,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12,width: 1),
                                      color: selectStatus == 2?Colors.black12:Color(0xFFffffff),
                                      // borderRadius: BorderRadius.circular(20)
                                    ),
                                    child:Text("目标容器",style: _biggerFont),
                                ),
                               onTap: (){
                                    setState(() {
                                      selectStatus = 2;
                                    });
                                }, 
                              ),
                          )
                            
                        ]
                      ),
                      //内容
                      Row(
                          children:[
                            Container(
                                width: status?SizeConfig.blockSizeHorizontal * 100:SizeConfig.blockSizeHorizontal * 50,
                                height: SizeConfig.blockSizeVertical * 65,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(
                                     left:BorderSide(color: Colors.black12,width: 1),
                                      right:BorderSide(color: Colors.black12,width: 1),
                                      bottom:BorderSide(color: Colors.black12,width: 1),
                                  ),
                                  image: new DecorationImage(
                                    image: AssetImage("lib/assets/bb.png"),
                                      //  fit: BoxFit.cover,
                                      //这里是从assets静态文件中获取的，也可以new NetworkImage(）从网络上获取
                                      centerSlice: new Rect.fromLTRB(270.0, 180.0, 1360.0, 730.0),
                                  )
                                ),
                                child:ListView.builder(
                                  padding: const EdgeInsets.all(5.0),
                                  itemCount: sources.length,
                                  itemBuilder: (context, i) {
                                    return _buildRow(sources[i],1);
                                  },
                                )
                            ),
                             Offstage(
                              offstage:status,
                              child:Container(
                                  width: SizeConfig.blockSizeHorizontal * 50,
                                  height: SizeConfig.blockSizeVertical * 65,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left:BorderSide(color: Colors.black12,width: 1),
                                          right:BorderSide(color: Colors.black12,width: 1),
                                          bottom:BorderSide(color: Colors.black12,width: 1),
                                    ),
                                    image: new DecorationImage(
                                      image: AssetImage("lib/assets/bb.png"),
                                        //  fit: BoxFit.cover,
                                        //这里是从assets静态文件中获取的，也可以new NetworkImage(）从网络上获取
                                        centerSlice: new Rect.fromLTRB(270.0, 180.0, 1360.0, 730.0),
                                    )
                                  ),
                                  child:ListView.builder(
                                    padding: const EdgeInsets.all(5.0),
                                    itemCount: goals.length,
                                    itemBuilder: (context, i) {
                                      return _buildRow(goals[i],2);
                                    },
                                  )
                                )
                             )
                            
                          ]
                      ),
                  ],
                ),
               
              ),
                
              Positioned(
                // left:  SizeConfig.blockSizeHorizontal * 15,
                bottom: SizeConfig.blockSizeHorizontal * 15,
                child:FlatButton(
                          child: Container(
                              width:  SizeConfig.blockSizeHorizontal * 90,
                              height: SizeConfig.blockSizeVertical * 8,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black12,width: 2),
                                borderRadius: BorderRadius.circular(20),
                                 image: new DecorationImage(
                                      image: AssetImage("lib/assets/next.png"),
                                        //  fit: BoxFit.cover,
                                        //这里是从assets静态文件中获取的，也可以new NetworkImage(）从网络上获取
                                        centerSlice: new Rect.fromLTRB(270.0, 180.0, 1360.0, 730.0),
                                  )
                                
                              ),
                              child: Text(
                                "下一步",
                                style: _biggerFont
                              ),
                          ),
                          onPressed: (){
                              if(sources.length == 0 || goals.length == 0){
                                  Toast.toast(context,msg:"源容器和目标容器都不能为空");
                                  return;
                              }
                              Navigator.pushNamed(context, '/way',arguments:<String,dynamic>{
                                  "prev":sources,
                                  "next":goals,
                                  "shop_processes_id":widget.arguments['id'],
                                  'remark':widget.arguments['remark'],
                                  'mode':widget.arguments['mode'],
                              });
                          }
                        )
                ),
            ],
          )
       )
    );
  }
}



class ListItem extends StatefulWidget{
   ListItem({this.item,this.type,this.delete});
   dynamic item,type,delete;
    @override
   createState()=> _ListItem();
}
class _ListItem extends State<ListItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12,width: 2),
            borderRadius: BorderRadius.circular(20),
            color:Colors.white
          ),
          child:FlatButton(
                child: Text(
                  widget.item,
                  style: _biggerFont,
                ),
                onPressed: (){
                  widget.delete(widget.item,widget.type);
                }
          )
      );
  }
}