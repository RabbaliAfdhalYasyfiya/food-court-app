extension ExtensionString on String {
  bool get isEmailValid {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]");
    return emailRegExp.hasMatch(this);
  }

  bool get isPassValid {
    final passRegExp = RegExp(r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$");
    return passRegExp.hasMatch(this);
  }

  bool get isPhoneValid {
    final phoneRegExp = RegExp(r"^\+?0[0-9]{10}$");
    return phoneRegExp.hasMatch(this);
  }
}
