import 'package:edemand_partner/app/generalImports.dart';
import 'package:flutter/material.dart';

class SendWithdrawalRequestBottomsheet extends StatefulWidget {
  const SendWithdrawalRequestBottomsheet({super.key});

  @override
  SendWithdrawalRequestScreenState createState() =>
      SendWithdrawalRequestScreenState();
}

class SendWithdrawalRequestScreenState
    extends State<SendWithdrawalRequestBottomsheet> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController bankDetailsController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  FocusNode bankDetailsFocus = FocusNode();
  FocusNode amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: BottomSheetLayout(
        title: "sendWithdrawalRequest",
        child: withdrawAmountForm(),
      ),
    );
  }

  Widget withdrawAmountForm() {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomContainer(
            color: Theme.of(context).colorScheme.primaryColor,
            padding: const EdgeInsetsDirectional.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFormField(
                  labelText: 'bankDetailsHint'.translate(context: context),
                  controller: bankDetailsController,
                  // currentFocusNode: bankDetailsFocus,
                  // nextFocusNode: amountFocus,
                  currentFocusNode: bankDetailsFocus,
                  nextFocusNode: amountFocus,
                  textInputType: TextInputType.multiline,
                  expands: true,
                  minLines: 4,
                ),
                CustomTextFormField(
                  labelText: 'amountLbl'.translate(context: context),
                  controller: amountController,
                  currentFocusNode: amountFocus,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                  validator: (String? val) {
                    if (val != '') {
                      if (double.parse(val!) >
                          double.parse(
                            (context.read<FetchSystemSettingsCubit>().state
                                    as FetchSystemSettingsSuccess)
                                .availableAmount,
                          )) {
                        return 'bigAmount'.translate(context: context);
                      }
                    }

                    return Validator.nullCheck(context, val);
                  },
                  textInputType: TextInputType.number,
                ),
              ],
            ),
          ),
          resetAndSubmitButton(),
        ],
      ),
    );
  }

  Widget resetAndSubmitButton() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: resetBtn()),
          Expanded(child: submitBtn()),
        ],
      ),
    );
  }

  Widget submitBtn() {
    return BlocConsumer<SendWithdrawalRequestCubit, SendWithdrawalRequestState>(
      listener: (BuildContext context, SendWithdrawalRequestState state) {
        if (state is SendWithdrawalRequestSuccess) {
          //update amount globally
          context.read<FetchSystemSettingsCubit>().updateAmount(state.balance);

          UiUtils.showMessage(
            context,
            'success',
            ToastificationType.success,
            onMessageClosed: () {},
          );

          // little bit delay because bottom sheet is closing very fast
          Future.delayed(
            const Duration(milliseconds: 500),
          ).then((value) => Navigator.pop(context, true));
        }

        if (state is SendWithdrawalRequestFailure) {
          UiUtils.showMessage(
            context,
            'failed',
            ToastificationType.error,
          );
        }
      },
      builder: (BuildContext context, SendWithdrawalRequestState state) {
        Widget? child;

        if (state is SendWithdrawalRequestInProgress) {
          child = CustomCircularProgressIndicator(color: AppColors.whiteColors);
        }

        return CustomInkWellContainer(
          onTap: () {
            UiUtils.removeFocus();
            onSubmitClick();
          },
          child: CustomContainer(
            height: 44,
            boxShadow: const [
              BoxShadow(
                color: Color(0x1c343f53),
                offset: Offset(0, -3),
                blurRadius: 10,
              ),
            ],
            color: Theme.of(context).colorScheme.accentColor,
            child: Center(
              child:
                  child ??
                  Text(
                    'submitBtnLbl'.translate(context: context),
                    style: TextStyle(
                      color: AppColors.whiteColors,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      fontSize: 14.0,
                    ),
                  ),
            ),
          ),
        );
      },
    );
  }

  Widget resetBtn() {
    return CustomInkWellContainer(
      onTap: () {
        bankDetailsController.text = '';
        amountController.text = '';

        FocusScope.of(context).requestFocus(bankDetailsFocus);
        setState(() {});
      },
      child: CustomContainer(
        height: 44,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1c343f53),
            offset: Offset(0, -3),
            blurRadius: 10,
          ),
        ],
        color: Theme.of(context).colorScheme.secondaryColor,
        child: Center(
          child: Text(
            'resetBtnLbl'.translate(context: context),
            style: TextStyle(
              color: Theme.of(context).colorScheme.blackColor,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              fontSize: 14.0,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onSubmitClick() async {
    final FormState? form = formKey.currentState;
    if (form == null) return;
    form.save();
    if (form.validate()) {
      context.read<SendWithdrawalRequestCubit>().sendWithdrawalRequest(
        amount: amountController.text,
        paymentAddress: bankDetailsController.text,
      );
    }
  }
}
