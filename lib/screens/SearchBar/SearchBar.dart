import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 5, bottom: 10),
      child: Row(
        children: <Widget>[
          new Container(
              width: 160,
              height: 44,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    enabledBorder: InputBorder.none,
                    hintText: 'From',
                    labelStyle: TextStyle(
                      fontFamily: 'AlegreyaSansSC',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              decoration: new BoxDecoration(
                color: Color(0xffffffff),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black54,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      spreadRadius: 0)
                ],
              )),
          Padding(
            padding: EdgeInsets.only(left: 20),
          ),
          Container(
              width: 160,
              height: 44,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    enabledBorder: InputBorder.none,
                    hintText: 'To',
                    labelStyle: TextStyle(
                      fontFamily: 'AlegreyaSansSC',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              decoration: new BoxDecoration(
                color: Color(0xffffffff),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black54,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      spreadRadius: 0)
                ],
              ))
        ],
      ),
    );
  }
}
