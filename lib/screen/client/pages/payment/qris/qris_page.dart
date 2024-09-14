import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../payment_page.dart';

class QRISPage extends StatefulWidget {
  const QRISPage({super.key});

  @override
  State<QRISPage> createState() => _QRISPageState();
}

class _QRISPageState extends State<QRISPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black,
        leading: IconButton(
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
          ),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            Navigator.pop(
              context,
              CupertinoPageRoute(
                builder: (context) => const PaymentPage(),
              ),
            );
          },
        ),
        title: const Text(
          'QRIS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  'Arahkan kamera ke kode QRIS untuk melakukan Pembayaran',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Stack(
                children: [
                  SizedBox(
                    height: 300,
                    width: 300,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          height: 275,
                          width: 275,
                          color: Colors.black,
                          child: Image.asset(
                            'assets/images/qr.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(25)),
                        border: Border.merge(
                          Border(
                              left: BorderSide(
                            width: 6,
                            color: Theme.of(context).primaryColor,
                          )),
                          Border(
                              bottom: BorderSide(
                            width: 6,
                            color: Theme.of(context).primaryColor,
                          )),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25)),
                        border: Border.merge(
                          Border(
                              left: BorderSide(
                            width: 6,
                            color: Theme.of(context).primaryColor,
                          )),
                          Border(
                              top: BorderSide(
                            width: 6,
                            color: Theme.of(context).primaryColor,
                          )),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(25)),
                        border: Border.merge(
                          Border(
                              right: BorderSide(
                            width: 6,
                            color: Theme.of(context).primaryColor,
                          )),
                          Border(
                              top: BorderSide(
                            width: 6,
                            color: Theme.of(context).primaryColor,
                          )),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(25)),
                        border: Border.merge(
                          Border(
                              right: BorderSide(
                            width: 6,
                            color: Theme.of(context).primaryColor,
                          )),
                          Border(
                              bottom: BorderSide(
                            width: 6,
                            color: Theme.of(context).primaryColor,
                          )),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Image.asset(
                'assets/images/logo/QRIS.png',
                color: Colors.black,
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton.filled(
                    icon: const Icon(CupertinoIcons.bolt),
                    selectedIcon: const Icon(CupertinoIcons.bolt_fill),
                    iconSize: 30,
                    padding: const EdgeInsets.all(10),
                    color: Colors.white,
                    onPressed: () {
                      debugPrint('Clik Bolt');
                    },
                  ),
                  IconButton.filled(
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    iconSize: 30,
                    padding: const EdgeInsets.all(10),
                    color: Colors.white,
                    onPressed: () {
                      debugPrint('Clik add Photo');
                    },
                  ),
                  // IconButton.filled(
                  //   icon: const Icon(CupertinoIcons.money_dollar_circle),
                  //   iconSize: 30,
                  //   padding: const EdgeInsets.all(10),
                  //   color: Colors.white,
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       CupertinoPageRoute(
                  //         builder: (context) => const PriceAmount(),
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
