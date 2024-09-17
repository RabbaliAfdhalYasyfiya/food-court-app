import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';

import '../../../../services/models/model_product.dart';
import '../../../../services/models/model_tenant.dart';
import '../../../../widget/snackbar.dart';
import '../../main_page.dart';

class OrderSuccess extends StatefulWidget {
  const OrderSuccess({
    super.key,
    required this.orderedProducts,
    required this.priceTotal,
    required this.payMethod,
    required this.taxFee,
    required this.vendorId,
    required this.orderTime,
    required this.initialIndex,
  });

  final Timestamp orderTime;
  final List<Product> orderedProducts;
  final String payMethod;
  final double priceTotal;
  final double taxFee;
  final String vendorId;
  final int initialIndex;

  @override
  State<OrderSuccess> createState() => _OrderSuccessState();
}

class _OrderSuccessState extends State<OrderSuccess> {
  List<BluetoothDevice> devices = [];
  BlueThermalPrinter printer = BlueThermalPrinter.instance;
  BluetoothDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    getPrinter();
  }

  void getPrinter() async {
    devices = await printer.getBondedDevices();

    setState(() {
      printer.isConnected;
    });
  }

  void orderPrint(
    String nameVendor,
    String emailVendor,
    String phoneVendor,
  ) {
    showModalBottomSheet(
      context: context,
      scrollControlDisabledMaxHeightRatio: 1 / 1.75,
      isScrollControlled: false,
      enableDrag: false,
      useRootNavigator: false,
      showDragHandle: false,
      useSafeArea: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        style: const ButtonStyle(
                          shadowColor: WidgetStatePropertyAll(Colors.black),
                          elevation: WidgetStatePropertyAll(1),
                          backgroundColor: WidgetStatePropertyAll(Colors.white),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          CupertinoIcons.xmark,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Icon(
                              Icons.drag_handle_rounded,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const Gap(15),
                          const Text(
                            'Select Device Printer',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                            ),
                          ),
                          const Divider(
                            thickness: 0.25,
                            color: Colors.black38,
                            endIndent: 15,
                            indent: 15,
                          ),
                          Expanded(
                            child: devices.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No Device Printer',
                                      style: TextStyle(
                                        color: Colors.black45,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 15,
                                      ),
                                    ),
                                  )
                                : ListView(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    children: devices.map(
                                      (e) {
                                        return ListTile(
                                          visualDensity: VisualDensity.comfortable,
                                          contentPadding:
                                              const EdgeInsets.symmetric(horizontal: 10),
                                          leading: const Icon(
                                            CupertinoIcons.printer,
                                            color: Colors.black45,
                                          ),
                                          title: Text(
                                            e.name!,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 17,
                                            ),
                                          ),
                                          subtitle: Text(
                                            e.address!,
                                            style: const TextStyle(
                                              color: Colors.black38,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 13,
                                            ),
                                          ),
                                          selected: selectedDevice == e,
                                          trailing: TextButton(
                                            onPressed: () async {
                                              setModalState(() {
                                                selectedDevice = e;
                                              });

                                              if (await printer.isConnected == true) {
                                                printDocument(nameVendor, emailVendor, phoneVendor);
                                                //printer.disconnect();
                                                snackBarCustom(
                                                  context,
                                                  Colors.greenAccent.shade400,
                                                  'Enter, Print Successfully',
                                                  Colors.white,
                                                );
                                              } else {
                                                if (await printer.isAvailable == true) {
                                                  await printer.connect(selectedDevice!);

                                                  snackBarCustom(
                                                    context,
                                                    Theme.of(context).primaryColor,
                                                    'Connected to Printer ${e.name}',
                                                    Colors.white,
                                                  );
                                                }
                                              }
                                              setModalState(() {});
                                            },
                                            style: ButtonStyle(
                                              visualDensity: VisualDensity.comfortable,
                                              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(50))),
                                              backgroundColor: WidgetStatePropertyAll(
                                                selectedDevice == e
                                                    ? Theme.of(context).primaryColor
                                                    : Colors.greenAccent.shade400,
                                              ),
                                            ),
                                            child: Text(
                                              selectedDevice == e ? 'Print' : 'Connect',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void printDocument(String name, String email, String phone) {
    const int maxLineLength = 9;

    List<String> splitStringToTwoLines(String str, int length) {
      if (str.length <= length) {
        return [str, ''];
      } else {
        String firstLine = '${str.substring(0, length)}-';
        String secondLine = '${str.substring(length)}...';
        return [firstLine, secondLine];
      }
    }

    printer.paperCut();
    printer.printNewLine();
    printer.printNewLine();
    printer.printCustom(name, 2, 1);
    printer.printNewLine();
    printer.printCustom(email, 1, 1);
    printer.printCustom(phone, 1, 1);
    printer.printNewLine();
    printer.printNewLine();

    printer.printLeftRight(
        'Date Due:', DateFormat('dd MMM yyyy').format(widget.orderTime.toDate()), 0);
    printer.printLeftRight('Pay Method:', widget.payMethod, 0);
    printer.printNewLine();
    printer.print3Column('Product', 'Qty', 'Price', 1);
    for (var i = 0; i < widget.orderedProducts.length; i++) {
      final product = widget.orderedProducts[i];
      // String truncateString(String str, int length) {
      //   return (str.length <= length) ? str : '${str.substring(0, length)}...';
      // }
      // truncateString(product['name_product'], maxLineLength);

      // Memotong name_product jika terlalu panjang
      List<String> nameProductLines = splitStringToTwoLines(product.nameProduct, maxLineLength);
      printer.print3Column(nameProductLines[0], '${product.quantityProduct}x',
          product.valueTotal.toStringAsFixed(3), 0);
      if (nameProductLines[1].isNotEmpty) {
        String secondLine = nameProductLines[1].trim();
        printer.printCustom(secondLine, 0, 0);
      }
    }
    printer.printNewLine();
    printer.printLeftRight('Tax Fee', 'Rp ${widget.taxFee.toStringAsFixed(3)}', 1);
    printer.printNewLine();
    printer.printLeftRight('Total', 'Rp ${widget.priceTotal.toStringAsFixed(3)}', 3);
    printer.printNewLine();
    printer.printNewLine();

    printer.printCustom('*** Terima Kasih! ***', 1, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.printNewLine();
    printer.paperCut();
  }

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('vendors').doc(widget.vendorId).snapshots(),
        builder: (context, snapshot) {
          debugPrint(widget.vendorId);
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Nodata-pana.png',
                    width: 200,
                  ),
                  const Gap(20),
                  const Text(
                    'Here, no Orders have arrived yet',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            debugPrint('${snapshot.error}');
            return Center(
              child: Text('An error occurred: ${snapshot.error}'),
            );
          }

          final vendor = Tenant.fromDocument(snapshot.data!);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        children: [
                          Container(
                            height: 140,
                            width: 140,
                            color: Colors.transparent,
                            child: LottieBuilder.asset(
                              'assets/success_animation.json',
                              filterQuality: FilterQuality.low,
                              alignment: Alignment.center,
                              repeat: true,
                              animate: true,
                              backgroundLoading: false,
                            ),
                          ),
                          Text(
                            'The order has been successfully!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(25),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          end: Alignment.topCenter,
                          begin: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).colorScheme.onSecondary,
                            Theme.of(context).colorScheme.onTertiary,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // List Menu
                          Expanded(
                            child: ScrollbarTheme(
                              data: const ScrollbarThemeData(
                                crossAxisMargin: 0,
                                trackVisibility: WidgetStatePropertyAll(false),
                                thumbVisibility: WidgetStatePropertyAll(true),
                                interactive: true,
                                minThumbLength: 5,
                                radius: Radius.circular(50),
                                thickness: WidgetStatePropertyAll(5),
                                mainAxisMargin: 50,
                                thumbColor: WidgetStatePropertyAll(Colors.black26),
                              ),
                              child: Scrollbar(
                                controller: scrollController,
                                child: ListView.builder(
                                  controller: scrollController,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: widget.orderedProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = widget.orderedProducts[index];

                                    return ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                      titleAlignment: ListTileTitleAlignment.center,
                                      visualDensity: VisualDensity.comfortable,
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Theme.of(context).colorScheme.onPrimary,
                                                Theme.of(context).colorScheme.onSecondary,
                                                Theme.of(context).colorScheme.onTertiary,
                                              ],
                                            ),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: product.imageProduct,
                                            filterQuality: FilterQuality.low,
                                            fit: BoxFit.cover,
                                            useOldImageOnUrlChange: true,
                                            fadeInCurve: Curves.easeIn,
                                            fadeOutCurve: Curves.easeOut,
                                            fadeInDuration: const Duration(milliseconds: 500),
                                            fadeOutDuration: const Duration(milliseconds: 750),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        product.nameProduct,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          height: 1,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${product.quantityProduct}x',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      trailing: Text(
                                        'Rp ${NumberFormat('#,##0.000', 'id_ID').format(product.valueTotal).replaceAll(',', '.')}',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 15,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const Gap(10),
                          // Detail Order
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.035),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Date & Time',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.tertiary,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Gap(5),
                                        Text(
                                          DateFormat('dd/MM/yy hh:mm')
                                              .format(widget.orderTime.toDate()),
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    thickness: 1.5,
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Payment Method',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.tertiary,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Gap(5),
                                        Text(
                                          widget.payMethod.toString(),
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    thickness: 1.5,
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Tax Fee',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.tertiary,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'Rp ${NumberFormat('#,##0.000', 'id_ID').format(widget.taxFee).replaceAll(',', '.')}',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    thickness: 1.5,
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.tertiary,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'Rp ${NumberFormat('#,##0.000', 'id_ID').format(widget.priceTotal).replaceAll(',', '.')}',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          iconAlignment: IconAlignment.start,
                          icon: const Icon(
                            CupertinoIcons.printer,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Print',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () {
                            orderPrint(
                              vendor.vendorName,
                              vendor.emailVendor,
                              vendor.phoneNumberVendor,
                            );

                            setState(() {
                              getPrinter();
                            });
                          },
                          style: ButtonStyle(
                            fixedSize:
                                const WidgetStatePropertyAll(Size.fromWidth(double.maxFinite)),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            elevation: const WidgetStatePropertyAll(3),
                            side: WidgetStatePropertyAll(
                              BorderSide(
                                width: 2,
                                color: Colors.greenAccent.shade400.withOpacity(0.25),
                              ),
                            ),
                            backgroundColor: WidgetStatePropertyAll(Colors.greenAccent.shade700),
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.symmetric(vertical: 20),
                            ),
                          ),
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainPageTenant(
                                  initialIndex: widget.initialIndex,
                                ),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            fixedSize:
                                const WidgetStatePropertyAll(Size.fromWidth(double.maxFinite)),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            elevation: const WidgetStatePropertyAll(3),
                            backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.symmetric(vertical: 20),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
