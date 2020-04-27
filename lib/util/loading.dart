
import 'package:flutter/material.dart';
 


class Loading {
    
    
  static BuildContext ctx;

  /**
   * 弹出加载框
   * @param {type} 
   * @return: 
   */
  static showLoading(BuildContext context,{String msg = "加载中..."}){
     
      ctx = context;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return Dialog(
              child: Container(
                width: 100,
                height:100,
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: const CircularProgressIndicator(),
                    ),

                    Container(
                        margin: const EdgeInsets.only(left:20.0),
                        child: Text(
                          msg,
                          style: TextStyle(color: Colors.black, fontSize: 20.0),
                      )),
                  ], 
                )
              ),
          );
        }
      );
    }


    /**
     * 关闭加载框 
     * @param {type} 
     * @return: 
     */
    static closeLoading(){
        Navigator.of(ctx).pop();
    }
    



}

