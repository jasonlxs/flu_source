import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_chain/widget_chain.dart';


import '../util/size.dart';
import '../util/api/user.dart';
import '../util/toast.dart';





Color _randomColor(){
    var red = Random.secure().nextInt(255);
    var green = Random.secure().nextInt(255);
    var blue = Random.secure().nextInt(255);
    return Color.fromARGB(255, red, green, blue);
}

class LoginPage extends StatefulWidget{
  //  LoginPage({this.ctx});
  //  BuildContext ctx ;

   @override
   createState()=> _LoginPageState ();
}


class _LoginPageState extends State<LoginPage>{

  final _formKey = GlobalKey<FormState>();

  String _account, _password;
  bool _isObscure = true;
  Color _eyeColor;
  bool _isChecked = false;

   List _loginMethod = [
    {
      "title": "QQ",
      "icon": FontAwesomeIcons.qq,
    },
    {
      "title": "微信",
      "icon": FontAwesomeIcons.weixin,
    },
  ];

  void initStatus(){

  }


DateTime lastPopTime;

  Widget build(BuildContext context){
     SizeConfig().init(context);
     return WillPopScope(
       child: Scaffold(
       body:Container(
          padding:EdgeInsets.symmetric(horizontal: 20),
          decoration: new BoxDecoration(
            image: new DecorationImage(
               image: AssetImage("lib/assets/bk.png"),
                //  fit: BoxFit.cover,
                //这里是从assets静态文件中获取的，也可以new NetworkImage(）从网络上获取
                centerSlice: new Rect.fromLTRB(270.0, 180.0, 1360.0, 730.0),
            )
          ),
          child: Form(
              key: _formKey,
              child:Stack(
                        children: <Widget>[
                          ListView(
                            children: <Widget>[
                                     
                                    SizedBox(height: SizeConfig.blockSizeHorizontal*20),
                                    buildTitle(),
                                    SizedBox(height: 20.0),
                                    bulidAccountTextField(),
                                    SizedBox(height: 30.0),
                                    buildPasswordTextField(context),
                                    // buildForgetPasswordText(context),
                                    buildAutoSaved(context),

                                    SizedBox(height: 10.0),
                                    buildLoginButton(context),
                                    SizedBox(height: 30.0),
                                    // buildOtherLoginText(),
                                    // buildOtherMethod(context),
                                    // buildRegisterText(context), 
                            ],
                          ),
                        ],
                    ).intoContainer()
              ),
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


  ///创建标题
   Container buildTitle() {
    Widget rich = RichText(
      text:TextSpan(
        text: '福鼎',
        style: TextStyle(color:Colors.black,fontSize: 30),
        children: <TextSpan>[
          TextSpan(
            text: '白茶溯源系统',
            style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),
          ),
        ]
      ),
    );
    return  Stack(
          overflow: Overflow.visible,
          children: <Widget>[
             rich,
             Positioned(
               right: -45,
               top:0,
               child:  IconButton(
                    icon: new Icon(Icons.info),
                    color:Colors.black,
                    onPressed: (){}  // null 会禁用 button
                ),
             ),
            
            Positioned(
              left:0,
              bottom:-6.0,
              child: new Container(
                color:Colors.black,
                width: 60,
                height: 3, 
              ),
            )
          ],
        ).intoContainer(
          alignment:Alignment.centerLeft,
          padding: EdgeInsets.all(8.0),
        );
  }

  //创建账号输入 text输入
  TextFormField bulidAccountTextField(){
     return TextFormField(
       decoration: InputDecoration(
         contentPadding: EdgeInsets.all(1.0),
         icon: Icon(
            Icons.account_box,
            size: 25,
          ),
          labelText: "请输入你的账号",
        ),
        validator: (String value){
          // var accountReg = RegExp(
          //   r"[\w!#$%&'*+/=?^_`{|}~-]+(?:\.[\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\w](?:[\w-]*[\w])?\.)+[\w](?:[\w-]*[\w])?");
          //  if (!accountReg.hasMatch(value)) {
          //     return '请输入正确的邮箱地址';
          //  }
           if (value.isEmpty) {
              return '请输入账号';
          }
          
        },
        onSaved: (String value) => _account = value,
     );
  }
  //创建密码输入 text输入
   TextFormField buildPasswordTextField(BuildContext context) {
    return TextFormField(
      onSaved: (String value) => _password = value,
      obscureText: _isObscure,
      validator: (String value) {
        if (value.isEmpty) {
          return '请输入密码';
        }
        
      },
      decoration: InputDecoration(
          labelText: '请输入你的密码',
          contentPadding: EdgeInsets.all(1.0),
          icon: Icon(
              Icons.https,
              size:25
          ),
          suffixIcon: IconButton(
              icon: Icon(
                Icons.remove_red_eye,
                color: _eyeColor,
              ),
              onPressed: () {
                setState(() {
                  _isObscure = !_isObscure;
                  _eyeColor = _isObscure
                      ? Colors.grey
                      : Theme.of(context).iconTheme.color;
                });
              }
            )
      ),
    );
  }

  ///忘记密码
  Padding buildForgetPasswordText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: FlatButton(
          child: Text(
            '忘记密码？',
            style: TextStyle(fontSize: 14.0, color: Colors.grey),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  //单选checkbox
  Row buildAutoSaved(BuildContext context){
      Color color = _randomColor();
      return Row(
        mainAxisAlignment:MainAxisAlignment.end,
        children: <Widget>[
          Checkbox(
            activeColor: color,
            tristate: false,
            value: _isChecked,
            onChanged: (bool bol){
              if(mounted){
                setState(() {
                  _isChecked = bol;
                });
              }
            }
          ),
          Text('记住密码')
        ],
      );
  }


   ///登录按钮
  Align buildLoginButton(BuildContext context){
  
    Widget raise = RaisedButton(
          child: Text(
            'Login',
             style: Theme.of(context).primaryTextTheme.bodyText1,
          ),
          color: Colors.black,
          onPressed: () async {
         
            //跳转任务页面
            // Navigator.pushNamed(context, '/task');
            // Navigator.of(context).pushReplacementNamed("/task");
            if(_formKey.currentState.validate() ){
                ///只有输入的内容符合要求通过才会到达此处
              _formKey.currentState.save();
              //TODO 执行登录方法
              login(<String, dynamic>{
                "account":_account,
                "password":_password
              },context).then((res) async {
                if(res['status'] == 10000){

                
                  var cache = await SharedPreferences.getInstance();

                  cache.setString("token", res['data']['token']);
                  cache.setString("role", res['data']['role']);
                  cache.setInt("shops_id", res['data']['shops'][0]['shops_id']);
                  cache.setInt("processes_type", res['data']['shops'][0]['with_processes_type']['id']);

                  //弹窗
                  Toast.toast(context,msg: res['info']);
                  Future.delayed(Duration(microseconds: 300), () {
                      Navigator.pushNamed(context, '/task',arguments:<String, dynamic>{
                        "shops_id": res['data']['shops'][0]['shops_id'],
                        "processes_type":res['data']['shops'][0]['with_processes_type']['id']
                      });
                  });
                
                }else{
                  Toast.toast(context,msg: res['info']);
                }
               
              }).catchError((err){
                  print(err);
                   
              });
              
            }
          },
          shape: StadiumBorder(side:BorderSide()),
    );

    return Align(
      child: SizedBox(
        height: 40,
        width:270,
        child: raise
      ),
    );
  }




  ///其它账号
  Align buildOtherLoginText(){
    return Align(
      alignment: Alignment.center,
      child: Text(
        '其它账号登录',
        style: TextStyle(color:Colors.grey,fontSize: 14),
      ),
    );
  }


  ///第三方登录
  ButtonBar buildOtherMethod(BuildContext context){
      return ButtonBar(
        alignment: MainAxisAlignment.center,
        children: _loginMethod.map((item)=>Builder(
            builder: (context){
              return IconButton(
                icon: Icon(
                  item['icon'],
                  color:Theme.of(context).iconTheme.color
                ),
                onPressed: (){
                    Scaffold.of(context).showSnackBar(
                      new SnackBar(
                        content: new Text("${item['title']}登录"),
                        action: new SnackBarAction(
                          label: "取消",
                          onPressed: (){},
                        ),
                      )
                    );
                },
              );
            },
        )).toList(),
      );
  }
   

  ///注册
  Align buildRegisterText(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('没有账号？'),
            GestureDetector(
              child: Text(
                '点击注册',
                style: TextStyle(color: Colors.green),
              ),
              onTap: () {
                //TODO 跳转到注册页面
                print('去注册');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

