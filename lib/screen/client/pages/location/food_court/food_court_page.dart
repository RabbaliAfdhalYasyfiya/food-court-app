import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';

import '../../../../../services/models/model_product.dart';
import '../../../../../services/models/model.dart';
import '../../../../../widget/button.dart';
import '../../../../../widget/page.dart';
import '../route_page.dart';
import 'review_page.dart';

class FoodCourtPage extends StatefulWidget {
  const FoodCourtPage({
    super.key,
    required this.markerAdmin,
    required this.currentLat,
    required this.currentLng,
  });

  final MarkerAdmin markerAdmin;
  final double currentLat;
  final double currentLng;

  @override
  State<FoodCourtPage> createState() => _FoodCourtPageState();
}

class _FoodCourtPageState extends State<FoodCourtPage> {
  int currentIndex = 0;
  final User currentUser = FirebaseAuth.instance.currentUser!;
  bool isEmpty = false;
  late List<Tab> tabs;

  @override
  void initState() {
    fetchMarkerAdminDataFromFirestore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double rating = widget.markerAdmin.averageRating();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarBrightness: Brightness.dark,
            ),
            expandedHeight: 265,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 1,
            pinned: true,
            stretch: true,
            leadingWidth: 70,
            leading: IconButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
              ),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ElevatedButton.icon(
                  label: const Text(
                    'Route',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    ),
                  ),
                  onLongPress: () {
                    try {
                      var url =
                          "https://www.google.com/maps/dir/?api=1&destination=${widget.markerAdmin.latitude},${widget.markerAdmin.longitude}";
                      final Uri uri = Uri.parse(url);
                      launchUrl(uri);
                    } catch (e) {
                      debugPrint('Error : $e');
                    }
                  },
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => RoutePage(
                          markerAdmin: widget.markerAdmin,
                          currentLat: widget.currentLat,
                          currentLng: widget.currentLng,
                        ),
                      ),
                    );
                    debugPrint('Current Location : ${widget.currentLat}, ${widget.currentLng}');
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
                    elevation: const WidgetStatePropertyAll(0),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    ),
                  ),
                  icon: const Icon(
                    CupertinoIcons.arrow_up_right_diamond_fill,
                    color: Colors.white,
                  ),
                ),
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.blurBackground,
                StretchMode.zoomBackground,
              ],
              collapseMode: CollapseMode.parallax,
              background: CachedNetworkImage(
                imageUrl: widget.markerAdmin.imagePlace,
                filterQuality: FilterQuality.low,
                fit: BoxFit.cover,
                useOldImageOnUrlChange: true,
                fadeInCurve: Curves.easeIn,
                fadeOutCurve: Curves.easeOut,
                fadeInDuration: const Duration(milliseconds: 500),
                fadeOutDuration: const Duration(milliseconds: 750),
                errorWidget: (context, url, error) {
                  return Center(
                    child: Text(
                      'Image $error',
                      style: const TextStyle(
                        color: Colors.redAccent,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Container(
                height: 35,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.markerAdmin.placeName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const Gap(10),
                      Visibility(
                        visible: rating != 0.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onPrimary,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                rating == 0.0 ? '--' : rating.toStringAsPrecision(2),
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              const Gap(2.5),
                              Icon(
                                rating <= 4.0
                                    ? CupertinoIcons.star_lefthalf_fill
                                    : CupertinoIcons.star_fill,
                                color: Colors.amber,
                                size: 17,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Contacted',
                                style: Theme.of(context).textTheme.displayMedium,
                              ),
                              Row(
                                children: [
                                  ButtonIcon(
                                    icon: const Icon(Iconsax.call_calling),
                                    colors: Colors.greenAccent.shade700,
                                    onPress: () async {
                                      debugPrint('Calling');
                                      final url =
                                          Uri(scheme: 'tel', path: widget.markerAdmin.phoneNumber);
                                      if (await canLaunchUrl(url)) {
                                        launchUrl(url);
                                      }
                                    },
                                  ),
                                  const Gap(5),
                                  ButtonIcon(
                                    icon: const Icon(Iconsax.message_text),
                                    colors: Colors.greenAccent.shade700,
                                    onPress: () async {
                                      debugPrint('SMS');
                                      final url =
                                          Uri(scheme: 'sms', path: widget.markerAdmin.phoneNumber);
                                      if (await canLaunchUrl(url)) {
                                        launchUrl(url);
                                      }
                                    },
                                  ),
                                  const Gap(5),
                                  ButtonIcon(
                                    icon: const Icon(Iconsax.sms_tracking),
                                    colors: Theme.of(context).primaryColor,
                                    onPress: () async {
                                      debugPrint('Email');
                                      final url = Uri(
                                          scheme: 'mailto', path: widget.markerAdmin.emailAddress);
                                      if (await canLaunchUrl(url)) {
                                        launchUrl(url);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.5),
                          child: Divider(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            thickness: 1.5,
                            height: 10,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 16),
                          child: Text(
                            widget.markerAdmin.addressPlace,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(10),
                Divider(
                  color: Theme.of(context).dividerColor,
                  thickness: 0.25,
                  height: 10,
                  indent: 30,
                  endIndent: 30,
                ),
                const Gap(10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured Tenant',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).primaryColor.withOpacity(0.1)),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(
                          'See all',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PageTenant(
                  adminId: widget.markerAdmin.adminId,
                ),
                const Gap(10),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reviews',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => ReviewPage(
                                    currentUser: currentUser,
                                    adminId: widget.markerAdmin.adminId,
                                    placeName: widget.markerAdmin.placeName,
                                  ),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                  Theme.of(context).primaryColor.withOpacity(0.1)),
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(5),
                    Container(
                      height: 365,
                      width: double.infinity,
                      color: Theme.of(context).canvasColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: PageReview(
                        currentUser: currentUser,
                        adminId: widget.markerAdmin.adminId,
                        placeName: widget.markerAdmin.placeName,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
