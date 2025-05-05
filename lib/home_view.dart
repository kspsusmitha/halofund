import 'dart:convert';
//
// import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
// import 'dart:typed_data'; // ✅ this is the correct one
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:halofund/all.dart';
import 'package:halofund/campaign_details.dart';
import 'package:halofund/creat_campaign.dart';
import 'package:halofund/urgent_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:halofund/profile_view.dart';



class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final cat = [
    {"name": "All", "icon": Icons.category},
    {"name": "Urgent", "icon": Icons.warning},
    {"name": "Create Help", "icon": Icons.add_circle},
  ];




  int selectedPage = 0;
  final PageController _pageController = PageController();

  List<CampaignModel>? model;
  bool isLoading = false;

  Future<List<CampaignModel>?> fetchProducts() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('patients').get();
      setState(() {
        isLoading = false;
      });
      model =  snapshot.docs
          .map((doc) => CampaignModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      return model;
    } catch (e) {
      print("Error fetching products: $e");
      setState(() {
        isLoading = false;
      });
      return [];
    }

  }
  // Future<List<Map<String, dynamic>>> fetchProducts() async {
  //   try {
  //     QuerySnapshot snapshot =
  //     await FirebaseFirestore.instance.collection('patients').get();
  //
  //     List<Map<String, dynamic>> products = snapshot.docs.map((doc) {
  //       return {
  //         'amount': doc['amount'] ?? '',
  //         'phone': doc['Phone'] ?? '',
  //         'address': doc['address'] ?? '',
  //         'age': doc['age'] ?? '',
  //         'gender': doc['gender'] ?? '',
  //         'image': doc['image'] ?? '',
  //         'medical_condition': doc['medical_condition'] ?? '',
  //         'name': doc['name'] ?? '',
  //         'treatment_required': doc['treatment_required'] ?? '',
  //         'doctors_diagnosis_report': doc['doctors_diagnosis_report'] ?? '',
  //         'hospital_bill_stimate': doc['hospital_bill_stimate'] ?? '',
  //         'timestamp': doc['timestamp'] ?? '',
  //       };
  //     }).toList();
  //
  //     return products;
  //   } catch (e) {
  //     print("Error fetching products: $e");
  //     return [];
  //   }
  // }



  Image base64ToImageWidget(String base64String) {
    var bytes = base64Decode(base64String);
    return Image.memory(bytes, fit: BoxFit.cover,height: 150, width: 150,);
  }

  List<String> banners = ["https://img.freepik.com/free-psd/charity-activities-banner-template_23-2148943847.jpg?semt=ais_hybrid&w=740",
    "https://img.freepik.com/free-psd/flat-design-social-activity-youtube-cover_23-2150399881.jpg?semt=ais_hybrid&w=740",
    "https://img.freepik.com/free-psd/flat-design-social-activity-facebook-cover_23-2150399895.jpg"];


  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xffdad6d6),
      appBar: AppBar(
        backgroundColor: const Color(0xffefeeee),
        leading: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileView()),
            );
          },
          child: const Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
          ),
        ),
        title: Text(
          "Hi, User",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CarouselSlider.builder(
              itemCount: banners.length,
              itemBuilder: (context, index, realIndex) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.purple,
                    image:   DecorationImage(
                      image: NetworkImage(banners[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: 170,
                enlargeCenterPage: true,
                autoPlay: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    selectedPage = index;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            AnimatedSmoothIndicator(
              // controller: _pageController,
              count: 3,
              effect:  SlideEffect(
                dotHeight: 12,
                dotWidth: 12,
                activeDotColor: Colors.purple,
                dotColor: Colors.grey,
              ), activeIndex: selectedPage,

            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: cat.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          if (index == 2) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CreatCampaign()),
                            );
                          } else if (index == 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const All()),
                            );
                          }else if(index == 1){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => UrgentView(),));
                          }
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey.shade300,
                          child: Icon(
                            cat[index]["icon"] as IconData?,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat[index]["name"] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 70),
              ),
            ),
            const SizedBox(height: 20),
            isLoading? Center(child: CircularProgressIndicator()):
            ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: model?.length ?? 1,
          itemBuilder: (context, index) {
            if(model?.length == 0){
              return Text("Campaign not font");
            }else{
              return model![index].status? Container(
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
                      child: base64ToImageWidget(
                          model?[index].image ?? ""),
                      // child: Image.file(
                      //   campaign["image"] ?? "",
                      //   height: 150,
                      //   width: 150,
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            model?[index].name ?? "",
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
                              model?[index].medicalCondition ?? "",
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
                                    builder: (context) =>
                                        Campaign_Details(
                                          info: model![index],),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10),
                                ),
                              ),
                              child: Text(
                                "View Details",
                                style: GoogleFonts.poppins(
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ): Divider();
            }



          },
          separatorBuilder: (_, __) => const SizedBox(height: 20),
        ),
          ],
        ),
      ),
    );
  }
}




//model

class CampaignModel {
  final bool  urgency;
  final bool  status;
  final String amount;
  final String phone;
  final String address;
  final String age;
  final String gender;
  final String image;
  final String medicalCondition;
  final String name;
  final String treatmentRequired;
  final String doctorsDiagnosisReport;
  final String hospitalBillEstimate;
  final dynamic timestamp; // You can change to `Timestamp` if needed

  CampaignModel({
    required this.amount,
    required this.phone,
    required this.address,
    required this.age,
    required this.gender,
    required this.image,
    required this.medicalCondition,
    required this.name,
    required this.treatmentRequired,
    required this.doctorsDiagnosisReport,
    required this.hospitalBillEstimate,
    required this.timestamp,
    required this.status,
    required this.urgency
  });

  factory CampaignModel.fromMap(Map<String, dynamic> map) {
    return CampaignModel(
      amount: map['amount'] ?? '',
      phone: map['Phone'] ?? '',
      address: map['address'] ?? '',
      age: map['age'] ?? '',
      gender: map['gender'] ?? '',
      image: map['image'] ?? '',
      medicalCondition: map['medical_condition'] ?? '',
      name: map['name'] ?? '',
      treatmentRequired: map['treatment_required'] ?? '',
      doctorsDiagnosisReport: map['doctors_diagnosis_report'] ?? '',
      hospitalBillEstimate: map['hospital_bill_stimate'] ?? '',
      timestamp: map['timestamp'] ?? '',
      status: map['status'] ?? false,
      urgency: map['urgency'] ?? false
    );
  }



}
