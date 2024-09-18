import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

class FieldFormEmail extends StatelessWidget {
  const FieldFormEmail({
    super.key,
    required this.hintText,
    required this.controller,
    required this.inputType,
    required this.focusNode,
    required this.onFieldSubmit,
  });

  final String hintText;
  final TextEditingController controller;
  final TextInputType inputType;
  final FocusNode focusNode;
  final Function(String) onFieldSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: TextFormField(
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmit,
          onChanged: (value) {
            controller.text = value;
          },
          controller: controller,
          inputFormatters: [
            FilteringTextInputFormatter.singleLineFormatter,
          ],
          keyboardType: inputType,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 17,
            letterSpacing: 1,
            fontWeight: FontWeight.w400,
          ),
          selectionControls: EmptyTextSelectionControls(),
          enableInteractiveSelection: true,
          canRequestFocus: true,
          showCursor: false,
          cursorColor: Colors.black,
          obscureText: false,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Icon(
                Iconsax.sms,
                color: Colors.grey.shade500,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                width: 1,
                style: BorderStyle.solid,
                color: Colors.grey.shade400,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                width: 2,
                style: BorderStyle.solid,
                color: Theme.of(context).primaryColor,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
            hintText: hintText,
            hintStyle: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class FieldFormPassword extends StatelessWidget {
  const FieldFormPassword({
    super.key,
    required this.obscure,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    required this.onTap,
  });

  final bool obscure;
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: TextFormField(
          focusNode: focusNode,
          onChanged: (value) {
            controller.text = value;
          },
          controller: controller,
          inputFormatters: [
            FilteringTextInputFormatter.singleLineFormatter,
          ],
          keyboardType: TextInputType.visiblePassword,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 17,
            letterSpacing: 1,
            fontWeight: FontWeight.w400,
          ),
          selectionControls: EmptyTextSelectionControls(),
          enableInteractiveSelection: true,
          canRequestFocus: true,
          showCursor: false,
          cursorColor: Colors.black,
          obscureText: !obscure,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Icon(
                Iconsax.password_check,
                color: Colors.grey.shade500,
              ),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButton(
                onPressed: onTap,
                visualDensity: VisualDensity.comfortable,
                icon: Icon(
                  obscure ? Iconsax.eye : Iconsax.eye_slash,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                width: 1,
                style: BorderStyle.solid,
                color: Colors.grey.shade400,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                width: 1.5,
                style: BorderStyle.solid,
                color: Theme.of(context).primaryColor,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
            hintText: hintText,
            hintStyle: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class FormFields extends StatelessWidget {
  const FormFields({
    super.key,
    required this.prefixIcon,
    required this.inputType,
    required this.controller,
    required this.hintText,
    required this.tap,
    required this.maxLineBoolean,
    required this.textInputFormatter,
    required this.focusNode,
    required this.onFieldSubmit,
  });

  final IconData prefixIcon;
  final TextInputType inputType;
  final TextEditingController controller;
  final String hintText;
  final bool tap;
  final bool maxLineBoolean;
  final TextInputFormatter textInputFormatter;
  final FocusNode focusNode;
  final Function(String) onFieldSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: TextFormField(
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmit,
          maxLines: maxLineBoolean ? 3 : null,
          readOnly: tap,
          onChanged: (value) {
            controller.text = value;
          },
          controller: controller,
          inputFormatters: [
            textInputFormatter,
          ],
          keyboardType: inputType,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 17,
            letterSpacing: 1,
            fontWeight: FontWeight.w400,
          ),
          selectionControls: EmptyTextSelectionControls(),
          enableInteractiveSelection: true,
          canRequestFocus: true,
          showCursor: false,
          cursorColor: Colors.black,
          obscureText: false,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Icon(
                prefixIcon,
                color: Colors.grey.shade500,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                width: 1,
                style: BorderStyle.solid,
                color: Colors.grey.shade400,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                width: 1.5,
                style: BorderStyle.solid,
                color: Theme.of(context).primaryColor,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
            hintText: hintText,
            hintStyle: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class FormFieldPassword extends StatelessWidget {
  const FormFieldPassword({
    super.key,
    required this.prefixIcon,
    required this.inputType,
    required this.controller,
    required this.hintText,
    required this.obscure,
    required this.focusNode,
    required this.onTap,
  });

  final IconData prefixIcon;
  final TextInputType inputType;
  final TextEditingController controller;
  final String hintText;
  final bool obscure;
  final FocusNode focusNode;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: TextFormField(
          focusNode: focusNode,
          onChanged: (value) {
            controller.text = value;
          },
          controller: controller,
          inputFormatters: [
            FilteringTextInputFormatter.singleLineFormatter,
          ],
          keyboardType: inputType,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 17,
            letterSpacing: 1,
            fontWeight: FontWeight.w400,
          ),
          selectionControls: EmptyTextSelectionControls(),
          enableInteractiveSelection: true,
          canRequestFocus: true,
          showCursor: false,
          cursorColor: Colors.black,
          obscureText: !obscure,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Icon(
                prefixIcon,
                color: Colors.grey.shade500,
              ),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButton(
                onPressed: onTap,
                visualDensity: VisualDensity.comfortable,
                icon: Icon(
                  obscure ? Iconsax.eye : Iconsax.eye_slash,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(
                width: 1,
                style: BorderStyle.solid,
                color: Colors.grey.shade400,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(
                width: 1.5,
                style: BorderStyle.solid,
                color: Theme.of(context).primaryColor,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
            hintText: hintText,
            hintStyle: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class FormFieldGenerateCode extends StatelessWidget {
  const FormFieldGenerateCode({
    super.key,
    required this.prefixIcon,
    required this.inputType,
    required this.controller,
    required this.hintText,
    required this.onTapGenerate,
  });

  final IconData prefixIcon;
  final TextInputType inputType;
  final TextEditingController controller;
  final String hintText;
  final Function() onTapGenerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: TextFormField(
          readOnly: true,
          onTap: onTapGenerate,
          onChanged: (value) {
            controller.text = value;
          },
          controller: controller,
          inputFormatters: [
            FilteringTextInputFormatter.singleLineFormatter,
          ],
          keyboardType: inputType,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 17,
            letterSpacing: 1,
            fontWeight: FontWeight.w400,
          ),
          selectionControls: EmptyTextSelectionControls(),
          enableInteractiveSelection: true,
          canRequestFocus: true,
          showCursor: false,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Icon(
                prefixIcon,
                color: Colors.grey.shade500,
              ),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: IconButton(
                onPressed: onTapGenerate,
                style: ButtonStyle(
                  visualDensity: VisualDensity.standard,
                  shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
                ),
                icon: const Icon(
                  Iconsax.refresh5,
                  color: Colors.white,
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(
                width: 1,
                style: BorderStyle.solid,
                color: Colors.grey.shade400,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(
                width: 1.5,
                style: BorderStyle.solid,
                color: Theme.of(context).primaryColor,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
            hintText: hintText,
            hintStyle: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class FormFieldGetLocation extends StatelessWidget {
  const FormFieldGetLocation({
    super.key,
    required this.prefixIcon,
    required this.inputType,
    required this.controller,
    required this.hintText,
    required this.onTapLocation,
  });

  final IconData prefixIcon;
  final TextInputType inputType;
  final TextEditingController controller;
  final String hintText;
  final Function() onTapLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: TextFormField(
          onTap: onTapLocation,
          readOnly: true,
          onChanged: (value) {
            controller.text = value;
          },
          controller: controller,
          inputFormatters: [
            FilteringTextInputFormatter.singleLineFormatter,
          ],
          keyboardType: inputType,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 17,
            letterSpacing: 1,
            fontWeight: FontWeight.w400,
          ),
          selectionControls: EmptyTextSelectionControls(),
          enableInteractiveSelection: true,
          canRequestFocus: true,
          showCursor: false,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Icon(
                prefixIcon,
                color: Colors.grey.shade500,
              ),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: IconButton(
                onPressed: onTapLocation,
                style: ButtonStyle(
                  visualDensity: VisualDensity.standard,
                  shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
                ),
                icon: const Icon(
                  Iconsax.location5,
                  color: Colors.white,
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(
                width: 1,
                style: BorderStyle.solid,
                color: Colors.grey.shade400,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(
                width: 1.5,
                style: BorderStyle.solid,
                color: Theme.of(context).primaryColor,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
            hintText: hintText,
            hintStyle: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
