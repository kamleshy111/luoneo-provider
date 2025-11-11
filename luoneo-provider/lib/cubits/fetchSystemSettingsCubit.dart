import '../../app/generalImports.dart';

abstract class FetchSystemSettingsState {}

class FetchSystemSettingsInitial extends FetchSystemSettingsState {}

class FetchSystemSettingsInProgress extends FetchSystemSettingsState {}

class FetchSystemSettingsSuccess extends FetchSystemSettingsState {
  final String termsAndConditions;
  final String privacyPolicy;
  final String aboutUs;
  final String contactUs;
  final String availableAmount;
  final String payableCommission;
  final String isDemoModeEnable;
  final String isAcceptingCustomJob;
  final GeneralSettings generalSettings;
  final PaymentGatewaysSettings paymentGatewaysSettings;
  final SubscriptionInformation subscriptionInformation;
  final AppSetting appSetting;
  final List<SocialMediaURL> socialMediaURLs;

  FetchSystemSettingsSuccess({
    required this.termsAndConditions,
    required this.privacyPolicy,
    required this.aboutUs,
    required this.contactUs,
    required this.availableAmount,
    required this.payableCommission,
    required this.isDemoModeEnable,
    required this.isAcceptingCustomJob,
    required this.paymentGatewaysSettings,
    required this.generalSettings,
    required this.subscriptionInformation,
    required this.socialMediaURLs,
    required this.appSetting,
  });

  FetchSystemSettingsSuccess copyWith({
    String? termsAndConditions,
    String? privacyPolicy,
    String? aboutUs,
    String? contactUs,
    String? availableAmount,
    String? payableCommission,
    String? isAcceptingCustomJob,
    GeneralSettings? generalSettings,
    AppSetting? appSetting,
    PaymentGatewaysSettings? paymentGatewaysSettings,
    SubscriptionInformation? subscriptionInformation,
    List<SocialMediaURL>? socialMediaURLs,
  }) {
    return FetchSystemSettingsSuccess(
      generalSettings: generalSettings ?? this.generalSettings,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      privacyPolicy: privacyPolicy ?? this.privacyPolicy,
      aboutUs: aboutUs ?? this.aboutUs,
      contactUs: contactUs ?? this.contactUs,
      isDemoModeEnable: isDemoModeEnable,
      availableAmount: availableAmount ?? this.availableAmount,
      payableCommission: payableCommission ?? this.payableCommission,
      isAcceptingCustomJob: isAcceptingCustomJob ?? this.isAcceptingCustomJob,
      paymentGatewaysSettings:
          paymentGatewaysSettings ?? this.paymentGatewaysSettings,
      subscriptionInformation:
          subscriptionInformation ?? this.subscriptionInformation,
      socialMediaURLs: socialMediaURLs ?? this.socialMediaURLs,
      appSetting: appSetting ?? this.appSetting,
    );
  }
}

class FetchSystemSettingsFailure extends FetchSystemSettingsState {
  final String errorMessage;

  FetchSystemSettingsFailure(this.errorMessage);
}

class FetchSystemSettingsCubit extends Cubit<FetchSystemSettingsState> {
  FetchSystemSettingsCubit() : super(FetchSystemSettingsInitial());
  final SettingsRepository _settingsRepository = SettingsRepository();

  Future<void> getSettings({required bool isAnonymous}) async {
    try {
      emit(FetchSystemSettingsInProgress());
      final result = await _settingsRepository.getSystemSettings(
        isAnonymous: isAnonymous,
      );

      emit(
        FetchSystemSettingsSuccess(
          socialMediaURLs: ((result["social_media"] ?? []) as List).isNotEmpty
              ? (result["social_media"] as List)
                    .map((e) => SocialMediaURL.fromJson(Map.from(e)))
                    .toList()
              : [],
          generalSettings: GeneralSettings.fromJson(
            result['general_settings'] ?? {},
          ),
          privacyPolicy: _extractContent(
            result['privacy_policy'],
            'privacy_policy',
          ),
          aboutUs: _extractContent(result['about_us'], 'about_us'),
          availableAmount: (result['balance'] ?? '').toString(),
          isDemoModeEnable: (result['demo_mode'] ?? '0').toString(),
          isAcceptingCustomJob: (result['is_accepting_custom_jobs'] ?? "0")
              .toString(),
          termsAndConditions: _extractContent(
            result['terms_conditions'],
            'terms_conditions',
          ),
          contactUs: _extractContent(result['contact_us'], 'contact_us'),
          //  privacyPolicy: result['privacy_policy']['privacy_policy'] ?? '',
          // aboutUs: result['about_us']['about_us'] ?? '',
          // availableAmount: result['balance'] ?? '',
          // isDemoModeEnable: result['demo_mode'] ?? '0',
          // isAcceptingCustomJob: result['is_accepting_custom_jobs'] ?? "0",
          // termsAndConditions:
          //     result['terms_conditions']['terms_conditions'] ?? '',
          // contactUs: result['contact_us']['contact_us'] ?? '',
          subscriptionInformation: result["subscription_information"] != null
              ? SubscriptionInformation.fromJson(
                  Map.from(result["subscription_information"] ?? {}),
                )
              : SubscriptionInformation(),
          paymentGatewaysSettings: PaymentGatewaysSettings.fromJson(
            result["payment_gateways_settings"] ?? {},
          ),
          appSetting: AppSetting.fromJson(result["app_settings"] ?? {}),
          // payableCommission: result['payable_commision'] ?? '',
          payableCommission: (result['payable_commision'] ?? '').toString(),
        ),
      );
    } catch (e) {
      emit(FetchSystemSettingsFailure(e.toString()));
    }
  }

