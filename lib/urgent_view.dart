import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'campaign_details.dart';
import 'home_view.dart';

class UrgentView extends StatefulWidget {
  const UrgentView({super.key});

  @override
  State<UrgentView> createState() => _UrgentViewState();
}

class _UrgentViewState extends State<UrgentView> {
  List<CampaignModel>? model;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAndFilterPatients();
  }

  Image base64ToImageWidget(String base64String) {
    try {
      var bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        height: 150,
        width: 150,
      );
    } catch (e) {
      print("Image decoding error: $e");
      return Image.asset("assets/icons/appicon.png", height: 150, width: 150);
    }
  }
  Future<void> fetchAndFilterPatients() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('patients').get();

      List<CampaignModel> data = snapshot.docs
          .map((doc) => CampaignModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      model = data
          .where((item) => item.urgency == true && item.status == true)
          .toList();
    } catch (e) {
      print("Error fetching data: $e");
      model = [];
    }

    setState(() {
      isLoading = false;
    });
  }
  // Future<void> fetchProducts() async {
  //   setState(() => isLoading = true);
  //   try {
  //     QuerySnapshot snapshot = await FirebaseFirestore.instance
  //         .collection('patients')
  //         .get();
  //
  //     model = snapshot.docs
  //         .map((doc) =>
  //         CampaignModel.fromMap(doc.data() as Map<String, dynamic>))
  //         .where((item) => item.urgency == true || item.status == true) // 👈 filter
  //         .toList();
  //   } catch (e) {
  //     print("Error fetching products: $e");
  //     model = [];
  //   }
  //   setState(() => isLoading = false);
  // }
  // Future<void> fetchProducts() async {
  //   setState(() => isLoading = true);
  //   try {
  //     QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('patients').get();
  //     model = snapshot.docs
  //         .map((doc) => CampaignModel.fromMap(doc.data() as Map<String, dynamic>))
  //         .toList();
  //   } catch (e) {
  //     print("Error fetching products: $e");
  //     model = [];
  //   }
  //   setState(() => isLoading = false);
  // }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Urgent Campaigns"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : model == null || model!.isEmpty
          ? const Center(child: Text("No campaigns found."))
          : ListView.builder(
        itemCount: model!.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final item = model![index];
          print("urgency : ${item.urgency}");

          // if (item.urgency != true && item.status != true) {
          //   print("urgency ");
          //   return const SizedBox.shrink();}
          // else{
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(10),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: base64ToImageWidget(item.image ?? ""),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.name ?? "",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.medicalCondition ?? "",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Campaign_Details(info: item),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "View Details",
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );}
        // },
      ),
    );
  }
}
