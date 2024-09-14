import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'qris/qris_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('clients').doc(currentUser.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.all(0),
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              Positioned(
                                top: -50,
                                left: -20,
                                child: Container(
                                  height: 200,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.blueAccent.shade100,
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -30,
                                right: -25,
                                child: Container(
                                  height: 130,
                                  width: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blueAccent.shade200,
                                    border: Border.all(
                                      color: Colors.blueAccent.shade100,
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -200,
                                left: 0,
                                right: 10,
                                child: Container(
                                  height: 300,
                                  width: 300,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blueAccent.shade200.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -20,
                                right: -15,
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blueAccent.shade100.withOpacity(0.25),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -60,
                                left: 75,
                                child: Container(
                                  height: 100,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blueAccent.shade100.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -75,
                                left: -15,
                                child: Container(
                                  height: 150,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blueAccent.shade200,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.account_balance_wallet,
                                              color: Colors.white,
                                            ),
                                            Gap(5),
                                            Text(
                                              'Balance',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(25),
                                          child: Image.network(
                                            userData['image'],
                                            height: 37,
                                            width: 37,
                                            fit: BoxFit.cover,
                                            filterQuality: FilterQuality.low,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Rp',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                height: 1,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Gap(5),
                                            Text(
                                              '125.000',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 35,
                                                height: 1,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Gap(5),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        buttonPayMethod(
                          CupertinoIcons.rectangle_stack_badge_plus,
                          'Top Up',
                          () {},
                        ),
                        const Gap(10),
                        buttonPayMethod(
                          CupertinoIcons.qrcode,
                          'QRIS',
                          () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => const QRISPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Gap(15),
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaction History',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blueAccent,
              ),
            );
          },
        ),
      ),
    );
  }

  DropdownMenuItem<String> dropMenuItem(
    String value,
    String image,
    String label,
    Function() onTap,
  ) {
    return DropdownMenuItem(
      onTap: onTap,
      value: value,
      alignment: Alignment.center,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: Image.asset(
              image,
              filterQuality: FilterQuality.low,
              fit: BoxFit.fitWidth,
            ),
          ),
          const Gap(10),
          Text(label),
        ],
      ),
    );
  }

  Widget buttonPayMethod(
    final IconData icon,
    final String label,
    final Function() onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ButtonStyle(
        fixedSize: const WidgetStatePropertyAll(Size.fromWidth(100)),
        elevation: const WidgetStatePropertyAll(1),
        backgroundColor: const WidgetStatePropertyAll(Colors.white),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 15, horizontal: 15)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 30,
          ),
          const Gap(15),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