  AppSetting get appSetting {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess).appSetting;
    }
    return AppSetting();
  }

  String get SystemCurrency => appSetting.currency ?? '';

  String get SystemCurrencyCountryCode => appSetting.countryCurrencyCode ?? '';

  String get SystemDecimalPoint => appSetting.decimalPoint ?? "0";

  bool get isOrderOTPConfirmationEnable =>
      generalSettings.isOrderOTPConfirmationEnable == '1';

  bool get isDoorstepOptionAvailable =>
      generalSettings.atDoorStepOptionAvailable == '1';

  GeneralSettings get generalSettings {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess).generalSettings;
    }
    return GeneralSettings();
  }

  bool get isStoreOptionAvailable =>
      generalSettings.atStoreOptionAvailable == '1';

  String get getAppStoreURL => appSetting.providerAppAppStoreURL ?? '';
  String get getPlayStoreURL => appSetting.providerAppPlayStoreURL ?? '';

  void updateAmount(String amount) {
    if (state is FetchSystemSettingsSuccess) {
      emit(
        (state as FetchSystemSettingsSuccess).copyWith(availableAmount: amount),
      );
    }
  }

  void updatePayebleCommision(String payableAmount) {
    if (state is FetchSystemSettingsSuccess) {
      emit(
        (state as FetchSystemSettingsSuccess).copyWith(
          payableCommission: payableAmount,
        ),
      );
    }
  }

  String getIsAcceptingCustomJobs() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess).isAcceptingCustomJob;
    }
    return "0";
  }

  bool get isDemoModeEnable =>
      (state as FetchSystemSettingsSuccess).isDemoModeEnable == '1';

  PaymentGatewaysSettings get paymentGatewaysSettings =>
      (state as FetchSystemSettingsSuccess).paymentGatewaysSettings;

  bool get isPayLaterAllowedByAdmin =>
      (state as FetchSystemSettingsSuccess)
          .paymentGatewaysSettings
          .isPayLaterEnable ==
      "1";

  List<SocialMediaURL> get socialMediaURLs {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess).socialMediaURLs;
    }
    return [];
  }

  Map<String, dynamic> get getContactUsDetails {
    return {
      "email": generalSettings.supportEmail ?? '',
      "mobile": generalSettings.phone ?? '',
      "address": generalSettings.address ?? '',
      "supportHours": generalSettings.supportHours ?? '',
    };
  }

  bool get isAdBannerEnabled => Platform.isAndroid
      ? appSetting.isAndroidAdEnabled == "1"
      : appSetting.isIosAdEnabled == "1";

  String get bannerAdId => Platform.isAndroid
      ? appSetting.androidBannerId ?? ''
      : appSetting.iosBannerId ?? '';

  String get interstitialAdId => Platform.isAndroid
      ? appSetting.androidInterstitialId ?? ''
      : appSetting.iosInterstitialId ?? '';

  List<Map<String, dynamic>> getEnabledPaymentMethods() {
    if (state is FetchSystemSettingsSuccess) {
      final PaymentGatewaysSettings paymentGatewaySetting =
          (state as FetchSystemSettingsSuccess).paymentGatewaysSettings;

      ///title will be shown in radio button
      ///description will be shown in radio button under title (conditional based on deliverable option)
      ///optionDescription will be shown in radio button under title (conditional based on deliverable option)
      ///image will be shown in radio button (icon)
      ///isEnabled will be shown in radio button (if enabled then only give option to select)
      ///paymentType will be used to identify the payment method (this type will be used in placeOrder)
      final List<Map<String, dynamic>> paymentMethods = [
        {
          "title": 'paypal',
          "description": 'payOnlineNowUsingPaypal',
          "image": AppAssets.icPaypal,
          "isEnabled": paymentGatewaySetting.paypalStatus == "enable",
          "paymentType": "paypal",
        },
        {
          "title": 'razorpay',
          "description": 'payOnlineNowUsingRazorpay',
          "image": AppAssets.icRazorpay,
          "isEnabled": paymentGatewaySetting.razorpayApiStatus == "enable",
          "paymentType": "razorpay",
        },
        {
          "title": 'paystack',
          "description": 'payOnlineNowUsingPaystack',
          "image": AppAssets.icPaystack,
          "isEnabled": paymentGatewaySetting.paystackStatus == "enable",
          "paymentType": "paystack",
        },
        {
          "title": 'stripe',
          "description": 'payOnlineNowUsingStripe',
          "image": AppAssets.icStripe,
          "isEnabled": paymentGatewaySetting.stripeStatus == "enable",
          "paymentType": "stripe",
        },
        {
          "title": 'flutterwave',
          "description": 'payOnlineNowUsingFlutterwave',
          "image": AppAssets.icFlutterwave,
          "isEnabled": paymentGatewaySetting.isFlutterwaveEnable == "enable",
          "paymentType": "flutterwave",
        },
        {
          "title": 'xendit',
          "description": 'payOnlineNowUsingXendit',
          "image": AppAssets.icXendit,
          "isEnabled": paymentGatewaySetting.isXenditEnabled,
          "paymentType": "xendit",
        },
      ];

      paymentMethods.removeWhere((element) => !element["isEnabled"]);
      return paymentMethods;
    }
    return [];
  }
}

String _extractContent(dynamic source, String key) {
  if (source == null) {
    return '';
  }
  if (source is String) {
    return source;
  }
  if (source is Map<String, dynamic>) {
    final dynamic value = source[key];
    return value?.toString() ?? '';
  }
  if (source is Map) {
    final dynamic value = source[key];
    return value?.toString() ?? '';
  }
  if (source is List && source.isNotEmpty) {
    final dynamic first = source.first;
    if (first is Map || first is Map<String, dynamic>) {
      return _extractContent(first, key);
    }
    return first?.toString() ?? '';
  }
  return source.toString();
}
