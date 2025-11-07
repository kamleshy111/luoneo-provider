import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class SendOTPScreen extends StatefulWidget {
  const SendOTPScreen({
    super.key,
    required this.screenTitle,
    required this.screenSubTitle,
  });

  final String screenTitle;
  final String screenSubTitle;

  @override
  State<SendOTPScreen> createState() => _SendOTPScreenState();

  static Route route(RouteSettings routeSettings) {
    final Map<String, dynamic> arguments =
        routeSettings.arguments as Map<String, dynamic>;

    return CupertinoPageRoute(
      builder: (_) {
        return SendOTPScreen(
          screenTitle: arguments['screenTitle'],
          screenSubTitle: arguments['screenSubTitle'],
        );
      },
    );
  }
}

class _SendOTPScreenState extends State<SendOTPScreen> {
  String phoneNumberWithCountryCode = '';
  String phoneNumberWithoutCountryCode = '';
  String countryCode = '';

  final GlobalKey<FormState> verifyPhoneNumberFormKey = GlobalKey<FormState>();
  final TextEditingController _numberFieldController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _numberFieldController.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void _onContinueButtonClicked() {
    UiUtils.removeFocus();

    final bool isvalidNumber = verifyPhoneNumberFormKey.currentState!
        .validate();

    if (isvalidNumber) {
      final String countryCallingCode = context
          .read<CountryCodeCubit>()
          .getSelectedCountryCode();

      phoneNumberWithCountryCode =
          countryCallingCode + _numberFieldController.text;
      phoneNumberWithoutCountryCode = _numberFieldController.text;
      countryCode = countryCallingCode;

      context.read<VerifyPhoneNumberFromAPICubit>().verifyPhoneNumberFromAPI(
        mobileNumber: phoneNumberWithoutCountryCode,
        countryCode: countryCode,
      );
    }
  }

