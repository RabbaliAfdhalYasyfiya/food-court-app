import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../widget/button.dart';
import 'profile_page.dart';

class Privacy extends StatelessWidget {
  const Privacy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
          ),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            Navigator.pop(
              context,
              CupertinoPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy & Security',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 22.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(15),
              ButtonPrivacy(
                onTap: () {},
                icon: Iconsax.lock_1,
                label: 'Privacy Key',
                description:
                    'Privacy keys can keep accounts secure and are used as two-step verification.',
              ),
              ButtonPrivacy(
                onTap: () {},
                icon: Iconsax.finger_scan,
                label: 'Biometric Lock',
                description:
                    'Biometric lock can be used as a security option to unlock CourtFinder on your device.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
