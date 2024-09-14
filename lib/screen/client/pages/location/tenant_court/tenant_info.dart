import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';

import '../../../../../services/models/model_product.dart';
import '../../../../../services/models/model_tenant.dart';
import '../../../../../widget/button.dart';
import 'tenant_menu.dart';

class TenantInfo extends StatelessWidget {
  const TenantInfo({
    super.key,
    required this.products,
    required this.tenant,
    required this.currentUser,
  });

  final List<MenuProduct> products;
  final Tenant tenant;
  final User currentUser;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Text(
            tenant.vendorName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              height: 1.05,
            ),
          ),
        ),
        const Gap(10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Contacted',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    ButtonIcon(
                      icon: const Icon(Iconsax.call_calling),
                      colors: Colors.greenAccent.shade700,
                      onPress: () async {
                        debugPrint('Calling');
                        final url = Uri(scheme: 'tel', path: tenant.phoneNumberVendor);
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
                        final url = Uri(scheme: 'sms', path: tenant.phoneNumberVendor);
                        if (await canLaunchUrl(url)) {
                          launchUrl(url);
                        }
                      },
                    ),
                    const Gap(5),
                    ButtonIcon(
                      icon: const Icon(Iconsax.sms_tracking),
                      colors: Colors.black38,
                      onPress: () async {
                        debugPrint('Email');
                        final url = Uri(scheme: 'mailto', path: tenant.emailVendor);
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
        ),
        const Gap(10),
        const Divider(
          color: Colors.black26,
          thickness: 0.25,
          height: 10,
          indent: 30,
          endIndent: 30,
        ),
        Visibility(
          visible: products.isNotEmpty,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Menu Items',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => TenantMenu(
                          products: products,
                          tenant: tenant,
                          currentUser: currentUser,
                        ),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(Theme.of(context).primaryColor.withOpacity(0.1)),
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
        ),
      ],
    );
  }
}
