import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

import '../../welcome_page.dart';

class PinPutClient extends StatefulWidget {
  const PinPutClient({super.key});

  @override
  State<PinPutClient> createState() => _PinPutClientState();
}

class _PinPutClientState extends State<PinPutClient> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
          ),
          icon: Icon(
            CupertinoIcons.multiply,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            SystemNavigator.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Text(
                    'Privacy Lock',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(5),
                  const Text(
                    'Enter Your Account Privacy Lock to open CourtFinder',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Gap(35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 20,
                          height: 20,
                          padding: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(
                              width: index < enteredPin.length ? 2 : 1,
                              color: index < enteredPin.length
                                  ? Colors.blueAccent.shade400
                                  : Colors.black45,
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index < enteredPin.length
                                  ? Colors.blueAccent.shade400
                                  : Colors.transparent,
                            ),
                            // child: index < enteredPin.length
                            //     ? Center(
                            //         child: Text(
                            //           enteredPin[index],
                            //           style: const TextStyle(
                            //             fontSize: 17,
                            //             color: Colors.blue,
                            //             fontWeight: FontWeight.w700,
                            //           ),
                            //         ),
                            //       )
                            //     : null,
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => numButton(1 + 3 * i + index),
                        ).toList(),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        iconButton(
                          const Icon(
                            Icons.fingerprint_rounded,
                            size: 35,
                          ),
                          () {},
                        ),
                        numButton(0),
                        iconButton(
                          const Icon(
                            CupertinoIcons.delete_left_fill,
                            size: 35,
                            color: Colors.black45,
                          ),
                          () {
                            setState(() {
                              if (enteredPin.isNotEmpty) {
                                enteredPin = enteredPin.substring(0, enteredPin.length - 1);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const Gap(25),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String enteredPin = '';
  bool isPinVisible = false;

  Widget iconButton(Icon icon, Function() tapped) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: TextButton(
        onPressed: tapped,
        child: icon,
      ),
    );
  }

  Widget numButton(int number) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: TextButton(
        onPressed: () {
          setState(() {
            if (enteredPin.length < 4) {
              enteredPin += number.toString();
              if (enteredPin.length == 4) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WelcomePage(),
                  ),
                );
              }
            }
          });
        },
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.black12),
          visualDensity: VisualDensity.standard,
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 20, horizontal: 30)),
        ),
        child: SizedBox(
          width: 17,
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 27,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
