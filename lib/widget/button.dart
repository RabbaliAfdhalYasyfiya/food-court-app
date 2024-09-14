import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ButtonWithIcon extends StatelessWidget {
  const ButtonWithIcon({
    super.key,
    required this.text,
    required this.icon,
    required this.ontap,
  });

  final String text;
  final Icon icon;
  final Function() ontap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: ontap,
      iconAlignment: IconAlignment.end,
      icon: icon,
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      style: ButtonStyle(
        elevation: const WidgetStatePropertyAll(3),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 15, vertical: 12.5)),
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context).primaryColor,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}

class ButtonDelete extends StatelessWidget {
  const ButtonDelete({
    super.key,
    required this.text,
    required this.color,
    required this.borderColor,
    required this.textColor,
    required this.smallText,
    required this.onTap,
  });

  final String text;
  final Color color;
  final Color borderColor;
  final Color textColor;
  final bool smallText;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ButtonStyle(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(color),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 15),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              width: 0.75,
              color: borderColor,
            ),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: smallText ? 15 : 18,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ButtonClose extends StatelessWidget {
  const ButtonClose({
    super.key,
    required this.text,
    required this.onTap,
  });

  final String text;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ButtonStyle(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context).primaryColor.withOpacity(0.15),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 15),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              width: 1,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ButtonAccount extends StatelessWidget {
  const ButtonAccount({
    super.key,
    required this.icon,
    required this.colorIcon,
    required this.colorButton,
    required this.label,
    required this.color,
    required this.widget,
    required this.onTap,
  });

  final IconData icon;
  final Color colorIcon;
  final Color colorButton;
  final String label;
  final Color color;
  final Widget widget;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        splashColor: Theme.of(context).primaryColor.withOpacity(0.25),
        onTap: onTap,
        visualDensity: VisualDensity.comfortable,
        leading: Icon(
          icon,
          color: colorIcon,
        ),
        minLeadingWidth: 5,
        title: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: widget,
        tileColor: colorButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.25), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 2.5,
        ),
        style: ListTileStyle.list,
      ),
    );
  }
}

class ButtonIcon extends StatelessWidget {
  const ButtonIcon({
    super.key,
    required this.icon,
    required this.colors,
    required this.onPress,
  });

  final Icon icon;
  final Color colors;
  final Function() onPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onPress,
          icon: icon,
          splashRadius: 50,
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(colors),
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const WidgetStatePropertyAll(EdgeInsets.all(15)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          color: Colors.white,
          iconSize: 20,
        ),
      ],
    );
  }
}

class ButtonPrivacy extends StatelessWidget {
  const ButtonPrivacy({
    super.key,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.description,
  });

  final Function() onTap;
  final IconData icon;
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          ListTile(
            tileColor: Colors.grey.shade50,
            splashColor: Theme.of(context).primaryColor.withOpacity(0.25),
            onTap: onTap,
            visualDensity: VisualDensity.comfortable,
            leading: Icon(
              icon,
              color: Theme.of(context).primaryColor,
            ),
            minLeadingWidth: 5,
            title: Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            titleAlignment: ListTileTitleAlignment.center,
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Not Active',
                  style: TextStyle(
                    color: Colors.black45,
                    //color: Theme.of(context).primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: Colors.black,
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.black.withOpacity(0.25), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 1,
            ),
            style: ListTileStyle.list,
          ),
          const Gap(5),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
