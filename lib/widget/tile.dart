import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';

import '../screen/client/pages/location/food_court/food_court_page.dart';
import '../services/models/model.dart';
import 'snackbar.dart';

class TileFoodCourt extends StatefulWidget {
  const TileFoodCourt({
    super.key,
    required this.markerAdmin,
    required this.currentLat,
    required this.currentLng,
  });

  final MarkerAdmin markerAdmin;
  final double currentLat;
  final double currentLng;

  @override
  State<TileFoodCourt> createState() => _TileFoodCourtState();
}

class _TileFoodCourtState extends State<TileFoodCourt> {
  @override
  void initState() {
    widget.markerAdmin.isClose;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        if (widget.markerAdmin.isClose) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => FoodCourtPage(
                markerAdmin: widget.markerAdmin,
                currentLat: widget.currentLat,
                currentLng: widget.currentLng,
              ),
            ),
          );
        } else {
          snackBarCustom(
            context,
            Theme.of(context).colorScheme.error,
            'This ${widget.markerAdmin.placeName} is currently Closed',
            Colors.white,
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.all(0),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: 180,
          height: double.infinity,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.75),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: double.infinity,
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
                            Visibility(
                              visible: widget.markerAdmin.averageRating() != 0.0,
                              child: Positioned(
                                bottom: 5,
                                left: 5,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.5, horizontal: 7.5),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.outline,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.markerAdmin.averageRating() == 0.0
                                            ? '--'
                                            : widget.markerAdmin
                                                .averageRating()
                                                .toStringAsPrecision(2),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      const Gap(2),
                                      Icon(
                                        widget.markerAdmin.averageRating() <= 4.0
                                            ? CupertinoIcons.star_lefthalf_fill
                                            : CupertinoIcons.star_fill,
                                        color: Colors.amber,
                                        size: 13,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(2.5),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.markerAdmin.placeName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(5),
              Expanded(
                flex: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.blueAccent.shade400,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.arrow_up_right_diamond_fill,
                            color: Colors.white,
                            size: 15,
                          ),
                          const Gap(3),
                          Text(
                            '${widget.markerAdmin.distance.toStringAsFixed(2)} km',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: widget.markerAdmin.isClose
                            ? Colors.greenAccent.shade400
                            : Colors.redAccent.shade400,
                      ),
                      child: Text(
                        widget.markerAdmin.isClose ? '· Open' : '· Close',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TileTenant extends StatelessWidget {
  const TileTenant({
    super.key,
    required this.nameFoodCourt,
    required this.image,
    required this.isOpen,
    required this.lengthProduct,
    required this.ontap,
  });

  final String nameFoodCourt;
  final String image;
  final bool isOpen;
  final int lengthProduct;
  final Function() ontap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Card(
        margin: const EdgeInsets.all(0),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
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
                      imageUrl: image,
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nameFoodCourt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const Gap(5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$lengthProduct',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                ),
                              ),
                              TextSpan(
                                text: ' Menu',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOpen ? Colors.greenAccent.shade400 : Colors.redAccent,
                            borderRadius: const BorderRadius.all(Radius.circular(25)),
                          ),
                          child: Text(
                            isOpen ? '· Open' : '· Close',
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TileAddressLocation extends StatelessWidget {
  const TileAddressLocation({
    super.key,
    required this.setLoad,
    required this.addressLocation,
    required this.specificAddressLocation,
    required this.coordinate,
  });

  final bool setLoad;
  final String addressLocation;
  final String specificAddressLocation;
  final String coordinate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(
              color: Colors.black12,
              width: 1,
            )),
      ),
      child: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            !setLoad
                ? Text(
                    addressLocation,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        height: 20,
                        width: 125,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const Gap(5),
                    ],
                  ),
            !setLoad
                ? Text(
                    specificAddressLocation,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 15,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const Gap(2.5),
                      Container(
                        height: 15,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
            const Divider(
              thickness: 0.3,
              color: Colors.grey,
            ),
            !setLoad
                ? Text(
                    coordinate,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                      //decorationColor: Colors.blue.shade400,
                    ),
                  )
                : Container(
                    height: 18,
                    width: 175,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class TileMenu extends StatelessWidget {
  const TileMenu({
    super.key,
    required this.image,
    required this.nameMenu,
    required this.price,
    required this.category,
    required this.descMenu,
    required this.ontap,
  });

  final String image;
  final String nameMenu;
  final String price;
  final String category;
  final String descMenu;
  final Function() ontap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Card(
        margin: const EdgeInsets.all(0),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: GestureDetector(
          onTap: ontap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.25),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
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
                          imageUrl: image,
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
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nameMenu,
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const Gap(10),
                        Text(
                          'Rp $price',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const Gap(5),
                        Text(
                          category,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Gap(2.5),
                        Visibility(
                          visible: descMenu.isNotEmpty,
                          child: Text(
                            descMenu,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TileReview extends StatelessWidget {
  const TileReview({
    super.key,
    required this.imageUser,
    required this.nameUser,
    required this.komenUser,
    required this.userId,
    required this.currentUserId,
    required this.ratingUser,
    required this.imageReview,
    required this.delete,
  });

  final String imageUser;
  final String nameUser;
  final String komenUser;
  final String userId;
  final String currentUserId;
  final double ratingUser;
  final String imageReview;
  final Function() delete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 350,
        height: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black12, width: 0.75),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundImage: NetworkImage(imageUser),
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              nameUser,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  ratingUser.toString(),
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const Gap(5),
                                RatingBar(
                                  initialRating: ratingUser,
                                  itemCount: 5,
                                  direction: Axis.horizontal,
                                  glow: false,
                                  itemSize: 15,
                                  ignoreGestures: true,
                                  allowHalfRating: true,
                                  maxRating: 5,
                                  minRating: 0,
                                  ratingWidget: RatingWidget(
                                    full: const Icon(
                                      CupertinoIcons.star_fill,
                                      color: Colors.amber,
                                    ),
                                    half: const Icon(
                                      CupertinoIcons.star_lefthalf_fill,
                                      color: Colors.amber,
                                    ),
                                    empty: const Icon(
                                      CupertinoIcons.star_fill,
                                      color: Colors.black38,
                                    ),
                                  ),
                                  onRatingUpdate: (rate) {},
                                ),
                              ],
                            ),
                          ],
                        ),
                        PopupMenuButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(width: 0.5, color: Theme.of(context).dividerColor),
                          ),
                          useRootNavigator: true,
                          popUpAnimationStyle: AnimationStyle(
                              curve: Curves.easeInSine,
                              duration: const Duration(milliseconds: 250)),
                          enabled: true,
                          elevation: 2,
                          iconColor: Theme.of(context).dividerColor,
                          iconSize: 20,
                          position: PopupMenuPosition.under,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          itemBuilder: (context) => [
                            if (userId == currentUserId) ...[
                              PopupMenuItem(
                                onTap: () {},
                                enabled: userId == currentUserId,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Iconsax.edit,
                                      size: 20,
                                    ),
                                    const Gap(10),
                                    Text(
                                      'Edit',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                onTap: delete,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Iconsax.trash,
                                      size: 20,
                                    ),
                                    const Gap(10),
                                    Text(
                                      'Delete',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              PopupMenuItem(
                                onTap: () {},
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Iconsax.flag,
                                      size: 20,
                                    ),
                                    const Gap(10),
                                    Text(
                                      'Report',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              )
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 0.75,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
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
                          imageUrl: imageReview,
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
                    ),
                  ),
                  const Gap(7),
                  Expanded(
                    flex: 1,
                    child: Text(
                      komenUser,
                      maxLines: 7,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.justify,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TileFavorite extends StatelessWidget {
  const TileFavorite({
    super.key,
    required this.imageProduct,
    required this.nameProduct,
    required this.priceProduct,
    required this.categoryProduct,
    required this.descProduct,
    required this.delete,
  });

  final String imageProduct;
  final String nameProduct;
  final String priceProduct;
  final String categoryProduct;
  final String descProduct;
  final Function() delete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.25),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
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
                          imageUrl: imageProduct,
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
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        nameProduct,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const Gap(10),
                      Text(
                        'Rp $priceProduct',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const Gap(5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryProduct,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            descProduct,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: IconButton.filled(
              onPressed: delete,
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.redAccent.shade400),
                shape: const WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                      topRight: Radius.circular(5),
                      bottomLeft: Radius.circular(5),
                    ),
                  ),
                ),
              ),
              icon: const Icon(
                Iconsax.trash,
                color: Colors.white,
              ),
              iconSize: 20,
            ),
          )
        ],
      ),
    );
  }
}

class TileTenantManager extends StatelessWidget {
  const TileTenantManager({
    super.key,
    required this.imageTenant,
    required this.nameTenant,
    required this.emailTenant,
    required this.phoneNumberTenant,
    required this.numberProduct,
    required this.isOpen,
    required this.onTap,
  });

  final String imageTenant;
  final String nameTenant;
  final String emailTenant;
  final String phoneNumberTenant;
  final int numberProduct;
  final bool isOpen;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(width: 0.75, color: Colors.black38),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.grey.shade200,
                          Colors.grey.shade100,
                          Colors.grey.shade50,
                        ],
                      ),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imageTenant,
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            nameTenant,
                            textAlign: TextAlign.start,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                              height: 1,
                            ),
                          ),
                        ),
                        const Gap(10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOpen ? Colors.greenAccent.shade400 : Colors.redAccent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            isOpen ? '· Open' : '· Close',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.sms,
                          color: Theme.of(context).primaryColor,
                          size: 17,
                        ),
                        const Gap(5),
                        Text(
                          emailTenant,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TileOrderProduct extends StatelessWidget {
  const TileOrderProduct({
    super.key,
    required this.index,
    required this.count,
    required this.imageProduct,
    required this.nameProduct,
    required this.priceProduct,
    required this.checkProduct,
    required this.tapped,
    required this.onChanged,
    required this.onDecCount,
    required this.onIncCount,
  });

  final int index;
  final int count;
  final String imageProduct;
  final String nameProduct;
  final String priceProduct;
  final bool checkProduct;
  final Function() tapped;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDecCount;
  final VoidCallback onIncCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12, width: 1),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: GestureDetector(
                    onTap: tapped,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.grey.shade200,
                                Colors.grey.shade100,
                                Colors.grey.shade50,
                              ],
                            ),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: imageProduct,
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
                      ),
                    ),
                  ),
                ),
                const Gap(10),
                Column(
                  children: [
                    Text(
                      nameProduct,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 19,
                        height: 1,
                      ),
                    ),
                    const Gap(5),
                    Text(
                      'Rp $priceProduct',
                      style: const TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    Divider(
                      thickness: 0.5,
                      height: 10,
                      endIndent: 10,
                      indent: 10,
                      color: Theme.of(context).dividerColor,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: onDecCount,
                          icon: const Icon(CupertinoIcons.minus),
                          color: Colors.white,
                          style: ButtonStyle(
                            shape: const WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                ),
                              ),
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.shade200,
                            ),
                            child: Center(
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onIncCount,
                          icon: const Icon(CupertinoIcons.add),
                          color: Colors.white,
                          style: ButtonStyle(
                            shape: const WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(15),
                                  topLeft: Radius.circular(10),
                                ),
                              ),
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 1,
            left: 1,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              ),
              child: Checkbox.adaptive(
                value: checkProduct,
                visualDensity: VisualDensity.compact,
                activeColor: Theme.of(context).primaryColor,
                side: const BorderSide(color: Colors.black, width: 1.5),
                autofocus: true,
                splashRadius: 50,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
