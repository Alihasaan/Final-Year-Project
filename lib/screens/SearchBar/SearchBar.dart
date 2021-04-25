import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return /* Container(
      margin: EdgeInsets.only(
        left: 3,
        right: 3,
        bottom: 10,
      ),
      padding: EdgeInsets.only(left: 5, right: 5, top: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 15, left: 5),
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withOpacity(.3),
                        border: Border.all(color: Colors.blue, width: 3.0),
                      ),
                    ),
                    SizedBox(width: 15.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "From",
                          style: Theme.of(context)
                              .textTheme
                              .subtitle
                              .apply(color: Colors.black38),
                        ),
                        Container(
                            width: 200,
                            height: 44,
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: TextField(
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    letterSpacing: 0,
                                    color: Colors.black87),
                                decoration: InputDecoration(
                                  enabledBorder: InputBorder.none,
                                  hintText: 'Your Location',
                                  hintStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal,
                                      letterSpacing: 0,
                                      color: Colors.black87),
                                ),
                              ),
                            ),
                            decoration: new BoxDecoration(
                              color: Color(0xffffffff),
                              borderRadius: BorderRadius.circular(15),
                            )),
                      ],
                    )
                  ],
                ),
                Divider(
                  height: 25,
                  color: Colors.black,
                  thickness: .7,
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 20, left: 5),
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange.withOpacity(.3),
                        border: Border.all(color: Colors.orange, width: 3.0),
                      ),
                    ),
                    SizedBox(width: 15.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "To",
                          style: Theme.of(context)
                              .textTheme
                              .subtitle
                              .apply(color: Colors.black38),
                        ),
                        Container(
                            width: 200,
                            height: 44,
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: TextField(
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    letterSpacing: 0,
                                    color: Colors.black87),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0),
                                  enabledBorder: InputBorder.none,
                                  hintText: 'Choose A Destination',
                                  hintStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal,
                                      letterSpacing: 0,
                                      color: Colors.black87),
                                ),
                              ),
                            ),
                            decoration: new BoxDecoration(
                              color: Color(0xffffffff),
                              borderRadius: BorderRadius.circular(15),
                            )),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 15.0,
          ),
          Container(
            decoration: BoxDecoration(
                color: Color(0xfff0f3f7),
                borderRadius: BorderRadius.circular(5.0)),
            child: IconButton(
              icon: Icon(
                Icons.import_export,
                color: Colors.black54,
              ),
              onPressed: () {},
            ),
          )
        ],
      ),
    );*/

        Padding(
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
