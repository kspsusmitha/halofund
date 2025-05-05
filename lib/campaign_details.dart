import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:halofund/home_view.dart';
import 'package:halofund/payment_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';



class Campaign_Details extends StatefulWidget {
   Campaign_Details({super.key,required this.info});

  CampaignModel info;
  @override
  State<Campaign_Details> createState() => _Campaign_DetailsState();
}

class _Campaign_DetailsState extends State<Campaign_Details> {

  Image base64ToImageWidget(String base64String) {
    var bytes = base64Decode(base64String);
    return Image.memory(bytes, height: 200,
      width: double.infinity,
      fit: BoxFit.fill,);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Campaign Details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700
                ),),
                SizedBox(
                  height: 10,
                ),
                ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: base64ToImageWidget("${widget.info.image}",)
                ),
            
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text("Help Save a Life: Support  on Their \nHealing Journey",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16
                  ),),
                ),
                Text("Fundraising Goal",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700
                ),),
                Text("₨ ${widget.info.amount}",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20
                ),),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Raised: ₨ ${widget.info.amountRaised}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text("Goal: ₨ ${widget.info.amount}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: double.tryParse(widget.info.amountRaised) != null && double.tryParse(widget.info.amount) != null
                          ? double.parse(widget.info.amountRaised) / double.parse(widget.info.amount)
                          : 0.0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Text("Patient Profile Section",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700
                ),),
                _patitiontDetails("Name: ","${widget.info.name}"),
                SizedBox(
                  height: 10,
                ),
                _patitiontDetails("age: ","${widget.info.age} years old"),
                SizedBox(
                  height: 10,
                ),
                _patitiontDetails("Location: ","New York, USA"),
                SizedBox(
                  height: 10,
                ),
                _patitiontDetails("Medical Condition: ","${widget.info.medicalCondition}"),
                SizedBox(
                  height: 10,
                ),
                _patitiontDetails("Treatment Required: ","${widget.info.treatmentRequired}"),
            
                SizedBox(
                  height: 30,
                ),
                Text("Medical Documents & Reports",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700
                ),),
                SizedBox(
                  height: 15,
                ),
                _buildDownloadSection("Doctor's Diagnosis Report",),
                SizedBox(
                  height: 10,
                ),
            
                InkWell(
                    onTap: () {
                      Future<void> saveBase64Image(String base64String, String fileName) async {
                        // Request storage permission
                        var status = await Permission.storage.request();
                        if (!status.isGranted) {
                          print("Permission denied");
                          return;
                        }
            
                        try {
                          // Decode base64
                          var bytes = base64Decode(base64String);
            
                          // Get directory
                          Directory directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
                          String filePath = '${directory.path}/$fileName.jpg';
            
                          // Save file
                          File imgFile = File(filePath);
                          await imgFile.writeAsBytes(bytes);
            
                          print("Image saved to: $filePath");
                        } catch (e) {
                          print("Error saving image: $e");
                        }
                      }
                    },
                    child: _buildDownloadSection("Hospital Bill Estimate")),

                Center(
                  child: InkWell(
                    onTap: () {
                      print("Donate");
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentView(model: widget.info),));
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 50),
                      alignment: Alignment.center,
                      height: 50,
                      width: 200,
                       child: Text("Donate",style: TextStyle(
                         color: Colors.white,
                         fontSize: 20,
                         fontWeight: FontWeight.bold
                       ),),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(25)
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _patitiontDetails(String title,String value){

  return RichText(text: TextSpan(
      text: "$title: ",
      style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w700
      ),
      children: [
        TextSpan(text: "$value",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 16
            ))
      ]
  ));

}

Widget _buildDownloadSection(String title) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
      Container(
        height: 30,
        width: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Text("⇣ Download"),
      ),
    ],
  );
}