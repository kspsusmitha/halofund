import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'campaign_details.dart';
import 'home_view.dart';

class All extends StatefulWidget {
  const All({super.key});

  @override
  State<All> createState() => _AllState();
}

class _AllState extends State<All> {
  List<CampaignModel>? model;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<List<CampaignModel>?> fetchProducts() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('patients').get();
      model = snapshot.docs
          .map((doc) => CampaignModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      setState(() {
        isLoading = false;
      });
      return model;
    } catch (e) {
      print("Error fetching products: $e");
      setState(() {
        isLoading = false;
      });
      return [];
    }
  }

  Widget base64ToImageWidget(String base64String) {
    try {
      var bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        height: 150,
        width: 150,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
      );
    } catch (_) {
      return  Icon(Icons.broken_image);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("All"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : model == null || model!.isEmpty
          ? const Center(child: Text("No campaigns found"))
          : ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        itemCount: model!.length,
        itemBuilder: (context, index) {
          final item = model![index];
          if (!item.status) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(10),
            height: 200,
            width: width - 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: base64ToImageWidget(item.image ?? ""),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
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
                      Flexible(
                        child: Text(
                          item.medicalCondition ?? "",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: ElevatedButton(
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 20),
      ),
    );
  }
}
//
// class CampaignModel {
//   final String? name;
//   final String? medicalCondition;
//   final String? image;
//   final bool status;
//
//   CampaignModel({this.name, this.medicalCondition, this.image, required this.status});
//
//   factory CampaignModel.fromMap(Map<String, dynamic> map) {
//     return CampaignModel(
//       name: map['name'] ?? '',
//       medicalCondition: map['medicalCondition'] ?? '',
//       image: map['image'] ?? '',
//       status: map['status'] ?? false,
//     );
//   }
// }
