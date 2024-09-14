import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TenantAppbar extends StatelessWidget {
  const TenantAppbar({
    super.key,
    required this.imagePlace,
  });

  final String imagePlace;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
      ),
      expandedHeight: 250,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      pinned: true,
      stretch: true,
      leadingWidth: 70,
      leading: IconButton(
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.white),
        ),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.blurBackground,
          StretchMode.zoomBackground,
        ],
        collapseMode: CollapseMode.pin,
        background: CachedNetworkImage(
          imageUrl: imagePlace,
          filterQuality: FilterQuality.low,
          fit: BoxFit.cover,
          placeholder: (context, url) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey.shade200,
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.grey.shade400,
                  strokeCap: StrokeCap.round,
                ),
              ),
            );
          },
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
          imageBuilder: (context, imageProvider) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
    );
  }
}