  Padding _buildPhoneNumberFiled() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 10.0, bottom: 25),
      child: CustomTextFormField(
        bottomPadding: 0,
        controller: _numberFieldController,
        isDense: false,
        // isRoundedBorder: true,
        fillColor: Colors.transparent,
        textInputType: TextInputType.phone,
        hintText: 'enterMobileNumber'.translate(context: context),
        hintTextColor: Theme.of(context).colorScheme.lightGreyColor,
        textInputAction: TextInputAction.done,
        prefix: Padding(
          padding: const EdgeInsetsDirectional.only(start: 12.0, bottom: 2),
          child: BlocBuilder<CountryCodeCubit, CountryCodeState>(
            builder: (BuildContext context, CountryCodeState state) {
              String code = '--';

              if (state is CountryCodeFetchSuccess) {
                code = state.selectedCountry!.callingCode;
              }

              return IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomInkWellContainer(
                      onTap: () {
                        if (allowOnlySingleCountry ||
                            (state is CountryCodeFetchSuccess &&
                                state.temporaryCountryList != null &&
                                state.temporaryCountryList!.length == 1)) {
                          return;
                        }
                        Navigator.pushNamed(
                          context,
                          Routes.countryCodePickerRoute,
                        ).then((Object? value) {
                          Future.delayed(
                            const Duration(milliseconds: 250),
                          ).then((value) {
                            context
                                .read<CountryCodeCubit>()
                                .fillTemporaryList();
                          });
                        });
                      },
                      child: Row(
                        children: [
                          Builder(
                            builder: (BuildContext context) {
                              if (state is CountryCodeFetchSuccess) {
                                return SizedBox(
                                  width: 35,
                                  height: 25,
                                  child:
                                      state.selectedCountry!.flagImage
                                          .startsWith('http')
                                      ? Image.network(
                                          state.selectedCountry!.flagImage,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          state.selectedCountry!.flag,
                                          fit: BoxFit.cover,
                                        ),
                                );
                              }
                              if (state is CountryCodeFetchFail) {
                                return ErrorContainer(
                                  errorMessage: state.error
                                      .toString()
                                      .translate(context: context),
                                );
                              }
                              return const CustomCircularProgressIndicator();
                            },
                          ),
                          const SizedBox(width: 10),
                          if (!allowOnlySingleCountry &&
                              !(state is CountryCodeFetchSuccess &&
                                  state.temporaryCountryList != null &&
                                  state.temporaryCountryList!.length == 1))
                            CustomSvgPicture(
                              svgImage: AppAssets.spDown,
                              height: 5,
                              width: 5,
                              color: Theme.of(context).colorScheme.accentColor,
                            ),
                        ],
                      ),
                    ),
                    VerticalDivider(
                      thickness: 1,
                      indent: 6,
                      endIndent: 6,
                      color: Theme.of(context).colorScheme.lightGreyColor,
                    ),
                    Text(
                      code,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.blackColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
              );
            },
          ),
        ),
        validator: (String? value) {
          return Validator.validateNumber(context, value!);
        },
      ),
    );
  }

  Widget _buildHeading() {
    return Text(
      widget.screenTitle.translate(context: context),
      style: TextStyle(
        color: Theme.of(context).colorScheme.blackColor,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        fontSize: 28.0,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubHeading() {
    return Text(
      widget.screenSubTitle.translate(context: context),
      style: TextStyle(
        color: Theme.of(context).colorScheme.blackColor.withValues(alpha: 0.5),
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        fontSize: 16.0,
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        //appBar: UiUtils.getSimpleAppBar(context: context, elevation: 1),
        body: Form(
          key: verifyPhoneNumberFormKey,
          child: CustomContainer(
            height: context.screenHeight,
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 40),
                    const CustomSvgPicture(
                      svgImage: AppAssets.loginLogo,
                      width: 100,
                      height: 108,
                      boxFit: BoxFit.cover,
                    ),
                    const SizedBox(height: 40),
                    _buildHeading(),
                    const SizedBox(height: 8),
                    _buildSubHeading(),
                    const SizedBox(height: 40),
                    _buildPhoneNumberFiled(),
                    _buildContinueButton(),
                    const SizedBox(height: 40),
                    Expanded(child: _buildPrivacyPolicyAndTnCContainer()),
                    const SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return BlocConsumer<
      VerifyPhoneNumberFromAPICubit,
      VerifyPhoneNumberFromAPIState
    >(
      listener:
          (BuildContext context, VerifyPhoneNumberFromAPIState state) async {
            if (state is VerifyPhoneNumberFromAPIFailure) {
              UiUtils.showMessage(
                context,
                state.errorMessage,
                ToastificationType.error,
              );
            }
            if (state is VerifyPhoneNumberFromAPISuccess) {
              //messageCode
              // 101:- Mobile number already registered and Active
              // 102:- Mobile number is not registered
              // 103:- Mobile number is De-active

              final bool isNewUser = widget.screenTitle != 'forgotPassword';

              if (state.messageCode == '101' && isNewUser) {
                UiUtils.showMessage(
                  context,
                  'mobileAlreadyRegistered',
                  ToastificationType.error,
                );
              } else if (state.messageCode == '102' && !isNewUser) {
                UiUtils.showMessage(
                  context,
                  'mobileNumberIsNotRegistered',
                  ToastificationType.error,
                );
              } else if (state.messageCode == '103') {
                UiUtils.showMessage(
                  context,
                  'mobileNumberIsDeactivate',
                  ToastificationType.error,
                );
              } else {
                if (state.authenticationMode == 'sms_gateway') {
                  context
                      .read<SendVerificationCodeCubit>()
                      .sendVerificationCodeUsingSMSGateway(
                        phoneNumberWithoutCountryCode:
                            phoneNumberWithoutCountryCode,
                        countryCode: context
                            .read<CountryCodeCubit>()
                            .getSelectedCountryCode(),
                        phoneNumberWithCountryCode: phoneNumberWithCountryCode,
                      );
                } else {
                  context
                      .read<SendVerificationCodeCubit>()
                      .sendVerificationCodeUsingFirebase(
                        phoneNumber: phoneNumberWithCountryCode,
                        countryCode: context
                            .read<CountryCodeCubit>()
                            .getSelectedCountryCode(),
                        phoneNumberWithCountryCode: phoneNumberWithCountryCode,
                      );
                }
              }
            }
          },
      builder: (BuildContext context, VerifyPhoneNumberFromAPIState state) {
        return BlocConsumer<
          SendVerificationCodeCubit,
          SendVerificationCodeState
        >(
          listener:
              (
                BuildContext context,
                SendVerificationCodeState verifyPhoneNumberState,
              ) {
                if (verifyPhoneNumberState
                    is SendVerificationCodeSuccessState) {
                  UiUtils.showMessage(
                    context,
                    'codeHasBeenSentToYourMobileNumber',
                    ToastificationType.success,
                  );
                  final String authenticationMode =
                      verifyPhoneNumberState.authenticationMode;
                  context.read<SendVerificationCodeCubit>().setInitialState();

                  Navigator.pushNamed(
                    context,
                    Routes.otpVerificationRoute,
                    arguments: {
                      'phoneNumberWithCountryCode': phoneNumberWithCountryCode,
                      'phoneNumberWithOutCountryCode':
                          phoneNumberWithoutCountryCode,
                      'countryCode': context
                          .read<CountryCodeCubit>()
                          .getSelectedCountryCode(),
                      'isItForForgotPassword':
                          widget.screenTitle == 'forgotPassword',
                      "authenticationMode": authenticationMode,
                    },
                  );
                } else if (verifyPhoneNumberState
                    is SendVerificationCodeFailureState) {
                  String errorMessage = '';

                  errorMessage = verifyPhoneNumberState.error
                      .toString()
                      .translate(context: context);
                  UiUtils.showMessage(
                    context,
                    errorMessage,
                    ToastificationType.error,
                  );
                }
              },
          builder:
              (
                BuildContext context,
                SendVerificationCodeState verifyPhoneNumberState,
              ) {
                final bool isLoading =
                    verifyPhoneNumberState
                        is SendVerificationCodeInProgressState ||
                    state is VerifyPhoneNumberFromAPIInProgress;

                return CustomRoundedButton(
                  height: 50,
                  onTap: () async {
                    if (verifyPhoneNumberState
                        is SendVerificationCodeInProgressState) {
                      return;
                    }
                    _onContinueButtonClicked();
                  },
                  buttonTitle: 'continue'.translate(context: context),
                  widthPercentage: 0.9,
                  backgroundColor: Theme.of(context).colorScheme.accentColor,
                  showBorder: false,
                  child: isLoading
                      ? CustomCircularProgressIndicator(
                          color: AppColors.whiteColors,
                        )
                      : null,
                );
              },
        );
      },
    );
  }

  Widget _buildPrivacyPolicyAndTnCContainer() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'byContinueYouAccept'.translate(context: context),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.lightGreyColor,
              fontSize: 12,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomInkWellContainer(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.appSettings,
                      arguments: {'title': 'privacyPolicyLbl'},
                    );
                  },
                  child: Text(
                    'privacyPolicyLbl'.translate(context: context),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.blackColor,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(
                  ' & ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.blackColor,
                    fontSize: 12,
                  ),
                ),
                CustomInkWellContainer(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.appSettings,
                      arguments: {'title': 'termsConditionLbl'},
                    );
                  },
                  child: Text(
                    'termsConditionLbl'.translate(context: context),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.blackColor,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
