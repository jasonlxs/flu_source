
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/api/source.dart';
import '../util/toast.dart';
import '../util/size.dart';
import '../util/api/user.dart';


class TaskPage extends StatefulWidget{
   final Map arguments;
   TaskPage({Key key, this.arguments});
   @override
   createState()=> _TaskPageState();
}


class _TaskPageState extends State<TaskPage>{
    List<dynamic> source_list = [];
    ///初始函数
    void initState() {
       //接收参数并请求接口
        source_process(<String, dynamic>{
          "type":widget.arguments['processes_type'],
          "append_shops_id":widget.arguments['shops_id']
        },context).then((res){
           if( res['status'] == 10000 ){
                setState(() {
                  source_list = res['data'];
                });
              //  print(source_list.length);
           }else{
             Toast.toast(context,msg:res['info']);
           }
        }).catchError((err){
           print(err);
        });
    }
    
   Widget _buildRow(dynamic item) {
    return new ListTile(
      title: new ListItem(
        item:item
      ),
    );
  }

  DateTime lastPopTime;

  Widget build(BuildContext context){
    
      //渲染页面
     return WillPopScope(
      child:Scaffold(
        appBar: new AppBar(
        ///标题
         title: new Text("任务选择"),
         automaticallyImplyLeading: false,
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
       body:Container(
          child: ListView.builder(
            padding: const EdgeInsets.all(5.0),
            itemCount: source_list.length,
            itemBuilder: (context, i) {
              return _buildRow(source_list[i]);
            },
          )
       ),
      ),
      onWillPop: () async{
        // 点击返回键的操作
        if(lastPopTime == null || DateTime.now().difference(lastPopTime) > Duration(seconds: 2)){
          lastPopTime = DateTime.now();
          Toast.toast(context,msg: '再按一次退出');
        }else{
          lastPopTime = DateTime.now();
          // 退出app
          await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      },
     );
  }
}

class ListItem extends StatelessWidget {
  
  ListItem({this.item});
  dynamic item;
  final _biggerFont = const TextStyle(fontSize: 25.0);
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
          height: SizeConfig.blockSizeVertical*10,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12,width: 2),
            borderRadius: BorderRadius.circular(20),
            image: new DecorationImage(
               image: AssetImage("lib/assets/tit.png"),
                //  fit: BoxFit.cover,
                //这里是从assets静态文件中获取的，也可以new NetworkImage(）从网络上获取
                centerSlice: new Rect.fromLTRB(270.0, 180.0, 1360.0, 730.0),
            )
          ),
          
          child:GestureDetector(

              child:Container(
                padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal*4),
                child:Text(
                  this.item['remark'],
                  style: _biggerFont,
                ),
              ),
              onTap: (){
                  Navigator.pushNamed(context, '/nfc',arguments:this.item);
              }
          )
      );
  }
}

