import 'package:flutter/material.dart';

import '../../../../app/generalImports.dart';

class VerifyOTPDialog extends StatefulWidget {
  final String otp;
  final Function confirmButtonPressed;

  VerifyOTPDialog({
    super.key,
    required this.otp,
    required this.confirmButtonPressed,
  });

  @override
  State<VerifyOTPDialog> createState() => _VerifyOTPDialogState();
}

class _VerifyOTPDialogState extends State<VerifyOTPDialog> {
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> otpFormKey = GlobalKey();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialogLayout(
      title: "otp",
      description: "pleaseEnterOTPGivenByCustomer",
      confirmButtonName: "verify",
      cancelButtonName: "cancel",
      confirmButtonBackgroundColor: Theme.of(context).colorScheme.accentColor,
      cancelButtonBackgroundColor: Theme.of(context).colorScheme.secondaryColor,
      widgetUnderDescription: Form(
        key: otpFormKey,
        child: CustomTextFormField(
          bottomPadding: 0,
          textInputType: TextInputType.number,
          controller: _otpController,
          isDense: true,
          forceUnFocus: false,
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'pleaseEnterOTP'.translate(context: context);
            } else if (value.trim() != widget.otp || value.trim() == '0') {
              return 'invalidOTP'.translate(context: context);
            }
            return null;
          },
          hintText: "enterOTP".translate(context: context),
          hintTextColor: Theme.of(context).colorScheme.lightGreyColor,
        ),
      ),
      showProgressIndicator: false,
      cancelButtonPressed: () {
        Navigator.pop(context);
      },
      confirmButtonPressed: () {
        final FormState? form = otpFormKey.currentState;
        if (form == null) return;
        form.save();
        if (form.validate()) {
          Navigator.pop(context, _otpController.text);
          widget.confirmButtonPressed.call();
        }
      },
    );
  }
}
