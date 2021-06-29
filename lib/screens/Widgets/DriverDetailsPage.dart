import 'package:flutter/material.dart';
import 'package:onlineTaxiApp/Models/driverModel.dart';
import 'package:onlineTaxiApp/utilities/constants.dart';

class DriverDetails extends StatelessWidget {
  final DriverModel driver;
  DriverDetails({Key? key, required this.driver}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("!----------------------!----Driver Details : ");
    print(driver.driverName);
    return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
                height: MediaQuery.of(context).size.height / height,
                padding: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                        color: priText,
                        blurRadius: 16,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7))
                  ],
                ),
                child: driver.driverID != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            SizedBox(
                              height: 5,
                            ),
                            Center(
                              child: Text("Rider Details",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'OpenSans',
                                  )),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.lightGreen[100],
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 65,
                                  ),
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: primary,
                                    child: ClipOval(
                                      child: SizedBox(
                                          width: 80,
                                          height: 80,
                                          child: Image.network(driver
                                              .driverPhotoUrl
                                              .toString())),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    children: [
                                      Text(driver.driverName.toString(),
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: 'OpenSans')),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.phone_android,
                                          ),
                                          Text(driver.driverPhoneno.toString(),
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.normal,
                                                  fontFamily: 'OpenSans')),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          ])
                    : SizedBox(
                        width: 80,
                        height: 100,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(
                                  color: primary,
                                ),
                                SizedBox(height: 20),
                                Text("Loading...",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: 'OpenSans'))
                              ],
                            ),
                          ),
                        ),
                      ))));
  }
}
