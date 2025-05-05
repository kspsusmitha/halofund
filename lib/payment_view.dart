import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halofund/home_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'card_pay.dart';

class PaymentView extends StatefulWidget {
  PaymentView({super.key, this.model});
  CampaignModel? model;
  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final TextEditingController _amountController = TextEditingController();

  Image base64ToImageWidget(String base64String) {
    var bytes = base64Decode(base64String);
    return Image.memory(bytes, fit: BoxFit.cover, height: 150, width: 150);
  }

  String? selectedValue;
  final List<String> items = [
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTiQRKnmlKMKmpkZTUXfuy4PXqmepDcQNqaxA&s",
    'https://lh3.googleusercontent.com/KE8W2U_931n24DtWrvySEdKwnx6dLeaoaXBV6nXNHKbJd32mnIx-eaxXPdsRscJMT8vxyLy59XKVkr_UXlswXFJ2KjomzkqV-ud3=s0',
    'https://cuvette.tech/blog/wp-content/uploads/2024/06/PhonePe-Logo.wine_.png',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSOK-ExH64w4vaz6r2HY7kpEc0SEZKmpq7CKg&s',
  ];
  bool anonymous = false;

  Future<void> _handleDonation() async {
    final campaign = widget.model;
    if (campaign == null) return;
    final String campaignId = await _getCampaignIdByNameAndAmount(campaign.name, campaign.amount);
    final String enteredAmount = _amountController.text.trim();
    if (enteredAmount.isEmpty || double.tryParse(enteredAmount) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }
    final double donation = double.parse(enteredAmount);
    try {
      // Fetch current amount_raised
      final docRef = FirebaseFirestore.instance.collection('patients').doc(campaignId);
      final docSnap = await docRef.get();
      double currentRaised = 0;
      if (docSnap.exists && docSnap.data() != null && docSnap.data()!.containsKey('amount_raised')) {
        currentRaised = double.tryParse(docSnap['amount_raised'].toString()) ?? 0;
      }
      final double newRaised = currentRaised + donation;
      await docRef.update({'amount_raised': newRaised.toStringAsFixed(2)});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your donation!')),
      );
      if (mounted) {
        Navigator.pop(context); // Go back to campaign details
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    }
  }

  Future<String> _getCampaignIdByNameAndAmount(String name, String amount) async {
    // This assumes name+amount is unique. Adjust as needed for your data model.
    final query = await FirebaseFirestore.instance
        .collection('patients')
        .where('name', isEqualTo: name)
        .where('amount', isEqualTo: amount)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }
    throw Exception('Campaign not found');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text("Pay")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              height: 150,
              width: double.infinity,
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
                    child: base64ToImageWidget(widget.model?.image ?? ""),
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
                          widget.model?.name ?? "",
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
                            widget.model?.medicalCondition ?? "",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Text(
              "Donation Payment",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: "Enter Amount",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.black, width: 1),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              alignment: Alignment.center,
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(width: 1, color: Colors.black),
              ),
              child: Expanded(
                child: DropdownButton<String>(
                  alignment: Alignment.center,
                  borderRadius: BorderRadius.circular(25),
                  menuWidth: double.infinity,
                  hint: Text('Select a Payment Method'),
                  value: selectedValue,
                  items:
                      items.map((String value) {
                        return DropdownMenuItem(
                          alignment: Alignment.center,
                          value: value,
                          child: Image.network(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Donate as Anonymous",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                Switch(
                  activeColor: Colors.blue,
                  value: anonymous,
                  onChanged: (value) {
                    setState(() {
                      anonymous = value;
                    });
                  },
                ),
              ],
            ),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.black, width: 1),
                ),
                hintText: "Add your Description",
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: _handleDonation,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.blue,
                  ),
                  height: 50,
                  width: 200,
                  child: Text(
                    "Pay",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
