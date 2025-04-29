import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatCampaign extends StatefulWidget {
  const CreatCampaign({super.key});

  @override
  State<CreatCampaign> createState() => _CreatCampaignState();
}

class _CreatCampaignState extends State<CreatCampaign> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final conditionController = TextEditingController();
  final treatmentController = TextEditingController();
  final amountController = TextEditingController();

  final List<String> gender = ["Male", "Female"];
  String? selectedGender;

  File? _imageUser;
  File? _imageDiagnosisReport;
  File? _imageBillEstimate;
  bool urgent = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _showImageSourceDialog(String type) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Choose Image Source"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera, type);
            },
            child: Text("Camera"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery, type);
            },
            child: Text("Gallery"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, String type) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        File image = File(pickedFile.path);
        if (type == "user") {
          _imageUser = image;
        } else if (type == "report") {
          _imageDiagnosisReport = image;
        } else if (type == "bill") {
          _imageBillEstimate = image;
        }
      });
    }
  }

  String? convertImageToBase64(File? imageFile) {
    if (imageFile == null) return null;
    final bytes = imageFile.readAsBytesSync();
    return base64Encode(bytes);
  }


  // compress image

  Future<String> convertCompressedImageToBase64(File? imageFile) async {
    if (imageFile == null) return "null";

    // Compress the image to 60% quality
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      imageFile.path,
      minWidth: 600,  // Resize if needed
      minHeight: 600,
      quality: 60,    // Adjust quality (1 to 100)
    );

    if (compressedBytes == null) return "null";

    print(base64Encode(compressedBytes));
    // Convert compressed bytes to Base64
    return base64Encode(compressedBytes);
  }


  Future<void> postToFirestore(Map<String, dynamic> data, String collectionName) async {
    try {
      await FirebaseFirestore.instance.collection(collectionName).add(data);
    } catch (e) {
      print("❌ Failed to post data: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Campaign")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: "Enter Patient Name", border: OutlineInputBorder()),
          ),
          SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: "Age", border: OutlineInputBorder()),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedGender,
                hint: Text("Select Gender"),
                onChanged: (value) => setState(() => selectedGender = value),
                items: gender.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
            ),
          ]),
          SizedBox(height: 10),
          TextField(
            keyboardType: TextInputType.number,
            controller: phoneController,
            decoration: InputDecoration(hintText: "Contact Number", border: OutlineInputBorder()),
          ),
          SizedBox(height: 10),
          TextField(
            controller: addressController,
            maxLines: 3,
            decoration: InputDecoration(hintText: "Address", border: OutlineInputBorder()),
          ),
          SizedBox(height: 10),
          TextField(
            controller: conditionController,
            decoration: InputDecoration(hintText: "Medical Condition", border: OutlineInputBorder()),
          ),
          SizedBox(height: 10),
          TextField(
            controller: treatmentController,
            maxLines: 3,
            decoration: InputDecoration(hintText: "Treatment Required", border: OutlineInputBorder()),
          ),
          SizedBox(height: 10),
          InkWell(
            onTap: () => _showImageSourceDialog("user"),
            child: _imageUser != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(_imageUser!, height: 200, width: double.infinity, fit: BoxFit.cover),
            )
                : Image.asset("assets/images/placeholderImage.png", height: 200, fit: BoxFit.fill,width: double.infinity,),
          ),
          SizedBox(height: 10),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.numberWithOptions(),
            decoration: InputDecoration(hintText: "Enter Amount", border: OutlineInputBorder()),
          ),
          SizedBox(height: 10),
          InkWell(onTap: () => _showImageSourceDialog("report"), child: _buildUploadSection("Doctor’s Diagnosis Report")),
          SizedBox(height: 10),
          InkWell(onTap: () => _showImageSourceDialog("bill"), child: _buildUploadSection("Hospital Bill Estimate")),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Need urgent help",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),),
              Switch(value: urgent, onChanged: (value) {
                setState(() {
                  urgent = value;
                });
              },)
            ],
          ),
          SizedBox(height: 20),

          TextButton(
            style: TextButton.styleFrom(minimumSize: Size(double.infinity, 50), backgroundColor: Color(0xff2770FF)),
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text("Uploading campaign...", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              );

              try {
                // String? userImageBase64 = convertImageToBase64(_imageUser);
                // String? diagnosisImageBase64 = convertImageToBase64(_imageDiagnosisReport);
                // String? billImageBase64 = convertImageToBase64(_imageBillEstimate);
                // print(convertCompressedImageToBase64(_imageUser));
                var img = await convertCompressedImageToBase64(_imageUser);
                var report = await convertCompressedImageToBase64(_imageDiagnosisReport);
                var bill = await convertCompressedImageToBase64(_imageBillEstimate);
                log("base 64 image ===> ${img}");
                Map<String, dynamic> campaignData = {
                  'Phone': "${phoneController.text}",
                  'address': "${addressController.text}",
                  'age': "${ageController.text}",
                  'amount': "${amountController.text}",
                  'doctors_diagnosis_report': "${report}",
                  'gender': "${selectedGender}",
                  'hospital_bill_stimate': "${bill}",
                  'image': img,
                  'medical_condition': "${conditionController.text}",
                  'name': "${nameController.text}",
                  'timestamp': "${FieldValue.serverTimestamp()}",
                  'treatment_required': "${treatmentController.text}",
                  'status': false,
                  'urgency': urgent,

                };

                await postToFirestore(campaignData, 'patients');
                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Success"),
                    content: const Text("Campaign created successfully!"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Error"),
                    content: Text("Something went wrong: $e"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ]),
      ),
    );
  }

  Widget _buildUploadSection(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        Container(
          height: 30,
          width: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.black),
          ),
          child: Text("+ Upload"),
        ),
      ],
    );
  }
}
