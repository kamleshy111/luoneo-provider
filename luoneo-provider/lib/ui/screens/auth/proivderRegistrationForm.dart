import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

import '../../../app/generalImports.dart';
import 'widgets/form_widgets.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key, required this.isEditing});

  final bool isEditing;

  @override
  RegistrationFormState createState() => RegistrationFormState();

  static Route<RegistrationForm> route(RouteSettings routeSettings) {
    final Map<String, dynamic> parameters =
        routeSettings.arguments as Map<String, dynamic>;

    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (BuildContext context) => EditProviderDetailsCubit(),
        child: RegistrationForm(isEditing: parameters['isEditing']),
      ),
    );
  }
}

class RegistrationFormState extends State<RegistrationForm> {
  int currentIndex = 1;

  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey4 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey5 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey6 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey7 = GlobalKey<FormState>();
  final GlobalKey<Form2CompanyInfoState> form2CompanyInfoKey =
      GlobalKey<Form2CompanyInfoState>();

  ScrollController scrollController = ScrollController();
  HtmlEditorController htmlController = HtmlEditorController();

  ///form1
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  FocusNode userNmFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode mobNoFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();

  Map<String, dynamic> pickedLocalImages = {
    'nationalIdImage': '',
    'addressIdImage': '',
    'passportIdImage': '',
    'logoImage': '',
    'bannerImage': '',
    'seoOgImage': '',
  };

  ///form2
  TextEditingController cityController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController aboutCompanyController = TextEditingController();
  TextEditingController visitingChargesController = TextEditingController();
  TextEditingController advanceBookingDaysController = TextEditingController();
  TextEditingController numberOfMemberController = TextEditingController();

  // Multi-language support for company name, about, and description
  int selectedLanguageIndex = 0;
  Map<String, TextEditingController> companyNameControllers = {};
  Map<String, TextEditingController> aboutCompanyControllers = {};
  Map<String, TextEditingController> longDescriptionControllers = {};
  List<AppLanguage> languages = [];
  AppLanguage? defaultLanguage;
  StreamSubscription? _languageListSubscription;

  // Saved data maps following promocode pattern
  Map<String, TextEditingController> userNameControllers = {};
  Map<String, String> savedUserNameData = {};
  Map<String, String> savedCompanyNameData = {};
  Map<String, String> savedAboutCompanyData = {};
  Map<String, String> savedLongDescriptionData = {};

  FocusNode aboutCompanyFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode latitudeFocus = FocusNode();
  FocusNode longitudeFocus = FocusNode();
  FocusNode companyNmFocus = FocusNode();
  FocusNode visitingChargeFocus = FocusNode();
  FocusNode advanceBookingDaysFocus = FocusNode();
  FocusNode numberOfMemberFocus = FocusNode();
  Map? selectCompanyType;
  Map companyType = {'0': 'Individual', '1': 'Organisation'};

  ///form3
  List<bool> isChecked = List<bool>.generate(
    7,
    (int index) => false,
  ); //7 = daysOfWeek.length
  List<TimeOfDay> selectedStartTime = [];
  List<TimeOfDay> selectedEndTime = [];

  late List<String> daysOfWeek = [
    'monLbl'.translate(context: context),
    'tueLbl'.translate(context: context),
    'wedLbl'.translate(context: context),
    'thuLbl'.translate(context: context),
    'friLbl'.translate(context: context),
    'satLbl'.translate(context: context),
    'sunLbl'.translate(context: context),
  ];

  late List<String> daysInWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  late List<String> _participant = [
    "personal",
    "company",
    "description",
    "seo",
    "workingDaysLbl",
    "bankAccount",
    "location",
  ];

  ///form4 - SEO
  TextEditingController seoTitleController = TextEditingController();
  TextEditingController seoDescriptionController = TextEditingController();
  TextEditingController seoKeywordsController = TextEditingController();
  TextEditingController seoSchemaMarkupController = TextEditingController();

  FocusNode seoTitleFocus = FocusNode();
  FocusNode seoDescriptionFocus = FocusNode();
  FocusNode seoKeywordsFocus = FocusNode();
  FocusNode seoSchemaMarkupFocus = FocusNode();

  ///form5 - previously form4
  TextEditingController bankNameController = TextEditingController();
  TextEditingController bankCodeController = TextEditingController();
  TextEditingController accountNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController taxNameController = TextEditingController();
  TextEditingController taxNumberController = TextEditingController();
  TextEditingController swiftCodeController = TextEditingController();

  FocusNode bankNameFocus = FocusNode();
  FocusNode bankCodeFocus = FocusNode();
  FocusNode bankAccountNumberFocus = FocusNode();
  FocusNode accountNameFocus = FocusNode();
  FocusNode accountNumberFocus = FocusNode();
  FocusNode taxNameFocus = FocusNode();
  FocusNode taxNumberFocus = FocusNode();
  FocusNode swiftCodeFocus = FocusNode();

  PickImage pickLogoImage = PickImage();
  PickImage pickBannerImage = PickImage();
  PickImage pickAddressProofImage = PickImage();
  PickImage pickPassportImage = PickImage();
  PickImage pickNationalIdImage = PickImage();
  PickImage pickSeoOgImage = PickImage();

  PickImage pickOtherImage = PickImage();

  ProviderDetails? providerData;
  bool? isIndividualType;

  String? isPreBookingChatAllowed;
  String? isPostBookingChatAllowed;
  String? atDoorstepAllowed;
  String? atStore;
  String? longDescription;

  ValueNotifier<List<String>> selectedOtherImages = ValueNotifier([]);
  ValueNotifier<List<String>> previouslyAddedOtherImages = ValueNotifier([]);

  Set<String> deletedPreviouslyAddedImages = {};

  @override
  void initState() {
    super.initState();

    initializeData();
    _initializeLanguages();
  }

  void _initializeLanguages() {
    final cubit = context.read<LanguageListCubit>();
    final currentLang = HiveRepository.getCurrentLanguage();

    if (currentLang == null) return;

    // Trigger fetching language list from cubit
    cubit.getLanguageList();

    // Cancel previous subscription if exists
    _languageListSubscription?.cancel();

    // Listen to cubit state once and initialize languages when success
    _languageListSubscription = cubit.stream.listen((state) {
      if (!mounted) return; // Check if widget is still mounted

      if (state is GetLanguageListSuccess) {
        languages = state.languages;
        defaultLanguage = state.defaultLanguage;

        // Set default language as first in list if not already
        if (defaultLanguage != null && languages.isNotEmpty) {
          final defaultIndex = languages.indexWhere(
            (lang) => lang.languageCode == defaultLanguage!.languageCode,
          );
          if (defaultIndex > 0) {
            // Move default language to first position
            final defaultLang = languages.removeAt(defaultIndex);
            languages.insert(0, defaultLang);
          }
        }

        // Initialize controllers after languages are loaded
        _initializeControllers();
        if (mounted) {
          setState(
            () {},
          ); // Refresh UI if needed only if widget is still mounted
        }

        // Cancel subscription after successful initialization to prevent memory leaks
        _languageListSubscription?.cancel();
        _languageListSubscription = null;
      }
    });
  }

  void _initializeControllers() {
    companyNameControllers = {};
    aboutCompanyControllers = {};
    longDescriptionControllers = {};
    userNameControllers = {};

    // Initialize all saved data maps following promocode pattern
    savedUserNameData = {};
    savedCompanyNameData = {};
    savedAboutCompanyData = {};
    savedLongDescriptionData = {};

    for (var lang in languages) {
      final String code = lang.languageCode;

      // Initialize company name controllers with translated data if available
      final String companyNameText =
          providerData?.providerInformation?.getTranslatedCompanyName(code) ??
          '';
      companyNameControllers[code] = TextEditingController(
        text: companyNameText,
      );
      savedCompanyNameData[code] = companyNameText; // Save to data map

      // Initialize about company controllers with translated data if available
      final String aboutText =
          providerData?.providerInformation?.getTranslatedAbout(code) ?? '';
      aboutCompanyControllers[code] = TextEditingController(text: aboutText);
      savedAboutCompanyData[code] = aboutText; // Save to data map

      // Initialize long description controllers with translated data if available
      final String longDescText =
          providerData?.providerInformation?.getTranslatedLongDescription(
            code,
          ) ??
          '';
      longDescriptionControllers[code] = TextEditingController(
        text: longDescText,
      );
      savedLongDescriptionData[code] = longDescText; // Save to data map

      // Initialize username controllers with translated data if available
      final String usernameText =
          providerData?.providerInformation?.getTranslatedUsername(code) ?? '';
      userNameControllers[code] = TextEditingController(text: usernameText);
      savedUserNameData[code] = usernameText; // Save to data map
    }

    // No need to call _populateTranslatedControllers as we already populated during initialization
  }

  // Method to update controllers with fresh provider data after API response
  void _updateControllersAfterApiResponse(ProviderDetails newProviderData) {
    providerData = newProviderData;

    // DON'T update controllers if user has already entered data
    // This prevents API response from overwriting user's current input
    final hasUserData =
        savedUserNameData.isNotEmpty ||
        savedCompanyNameData.isNotEmpty ||
        savedAboutCompanyData.isNotEmpty ||
        savedLongDescriptionData.isNotEmpty;

    if (hasUserData) {
      // Update main controllers from saved data, not API response
      final currentLangCode =
          HiveRepository.getCurrentLanguage()?.languageCode ?? 'en';
      final defaultLangCode = defaultLanguage?.languageCode ?? 'en';

      userNameController.text =
          savedUserNameData[currentLangCode] ??
          savedUserNameData[defaultLangCode] ??
          '';
      companyNameController.text =
          savedCompanyNameData[currentLangCode] ??
          savedCompanyNameData[defaultLangCode] ??
          '';
      aboutCompanyController.text =
          savedAboutCompanyData[currentLangCode] ??
          savedAboutCompanyData[defaultLangCode] ??
          '';
      longDescription =
          savedLongDescriptionData[currentLangCode] ??
          savedLongDescriptionData[defaultLangCode];

      return; // Don't update from API response
    }

    // Only update from API response if no user data exists (initial load)
    final currentLangCode =
        HiveRepository.getCurrentLanguage()?.languageCode ?? 'en';
    final defaultLangCode = defaultLanguage?.languageCode ?? 'en';

    userNameController.text =
        providerData?.providerInformation?.getTranslatedUsername(
          currentLangCode,
        ) ??
        providerData?.providerInformation?.getTranslatedUsername(
          defaultLangCode,
        ) ??
        '';
    companyNameController.text =
        providerData?.providerInformation?.getTranslatedCompanyName(
          currentLangCode,
        ) ??
        providerData?.providerInformation?.getTranslatedCompanyName(
          defaultLangCode,
        ) ??
        '';
    aboutCompanyController.text =
        providerData?.providerInformation?.getTranslatedAbout(
          currentLangCode,
        ) ??
        providerData?.providerInformation?.getTranslatedAbout(
          defaultLangCode,
        ) ??
        '';
    longDescription =
        providerData?.providerInformation?.getTranslatedLongDescription(
          currentLangCode,
        ) ??
        providerData?.providerInformation?.getTranslatedLongDescription(
          defaultLangCode,
        );

    // Update multi-language controllers from API response (initial load only)

    for (var lang in languages) {
      final String code = lang.languageCode;

      // Update username controllers and saved data
      if (userNameControllers.containsKey(code)) {
        final String usernameText = code == defaultLanguage?.languageCode
            ? userNameController.text
            : (providerData?.providerInformation?.getTranslatedUsername(code) ??
                  '');
        userNameControllers[code]!.text = usernameText;
        savedUserNameData[code] = usernameText; // Also update saved data
      }

      // Update company name controllers and saved data
      if (companyNameControllers.containsKey(code)) {
        final String companyNameText = code == defaultLanguage?.languageCode
            ? companyNameController.text
            : (providerData?.providerInformation?.getTranslatedCompanyName(
                    code,
                  ) ??
                  '');
        companyNameControllers[code]!.text = companyNameText;
        savedCompanyNameData[code] = companyNameText; // Also update saved data
      }

      // Update about company controllers and saved data
      if (aboutCompanyControllers.containsKey(code)) {
        final String aboutText = code == defaultLanguage?.languageCode
            ? aboutCompanyController.text
            : (providerData?.providerInformation?.getTranslatedAbout(code) ??
                  '');
        aboutCompanyControllers[code]!.text = aboutText;
        savedAboutCompanyData[code] = aboutText; // Also update saved data
      }

      // Update long description controllers and saved data
      if (longDescriptionControllers.containsKey(code)) {
        final String longDescText = code == defaultLanguage?.languageCode
            ? (longDescription ?? '')
            : (providerData?.providerInformation?.getTranslatedLongDescription(
                    code,
                  ) ??
                  '');
        longDescriptionControllers[code]!.text = longDescText;
        savedLongDescriptionData[code] = longDescText; // Also update saved data
      }
    }
  }

  // Method to save current HTML content to the current language controller
  Future<void> _saveCurrentHtmlContent() async {
    if (selectedLanguageIndex >= 0 &&
        selectedLanguageIndex < languages.length) {
      final currentLangCode = languages[selectedLanguageIndex].languageCode;
      final controller = longDescriptionControllers[currentLangCode];
      if (controller != null) {
        await _getHtmlContentWithRetry(controller);
      }
    }
  }

  // Robust method to get HTML content with retry mechanism
  Future<void> _getHtmlContentWithRetry(
    TextEditingController controller, {
    int maxRetries = 3,
    int currentRetry = 0,
  }) async {
    try {
      final text = await htmlController.getText();
      if (text.trim().isNotEmpty) {
        controller.text = text;
      }
    } catch (e) {
      if (currentRetry < maxRetries) {
        // Wait longer with each retry
        final delay = Duration(milliseconds: 500 * (currentRetry + 1));

        Future.delayed(delay, () {
          _getHtmlContentWithRetry(
            controller,
            maxRetries: maxRetries,
            currentRetry: currentRetry + 1,
          );
        });
      } else {
        // Fallback: keep current controller text
      }
    }
  }

  // Check if user can switch languages (validate default language required fields)
  bool _canSwitchLanguage(int targetIndex) {
    // Always allow switching to default language (index 0)
    if (targetIndex == 0) {
      return true;
    }

    // Always allow switching between non-default languages if already on non-default
    if (selectedLanguageIndex > 0 && targetIndex > 0) {
      return true;
    }

    // Switching from default (0) to other language - validate required fields
    if (selectedLanguageIndex == 0 && targetIndex > 0) {
      // Only validate for forms that have required fields in default language
      if (currentIndex == 2) {
        // Company info form
        if (!_areCompanyInfoRequiredFieldsFilled()) {
          UiUtils.showMessage(
            context,
            'pleaseCompleteDefaultLanguageFieldsFirst',
            ToastificationType.warning,
          );
          return false;
        }
      }
      // Note: Description form (currentIndex == 3) is optional, so no validation needed
    }

    return true;
  }

  // Check if company info required fields are filled in default language
  bool _areCompanyInfoRequiredFieldsFilled() {
    // Check required company info fields
    final hasCompanyName = companyNameController.text.trim().isNotEmpty;
    final hasAddress = addressController.text.trim().isNotEmpty;
    final hasPhone = mobileNumberController.text.trim().isNotEmpty;

    return hasCompanyName && hasAddress && hasPhone;
  }

  Future<void> _onLanguageChanged(int index) async {
    if (index >= 0 && index < languages.length) {
      // Check if can switch from default language to other languages
      if (!_canSwitchLanguage(index)) {
        return;
      }

      // Save ALL current language data before switching (following promocode pattern)
      _saveCurrentUserName();
      _saveCurrentCompanyName();
      _saveCurrentAboutCompany();
      // Don't call _saveCurrentLongDescription() here for Form 3 - we save from HTML editor below
      if (currentIndex != 3) {
        _saveCurrentLongDescription();
      }

      // Save current HTML content to the previous language controller (ONLY if on Form 3)
      if (currentIndex == 3 && selectedLanguageIndex < languages.length) {
        final previousLangCode = languages[selectedLanguageIndex].languageCode;
        final controller = longDescriptionControllers[previousLangCode];
        if (controller != null) {
          try {
            final text = await htmlController.getText();
            if (text.trim().isNotEmpty) {
              controller.text = text;
              savedLongDescriptionData[previousLangCode] =
                  text; // Also update saved data
            } else {}
          } catch (e) {
            // Handle error silently - HTML editor might not be ready
          }
        } else {}
      }

      // Update the selected language index first
      setState(() {
        selectedLanguageIndex = index;
      });

      // Clear form validation errors when switching languages
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Only clear validation state, not the field values
        if (formKey2.currentState != null) {
          // Force form to revalidate with current values, which will clear
          // validation errors for non-default languages
          formKey2.currentState!.validate();
        }
      });

      // Load HTML content for the new language with proper error handling
      if (index < languages.length) {
        final newLangCode = languages[index].languageCode;
        final controller = longDescriptionControllers[newLangCode];

        // Use a more robust retry mechanism for HTML editor
        _setHtmlContentWithRetry(controller, maxRetries: 3);
      }
    }
  }

  // Robust method to set HTML content with retry mechanism
  Future<void> _setHtmlContentWithRetry(
    TextEditingController? controller, {
    int maxRetries = 3,
    int currentRetry = 0,
  }) async {
    if (controller == null) {
      // Don't try to clear if controller is null, just return
      return;
    }

    try {
      if (controller.text.isNotEmpty) {
        htmlController.setText(controller.text);
      } else {
        // Only clear if there's content to clear
        try {
          final currentText = await htmlController.getText();
          if (currentText.trim().isNotEmpty) {
            htmlController.clear();
          } else {}
          // ignore: empty_catches
        } catch (e) {}
      }
    } catch (e) {
      if (currentRetry < maxRetries) {
        // Wait longer with each retry
        final delay = Duration(milliseconds: 1000 * (currentRetry + 1));

        Future.delayed(delay, () {
          _setHtmlContentWithRetry(
            controller,
            maxRetries: maxRetries,
            currentRetry: currentRetry + 1,
          );
        });
      } else {
        // Don't try to clear as fallback to avoid further errors
      }
    }
  }

  String? _getCompanyNameValidator(String? value) {
    if (selectedLanguageIndex < 0 ||
        selectedLanguageIndex >= languages.length) {
      return null;
    }

    final currentLanguage = languages[selectedLanguageIndex];
    final isDefaultLanguage =
        currentLanguage.languageCode == defaultLanguage?.languageCode;

    // Only validate for default language - non-default languages are optional
    if (isDefaultLanguage) {
      return Validator.nullCheck(context, value);
    }

    return null; // Optional for non-default languages
  }

  String? _getAboutCompanyValidator(String? value) {
    if (selectedLanguageIndex < 0 ||
        selectedLanguageIndex >= languages.length) {
      return null;
    }

    final currentLanguage = languages[selectedLanguageIndex];
    final isDefaultLanguage =
        currentLanguage.languageCode == defaultLanguage?.languageCode;

    // Only validate for default language - non-default languages are optional
    if (isDefaultLanguage) {
      return Validator.nullCheck(context, value);
    }

    return null; // Optional for non-default languages
  }

  String? _getLongDescriptionValidator(String? value) {
    if (selectedLanguageIndex < 0 ||
        selectedLanguageIndex >= languages.length) {
      return null;
    }

    final currentLanguage = languages[selectedLanguageIndex];
    final isDefaultLanguage =
        currentLanguage.languageCode == defaultLanguage?.languageCode;

    // Only validate for default language - non-default languages are optional
    if (isDefaultLanguage) {
      return Validator.nullCheck(context, value);
    }

    return null; // Optional for non-default languages
  }

  String? _getUserNameValidator(String? value) {
    if (languages.isEmpty ||
        selectedLanguageIndex < 0 ||
        selectedLanguageIndex >= languages.length) {
      return null;
    }

    final currentLanguage = languages[selectedLanguageIndex];
    final isDefaultLanguage =
        currentLanguage.languageCode == defaultLanguage?.languageCode;

    // Only validate for default language - non-default languages are optional
    if (isDefaultLanguage) {
      return Validator.nullCheck(context, value);
    }

    return null; // Optional for non-default languages
  }

  // Save methods for all multi-language fields (following promocode pattern)
  void _saveCurrentUserName() {
    if (languages.isNotEmpty && selectedLanguageIndex < languages.length) {
      final currentLangCode = languages[selectedLanguageIndex].languageCode;
      final controller = userNameControllers[currentLangCode];
      if (controller != null) {
        savedUserNameData[currentLangCode] = controller.text;
      }
    }
  }

  void _saveCurrentCompanyName() {
    if (languages.isNotEmpty && selectedLanguageIndex < languages.length) {
      final currentLangCode = languages[selectedLanguageIndex].languageCode;
      final controller = companyNameControllers[currentLangCode];
      if (controller != null) {
        savedCompanyNameData[currentLangCode] = controller.text;
      }
    }
  }

  void _saveCurrentAboutCompany() {
    if (languages.isNotEmpty && selectedLanguageIndex < languages.length) {
      final currentLangCode = languages[selectedLanguageIndex].languageCode;
      final controller = aboutCompanyControllers[currentLangCode];
      if (controller != null) {
        savedAboutCompanyData[currentLangCode] = controller.text;
      }
    }
  }

  void _saveCurrentLongDescription() {
    if (languages.isNotEmpty && selectedLanguageIndex < languages.length) {
      final currentLangCode = languages[selectedLanguageIndex].languageCode;
      final controller = longDescriptionControllers[currentLangCode];
      if (controller != null) {
        // For Form 3, we should get content from HTML editor, not controller
        // But we can't make this method async, so just save the controller text
        // The actual HTML editor saving happens in _onLanguageChanged and _saveCurrentFormData
        savedLongDescriptionData[currentLangCode] = controller.text;
      }
    }
  }

  // Method to get username data for API (following promocode pattern)
  Map<String, String> getUserNameData() {
    // Save current language data before collecting all data
    _saveCurrentUserName();

    final Map<String, String> userNameData = {};

    if (languages.isNotEmpty) {
      for (var lang in languages) {
        final String code = lang.languageCode;
        final value = savedUserNameData[code] ?? '';
        // Always include all languages, even if empty
        userNameData[code] = value.trim();
      }
    }

    return userNameData;
  }

  // Method to get company name data for API (following promocode pattern)
  Map<String, String> getCompanyNameData() {
    // Save current language data before collecting all data
    _saveCurrentCompanyName();

    final Map<String, String> companyNameData = {};

    if (languages.isNotEmpty) {
      for (var lang in languages) {
        final String code = lang.languageCode;
        final value = savedCompanyNameData[code] ?? '';
        // Always include all languages, even if empty
        companyNameData[code] = value.trim();
      }
    }

    return companyNameData;
  }

  // Method to get about company data for API (following promocode pattern)
  Map<String, String> getAboutCompanyData() {
    // Save current language data before collecting all data
    _saveCurrentAboutCompany();

    final Map<String, String> aboutCompanyData = {};

    if (languages.isNotEmpty) {
      for (var lang in languages) {
        final String code = lang.languageCode;
        final value = savedAboutCompanyData[code] ?? '';
        // Always include all languages, even if empty
        aboutCompanyData[code] = value.trim();
      }
    }

    return aboutCompanyData;
  }

  // Method to get long description data for API (following promocode pattern)
  Map<String, String> getLongDescriptionData() {
    // Save current language data before collecting all data
    _saveCurrentLongDescription();

    final Map<String, String> longDescriptionData = {};

    if (languages.isNotEmpty) {
      for (var lang in languages) {
        final String code = lang.languageCode;
        final value = savedLongDescriptionData[code] ?? '';
        // Always include all languages, even if empty
        longDescriptionData[code] = value.trim();
      }
    }

    return longDescriptionData;
  }

  // Helper method to reset to default language when entering company info or description page
  void _resetToDefaultLanguageIfNeeded(int newCurrentIndex) {
    // Reset to default language when entering Form 2 (company info) or Form 3 (description)
    if ((newCurrentIndex == 2 || newCurrentIndex == 3) &&
        languages.isNotEmpty &&
        defaultLanguage != null) {
      final defaultIndex = languages.indexWhere(
        (lang) => lang.languageCode == defaultLanguage!.languageCode,
      );
      if (defaultIndex >= 0) {
        selectedLanguageIndex = defaultIndex;
      } else {}
    } else {}
  }

  void initializeData() {
    Future.delayed(Duration.zero).then((value) {
      providerData = context.read<ProviderDetailsCubit>().providerDetails;

      // Get current language code for main controllers (with fallback to default)
      final currentLangCode =
          HiveRepository.getCurrentLanguage()?.languageCode ?? 'en';
      final defaultLangCode = defaultLanguage?.languageCode ?? 'en';

      userNameController.text =
          providerData?.providerInformation?.getTranslatedUsername(
            currentLangCode,
          ) ??
          providerData?.providerInformation?.getTranslatedUsername(
            defaultLangCode,
          ) ??
          '';
      emailController.text = providerData?.user?.email ?? '';
      mobileNumberController.text =
          "${providerData?.user?.countryCode ?? ''} ${providerData?.user?.phone ?? ''}";
      companyNameController.text =
          providerData?.providerInformation?.getTranslatedCompanyName(
            currentLangCode,
          ) ??
          providerData?.providerInformation?.getTranslatedCompanyName(
            defaultLangCode,
          ) ??
          '';
      aboutCompanyController.text =
          providerData?.providerInformation?.getTranslatedAbout(
            currentLangCode,
          ) ??
          providerData?.providerInformation?.getTranslatedAbout(
            defaultLangCode,
          ) ??
          '';

      isPostBookingChatAllowed =
          providerData?.providerInformation?.isPostBookingChatAllowed ?? "0";
      isPreBookingChatAllowed =
          providerData?.providerInformation?.isPreBookingChatAllowed ?? "0";

      atDoorstepAllowed = providerData?.providerInformation?.atDoorstep ?? "0";

      atStore = providerData?.providerInformation?.atStore ?? "0";

      // SEO fields initialization
      seoTitleController.text =
          providerData?.providerInformation?.seoTitle ?? '';
      seoDescriptionController.text =
          providerData?.providerInformation?.seoDescription ?? '';
      seoKeywordsController.text =
          providerData?.providerInformation?.seoKeywords ?? '';
      seoSchemaMarkupController.text =
          providerData?.providerInformation?.seoSchemaMarkup ?? '';

      bankNameController.text = providerData?.bankInformation?.bankName ?? '';
      bankCodeController.text = providerData?.bankInformation?.bankCode ?? '';
      accountNameController.text =
          providerData?.bankInformation?.accountName ?? '';
      accountNumberController.text =
          providerData?.bankInformation?.accountNumber ?? '';
      taxNameController.text = providerData?.bankInformation?.taxName ?? '';
      taxNumberController.text = providerData?.bankInformation?.taxNumber ?? '';
      swiftCodeController.text = providerData?.bankInformation?.swiftCode ?? '';

      cityController.text = providerData?.locationInformation?.city ?? '';
      addressController.text = providerData?.locationInformation?.address ?? '';
      latitudeController.text =
          providerData?.locationInformation?.latitude ?? '';
      longitudeController.text =
          providerData?.locationInformation?.longitude ?? '';
      companyNameController.text =
          providerData?.providerInformation?.getTranslatedCompanyName(
            currentLangCode,
          ) ??
          providerData?.providerInformation?.getTranslatedCompanyName(
            defaultLangCode,
          ) ??
          '';
      aboutCompanyController.text =
          providerData?.providerInformation?.getTranslatedAbout(
            currentLangCode,
          ) ??
          providerData?.providerInformation?.getTranslatedAbout(
            defaultLangCode,
          ) ??
          '';
      visitingChargesController.text =
          providerData?.providerInformation?.visitingCharges ?? '';
      advanceBookingDaysController.text =
          providerData?.providerInformation?.advanceBookingDays ?? '';
      numberOfMemberController.text =
          providerData?.providerInformation?.numberOfMembers ?? '';
      selectCompanyType = providerData?.providerInformation?.type == '0'
          ? {'title': 'Individual', 'value': '0'}
          : {'title': 'Organization', 'value': '1'};
      isIndividualType = providerData?.providerInformation?.type == '0';
      //add elements in TimeOfDay List

      final List<WorkingDay>? data = providerData?.workingDays?.reversed
          .toList();
      for (int i = 0; i < daysInWeek.length; i++) {
        //assign Default time @ start
        final List<String> startTime = (data?[i].startTime ?? '09:00:00').split(
          ':',
        );
        final List<String> endTime = (data?[i].endTime ?? '18:00:00').split(
          ':',
        );

        final int startTimeHour = int.parse(startTime[0]);
        final int startTimeMinute = int.parse(startTime[1]);
        selectedStartTime.insert(
          i,
          TimeOfDay(hour: startTimeHour, minute: startTimeMinute),
        );

        final int endTimeHour = int.parse(endTime[0]);
        final int endTimeMinute = int.parse(endTime[1]);
        selectedEndTime.insert(
          i,
          TimeOfDay(hour: endTimeHour, minute: endTimeMinute),
        );
        isChecked[i] = data?[i].isOpen == 1;
      }

      longDescription =
          providerData?.providerInformation?.getTranslatedLongDescription(
            currentLangCode,
          ) ??
          providerData?.providerInformation?.getTranslatedLongDescription(
            defaultLangCode,
          );
      previouslyAddedOtherImages.value = [
        ...?providerData?.providerInformation?.otherImages,
      ];

      // Initialize language-specific controllers with fetched translated data
      // Call this even if languages haven't loaded yet - it will be called again when they do
      if (languages.isNotEmpty) {
        _populateTranslatedControllers();
      }

      setState(() {});
    });
  }

  void _populateTranslatedControllers() {
    if (languages.isEmpty) {
      return;
    }

    // Populate all controllers using helper methods
    for (var lang in languages) {
      final String code = lang.languageCode;

      // Populate company name controllers and saved data
      final translatedCompanyName = providerData?.providerInformation
          ?.getTranslatedCompanyName(code);
      if (translatedCompanyName != null) {
        companyNameControllers[code]?.text = translatedCompanyName;
        savedCompanyNameData[code] = translatedCompanyName;
      }

      // Populate about company controllers and saved data
      final translatedAbout = providerData?.providerInformation
          ?.getTranslatedAbout(code);
      if (translatedAbout != null) {
        aboutCompanyControllers[code]?.text = translatedAbout;
        savedAboutCompanyData[code] = translatedAbout;
      }

      // Populate long description controllers and saved data
      final translatedLongDesc = providerData?.providerInformation
          ?.getTranslatedLongDescription(code);
      if (translatedLongDesc != null) {
        longDescriptionControllers[code]?.text = translatedLongDesc;
        savedLongDescriptionData[code] = translatedLongDesc;
      }

      // Populate username controllers and saved data
      final translatedUsername = providerData?.providerInformation
          ?.getTranslatedUsername(code);
      if (translatedUsername != null) {
        userNameControllers[code]?.text = translatedUsername;
        savedUserNameData[code] = translatedUsername;
      }
    }
  }

  @override
  void dispose() {
    // Cancel stream subscription to prevent memory leaks
    _languageListSubscription?.cancel();

    // Save current HTML content before disposing
    _saveCurrentHtmlContent();

    userNameController.dispose();
    emailController.dispose();
    mobileNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    companyNameController.dispose();
    visitingChargesController.dispose();
    advanceBookingDaysController.dispose();
    numberOfMemberController.dispose();
    aboutCompanyController.dispose();
    cityController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    addressController.dispose();
    bankNameController.dispose();
    bankCodeController.dispose();
    accountNameController.dispose();
    accountNumberController.dispose();
    taxNumberController.dispose();
    taxNameController.dispose();
    swiftCodeController.dispose();

    // SEO controllers disposal
    seoTitleController.dispose();
    seoDescriptionController.dispose();
    seoKeywordsController.dispose();
    seoSchemaMarkupController.dispose();

    // Dispose language-specific controllers
    companyNameControllers.values.forEach((controller) => controller.dispose());
    aboutCompanyControllers.values.forEach(
      (controller) => controller.dispose(),
    );
    longDescriptionControllers.values.forEach(
      (controller) => controller.dispose(),
    );
    userNameControllers.values.forEach((controller) => controller.dispose());

    pickedLocalImages.clear();
    previouslyAddedOtherImages.dispose();
    selectedOtherImages.dispose();

    confirmPasswordFocus.dispose();
    passwordFocus.dispose();
    mobNoFocus.dispose();
    emailFocus.dispose();
    userNmFocus.dispose();
    numberOfMemberFocus.dispose();
    advanceBookingDaysFocus.dispose();
    visitingChargeFocus.dispose();
    companyNmFocus.dispose();
    longitudeFocus.dispose();
    latitudeFocus.dispose();
    addressFocus.dispose();
    cityFocus.dispose();
    aboutCompanyFocus.dispose();
    swiftCodeFocus.dispose();
    taxNumberFocus.dispose();
    taxNameFocus.dispose();
    accountNumberFocus.dispose();
    accountNameFocus.dispose();
    bankAccountNumberFocus.dispose();
    bankCodeFocus.dispose();
    bankNameFocus.dispose();

    // SEO focus nodes disposal
    seoTitleFocus.dispose();
    seoDescriptionFocus.dispose();
    seoKeywordsFocus.dispose();
    seoSchemaMarkupFocus.dispose();

    pickNationalIdImage.dispose();
    pickPassportImage.dispose();
    pickAddressProofImage.dispose();
    pickBannerImage.dispose();
    pickLogoImage.dispose();
    pickSeoOgImage.dispose();

    scrollController.dispose();
    super.dispose();
  }

  // Method to save current form data before navigation
  Future<void> _saveCurrentFormData() async {
    try {
      // Save multi-language data for current form (following promocode pattern)
      if (currentIndex == 1) {
        // Personal info form - save username
        _saveCurrentUserName();
      } else if (currentIndex == 2) {
        // Company info form - save company name and about
        _saveCurrentCompanyName();
        _saveCurrentAboutCompany();
      } else if (currentIndex == 3) {
        // Description form - save long description
        _saveCurrentLongDescription();
      }

      // Save HTML editor content if on description page (step 3)
      if (currentIndex == 3) {
        final tempText = await htmlController.getText();
        if (tempText.trim().isNotEmpty) {
          // Save to current language's HTML content
          if (selectedLanguageIndex < languages.length) {
            final langCode = languages[selectedLanguageIndex].languageCode;
            longDescriptionControllers[langCode]?.text = tempText;
            savedLongDescriptionData[langCode] =
                tempText; // Also save to data map
          }
        }
      }

      // Save form data based on current step
      switch (currentIndex) {
        case 2:
          // Company info form data is automatically saved in controllers
          formKey2.currentState?.save();
          break;
        case 3:
          // Description form - HTML content already saved above
          break;
        case 4:
          // Documents form data is automatically saved
          break;
      }
    } catch (e) {
      // Handle errors silently
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator if languages are not yet loaded for forms that need them
    // Form 1 (personal info with username), Form 2 (company info), Form 3 (description)
    if ((currentIndex == 1 || currentIndex == 2 || currentIndex == 3) &&
        languages.isEmpty) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: Scaffold(
          appBar: AppBar(
            elevation: 1,
            title: CustomText(
              widget.isEditing
                  ? 'completeRegistration'.translate(context: context)
                  : 'completeKYCDetails'.translate(context: context),
              color: Theme.of(context).colorScheme.blackColor,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            leading: widget.isEditing
                ? InkWell(
                    onTap: () async {
                      await _saveCurrentFormData();
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.close,
                      color: context.colorScheme.blackColor,
                    ),
                  )
                : null,
            backgroundColor: Theme.of(context).colorScheme.secondaryColor,
            surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
          ),
          body: Padding(
            padding: const EdgeInsets.all(15),
            child: ShimmerLoadingContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const CustomShimmerContainer(
                    height: 50,
                    margin: EdgeInsets.only(bottom: 20),
                  ),
                  if (currentIndex == 1) ...const [
                    CustomShimmerContainer(
                      height: 60,
                      margin: EdgeInsets.only(bottom: 15),
                    ),
                    CustomShimmerContainer(
                      height: 60,
                      margin: EdgeInsets.only(bottom: 15),
                    ),
                    CustomShimmerContainer(
                      height: 60,
                      margin: EdgeInsets.only(bottom: 15),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomShimmerContainer(
                            height: 40,
                            margin: EdgeInsets.only(right: 5),
                          ),
                        ),
                        Expanded(
                          child: CustomShimmerContainer(
                            height: 40,
                            margin: EdgeInsets.only(left: 5),
                          ),
                        ),
                      ],
                    ),
                  ] else if (currentIndex == 2) ...const [
                    CustomShimmerContainer(
                      height: 60,
                      margin: EdgeInsets.only(bottom: 15),
                    ),
                    CustomShimmerContainer(
                      height: 60,
                      margin: EdgeInsets.only(bottom: 15),
                    ),
                    CustomShimmerContainer(
                      height: 100,
                      margin: EdgeInsets.only(bottom: 15),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomShimmerContainer(
                            height: 60,
                            margin: EdgeInsets.only(right: 5),
                          ),
                        ),
                        Expanded(
                          child: CustomShimmerContainer(
                            height: 60,
                            margin: EdgeInsets.only(left: 5),
                          ),
                        ),
                      ],
                    ),
                  ] else if (currentIndex == 3) ...const [
                    CustomShimmerContainer(
                      height: 50,
                      margin: EdgeInsets.only(bottom: 20),
                    ),
                    CustomShimmerContainer(
                      height: 200,
                      margin: EdgeInsets.only(bottom: 15),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Ensure selectedLanguageIndex is valid
    if (languages.isNotEmpty &&
        (selectedLanguageIndex < 0 ||
            selectedLanguageIndex >= languages.length)) {
      selectedLanguageIndex = 0;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: PopScope(
        canPop: currentIndex == 1,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) {
            return;
          } else {
            if (currentIndex > 1) {
              // Save current form data before going back
              await _saveCurrentFormData();
              currentIndex--;
              pickedLocalImages = pickedLocalImages;
              setState(() {});
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 1,
            title: CustomText(
              widget.isEditing
                  ? 'completeRegistration'.translate(context: context)
                  : 'completeKYCDetails'.translate(context: context),
              color: Theme.of(context).colorScheme.blackColor,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            leading: widget.isEditing
                ? InkWell(
                    onTap: () async {
                      await _saveCurrentFormData();
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.close,
                      color: context.colorScheme.blackColor,
                    ),
                  )
                : null,
            backgroundColor: Theme.of(context).colorScheme.secondaryColor,
            surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
            bottom: PreferredSize(
              preferredSize: const Size(double.infinity, 70),
              child: SizedBox(
                height: 70,
                child: EasyStepper(
                  internalPadding: 0,
                  borderThickness: 0,
                  stepBorderRadius: 0,
                  showStepBorder: false,
                  padding: EdgeInsets.only(left: 30, right: 30),
                  activeStep: currentIndex - 1,
                  lineStyle: LineStyle(
                    lineSpace: 0,
                    finishedLineColor: context.colorScheme.accentColor,
                    defaultLineColor: context.colorScheme.primaryColor,
                    lineLength: 100,
                    lineType: LineType.normal,
                    lineThickness: 2,
                    lineWidth: 30,
                    progress: 0.5,
                    progressColor: context.colorScheme.accentColor,
                  ),
                  stepRadius: 11,
                  finishedStepBackgroundColor:
                      context.colorScheme.secondaryColor,
                  finishedStepIconColor: context.colorScheme.accentColor,
                  finishedStepBorderColor: context.colorScheme.accentColor,
                  finishedStepBorderType: BorderType.normal,
                  showLoadingAnimation: false,
                  onStepReached: (index) async {
                    if (index + 1 != currentIndex) {
                      // Validate current form before changing
                      FormState? form = formKey1.currentState;
                      switch (currentIndex) {
                        case 2:
                          form = formKey2.currentState;
                          break;
                        case 4:
                          form = formKey4.currentState;
                          break;
                        case 5:
                          form = formKey5.currentState;
                          break;
                        case 6:
                          form = formKey6.currentState;
                          break;
                        default:
                          form = formKey1.currentState;
                          break;
                      }

                      if (form != null) {
                        form.save();
                        if (form.validate()) {
                          setState(() {
                            currentIndex = index + 1;
                          });
                          scrollController.jumpTo(0);
                        }
                      } else {
                        setState(() {
                          currentIndex = index + 1;
                        });
                        scrollController.jumpTo(0);
                      }
                    }
                  },
                  unreachedStepBackgroundColor: context.colorScheme.primaryColor
                      .withValues(alpha: 0.2),
                  steps: List<EasyStep>.generate(
                    _participant.length,
                    (index) => EasyStep(
                      customStep: CustomSvgPicture(
                        svgImage: AppAssets.bClock,
                        color: index <= currentIndex - 1
                            ? context.colorScheme.accentColor
                            : context.colorScheme.lightGreyColor,
                      ),
                      customTitle: CustomText(
                        _participant[index].translate(context: context),
                        textAlign: index == 0
                            ? TextAlign.right
                            : index == _participant.length - 1
                            ? TextAlign.left
                            : TextAlign.center,
                        color: index == currentIndex - 1
                            ? context.colorScheme.accentColor
                            : context.colorScheme.blackColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ).toList(),
                ),
              ),
            ),
          ),
          bottomNavigationBar: bottomNavigation(currentIndex: currentIndex),
          body: screenBuilder(currentIndex),
        ),
      ),
    );
  }

  Widget bottomNavigation({required int currentIndex}) {
    return CustomContainer(
      color: context.colorScheme.secondaryColor,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 10,
        top: 10,
        right: 15,
        left: 15,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentIndex > 1) ...[
            Expanded(
              flex: 1,
              child: nextPrevBtnWidget(
                isNext: false,
                currentIndex: currentIndex,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 5,
            child: BlocListener<EditProviderDetailsCubit, EditProviderDetailsState>(
              listener:
                  (BuildContext context, EditProviderDetailsState state) async {
                    if (state is EditProviderDetailsSuccess) {
                      UiUtils.showMessage(
                        context,
                        'detailsUpdatedSuccessfully',
                        ToastificationType.success,
                      );

                      if (widget.isEditing) {
                        context.read<ProviderDetailsCubit>().setUserInfo(
                          state.providerDetails,
                        );

                        // Update local controllers with the new data from API response
                        _updateControllersAfterApiResponse(
                          state.providerDetails,
                        );

                        Future.delayed(const Duration(seconds: 1)).then((
                          value,
                        ) {
                          Navigator.pop(context);
                        });
                      } else {
                        Future.delayed(Duration.zero, () {
                          HiveRepository.setUserLoggedIn = false;
                          HiveRepository.clearBoxValues(
                            boxName: HiveRepository.userDetailBoxKey,
                          );
                          context
                              .read<AuthenticationCubit>()
                              .setUnAuthenticated();
                          AppQuickActions.clearShortcutItems();
                        });

                        Future.delayed(const Duration(seconds: 1)).then((
                          value,
                        ) {
                          Navigator.pushReplacementNamed(
                            context,
                            Routes.successScreen,
                            arguments: {
                              'title': 'detailsSubmitted'.translate(
                                context: context,
                              ),
                              'message':
                                  'detailsHasBeenSubmittedWaitForAdminApproval'
                                      .translate(context: context),
                              'imageName': 'registration',
                            },
                          );
                        });
                      }
                    } else if (state is EditProviderDetailsFailure) {
                      UiUtils.showMessage(
                        context,
                        state.errorMessage,
                        ToastificationType.error,
                      );
                    }
                  },
              child: nextPrevBtnWidget(
                isNext: true,
                currentIndex: currentIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BlocBuilder<EditProviderDetailsCubit, EditProviderDetailsState>
  nextPrevBtnWidget({required bool isNext, required int currentIndex}) {
    return BlocBuilder<EditProviderDetailsCubit, EditProviderDetailsState>(
      builder: (BuildContext context, EditProviderDetailsState state) {
        Widget? child;
        if (state is EditProviderDetailsInProgress) {
          child = CustomCircularProgressIndicator(color: AppColors.whiteColors);
        } else if (state is EditProviderDetailsSuccess ||
            state is EditProviderDetailsFailure) {
          child = null;
        }
        return CustomRoundedButton(
          textSize: 16,
          widthPercentage: isNext ? 1 : 0.5,
          backgroundColor: isNext
              ? Theme.of(context).colorScheme.accentColor
              : Theme.of(context).colorScheme.accentColor.withAlpha(20),
          showBorder: false,
          titleColor: isNext
              ? AppColors.whiteColors
              : Theme.of(context).colorScheme.blackColor,
          onTap: () => state is EditProviderDetailsInProgress
              ? () {}
              : onNextPrevBtnClick(isNext: isNext, currentPage: currentIndex),
          buttonTitleWidget: isNext && currentIndex >= _participant.length
              ? CustomText(
                  'submitBtnLbl'.translate(context: context),
                  fontSize: 16.0,
                  color: AppColors.whiteColors,
                )
              : isNext
              ? CustomText(
                  'nxtBtnLbl'.translate(context: context),
                  fontSize: 16.0,
                  color: AppColors.whiteColors,
                )
              : CustomSvgPicture(
                  svgImage: AppAssets.backArrowLight,
                  color: context.colorScheme.accentColor,
                ),
          child: isNext && currentIndex >= _participant.length ? child : null,
        );
      },
    );
  }

  Future<void> onNextPrevBtnClick({
    required bool isNext,
    required int currentPage,
  }) async {
    if (currentPage == 3) {
      try {
        final tempText = await htmlController.getText();

        if (tempText.trim().isNotEmpty) {
          longDescription = tempText;
          // Also save to the current language controller
          await _saveCurrentHtmlContent();
        }
      } catch (e) {
        // Handle error silently - HTML editor might not be ready
        // Try to save from the current language controller instead
        if (selectedLanguageIndex >= 0 &&
            selectedLanguageIndex < languages.length) {
          final currentLangCode = languages[selectedLanguageIndex].languageCode;
          final controller = longDescriptionControllers[currentLangCode];
          if (controller != null && controller.text.trim().isNotEmpty) {
            longDescription = controller.text;
          }
        }
      }
    }
    if (isNext) {
      FormState? form = formKey1.currentState; //default value
      switch (currentPage) {
        case 2:
          form = formKey2.currentState;
          break;
        case 4:
          form = formKey4.currentState;
          break;
        case 5:
          form = formKey5.currentState;
          break;
        case 6:
          form = formKey6.currentState;
          break;
        case 7:
          form = formKey7.currentState;
          break;
        default:
          form = formKey1.currentState;
          break;
      }

      if (currentPage != 3) {
        if (form == null) return;
        form.save();
      }

      if (currentPage == 3 || form!.validate()) {
        // Add image validation specifically for form 2 (company info)
        if (currentPage == 2) {
          // Validate that logo and banner images are present
          final bool imagesValid =
              form2CompanyInfoKey.currentState?.validateImagesPresence(
                context,
              ) ??
              false;
          debugPrint("Image validation result: $imagesValid");
          if (!imagesValid) {
            return; // Stop proceeding if images are not valid
          }
        }

        if (currentPage == 1) {
          final bool isPassportRequiredStatus =
              (context.read<FetchSystemSettingsCubit>().state
                      as FetchSystemSettingsSuccess)
                  .generalSettings
                  .passportRequiredStatus!;
          final bool isNationalIdRequiredStatus =
              (context.read<FetchSystemSettingsCubit>().state
                      as FetchSystemSettingsSuccess)
                  .generalSettings
                  .nationalIdRequiredStatus!;
          final bool isAddressIdRequiredStatus =
              (context.read<FetchSystemSettingsCubit>().state
                      as FetchSystemSettingsSuccess)
                  .generalSettings
                  .addressIdRequiredStatus!;
          if (isPassportRequiredStatus) {
            if ((pickedLocalImages['passportIdImage'] == '') &&
                context
                        .read<ProviderDetailsCubit>()
                        .providerDetails
                        .providerInformation
                        ?.passport ==
                    '') {
              UiUtils.showMessage(
                context,
                'passportIdImageRequired',
                ToastificationType.error,
              );
              return;
            }
          }
          if (isNationalIdRequiredStatus) {
            if ((pickedLocalImages['nationalIdImage'] == '') &&
                context
                        .read<ProviderDetailsCubit>()
                        .providerDetails
                        .providerInformation
                        ?.nationalId ==
                    '') {
              UiUtils.showMessage(
                context,
                'nationalIdImageRequired',
                ToastificationType.error,
              );
              return;
            }
          }

          if (isAddressIdRequiredStatus) {
            if ((pickedLocalImages['addressIdImage'] == '') &&
                context
                        .read<ProviderDetailsCubit>()
                        .providerDetails
                        .providerInformation
                        ?.addressId ==
                    '') {
              UiUtils.showMessage(
                context,
                'addressIdImageRequired',
                ToastificationType.error,
              );
              return;
            }
          }
        }

        if (currentPage < _participant.length) {
          // Save current form data before proceeding (next button)
          await _saveCurrentFormData();

          // Reset to default language BEFORE updating currentIndex
          _resetToDefaultLanguageIfNeeded(currentPage + 1);

          currentIndex++;

          if (currentPage != 3) {
            scrollController.jumpTo(0); //reset Scrolling on Form change
          }
          pickedLocalImages = pickedLocalImages;
          setState(() {});
        } else {
          final List<WorkingDay> workingDays = [];
          for (int i = 0; i < daysInWeek.length; i++) {
            workingDays.add(
              WorkingDay(
                isOpen: isChecked[i] ? 1 : 0,
                endTime:
                    "${selectedEndTime[i].hour.toString().padLeft(2, "0")}:${selectedEndTime[i].minute.toString().padLeft(2, "0")}:00",
                startTime:
                    "${selectedStartTime[i].hour.toString().padLeft(2, "0")}:${selectedStartTime[i].minute.toString().padLeft(2, "0")}:00",
                day: daysInWeek[i],
              ),
            );
          }

          // Get multi-language data before creating provider details (following manageService pattern)
          final Map<String, String> formCompanyNames = getCompanyNameData();
          final Map<String, String> formAboutProvider = getAboutCompanyData();
          final Map<String, String> formLongDescriptions =
              getLongDescriptionData();
          final Map<String, String> formUserNames = getUserNameData();

          // Create the translated_fields structure (following manageService pattern)
          final Map<String, dynamic> translatedFields = {
            'company_name': formCompanyNames,
            'about_provider': formAboutProvider,
            'long_description': formLongDescriptions,
            'username': formUserNames,
          };

          final ProviderDetails editProviderDetails = ProviderDetails(
            workingDays: workingDays,
            user: UserDetails(
              id: providerData?.user?.id,
              // username: removed - now handled through translatedFields
              email: emailController.text.trim(),
              phone: providerData?.user?.phone,
              countryCode: providerData?.user?.countryCode,
              company: companyNameController.text.trim(),
              image: pickedLocalImages['logoImage'],
            ),
            deletedOtherImages: deletedPreviouslyAddedImages,
            providerInformation: ProviderInformation(
              type: selectCompanyType?['value'],
              // companyName: removed - now handled through translatedFields
              visitingCharges: visitingChargesController.text.trim(),
              advanceBookingDays: advanceBookingDaysController.text.trim(),
              // about: removed - now handled through translatedFields
              numberOfMembers: numberOfMemberController.text.trim(),
              banner: pickedLocalImages['bannerImage'],
              nationalId: pickedLocalImages['nationalIdImage'],
              passport: pickedLocalImages['passportIdImage'],
              addressId: pickedLocalImages['addressIdImage'],
              otherImages: selectedOtherImages.value,
              // longDescription: removed - now handled through translatedFields
              isPostBookingChatAllowed: isPostBookingChatAllowed,
              isPreBookingChatAllowed: isPreBookingChatAllowed,
              atDoorstep: atDoorstepAllowed,
              atStore: atStore,
              // SEO fields
              seoTitle: seoTitleController.text.trim(),
              seoDescription: seoDescriptionController.text.trim(),
              seoKeywords: seoKeywordsController.text.trim(),
              seoSchemaMarkup: seoSchemaMarkupController.text.trim(),
              seoOgImage: pickedLocalImages['seoOgImage'],
              // Pass single translated_fields structure (following manageService pattern)
              translatedFields: translatedFields,
            ),
            bankInformation: BankInformation(
              accountName: accountNameController.text.trim(),
              accountNumber: accountNumberController.text.trim(),
              bankCode: bankCodeController.text.trim(),
              bankName: bankNameController.text.trim(),
              taxName: taxNameController.text.trim(),
              taxNumber: taxNumberController.text.trim(),
              swiftCode: swiftCodeController.text.trim(),
            ),
            locationInformation: LocationInformation(
              longitude: longitudeController.text.trim(),
              latitude: latitudeController.text.trim(),
              address: addressController.text.trim(),
              city: cityController.text.trim(),
            ),
          );

          if (context.read<FetchSystemSettingsCubit>().isDemoModeEnable &&
              widget.isEditing) {
            UiUtils.showDemoModeWarning(context: context);
            return;
          }

          context.read<EditProviderDetailsCubit>().editProviderDetails(
            providerDetails: editProviderDetails,
          );
        }
      }
    } else if (currentPage > 1) {
      // Save current form data before going back (previous button)
      await _saveCurrentFormData();
      currentIndex--;
      pickedLocalImages = pickedLocalImages;
      setState(() {});
    }
  }

  Widget screenBuilder(int currentPage) {
    Widget currentForm;
    switch (currentPage) {
      case 1:
        currentForm = PersonalInfo(
          formKey: formKey1,
          userNameController: userNameController,
          emailController: emailController,
          mobileNumberController: mobileNumberController,
          pickNationalIdImage: pickNationalIdImage,
          pickAddressProofImage: pickAddressProofImage,
          pickPassportImage: pickPassportImage,
          userNmFocus: userNmFocus,
          emailFocus: emailFocus,
          mobNoFocus: mobNoFocus,
          pickedLocalImages: pickedLocalImages,
          atStore: atStore,
          atDoorstepAllowed: atDoorstepAllowed,
          isPreBookingChatAllowed: isPreBookingChatAllowed,
          isPostBookingChatAllowed: isPostBookingChatAllowed,
          onAtStoreChanged: (value) {
            setState(() {
              atStore = value;
            });
          },
          onAtDoorstepChanged: (value) {
            setState(() {
              atDoorstepAllowed = value;
            });
          },
          onPreBookingChatChanged: (value) {
            setState(() {
              isPreBookingChatAllowed = value;
            });
          },
          onPostBookingChatChanged: (value) {
            setState(() {
              isPostBookingChatAllowed = value;
            });
          },
          showCameraAndGalleryOption:
              ({required PickImage imageController, required String title}) {
                return showCameraAndGalleryOption(
                  imageController: imageController,
                  title: title,
                );
              },
          // Multi-language support for username
          languages: languages.isNotEmpty ? languages : null,
          defaultLanguage: defaultLanguage,
          selectedLanguageIndex: selectedLanguageIndex,
          onLanguageChanged: _onLanguageChanged,
          userNameControllers: userNameControllers.isNotEmpty
              ? userNameControllers
              : null,
          getUserNameValidator: _getUserNameValidator,
        );
        break;
      case 2:
        currentForm = Form2CompanyInfo(
          key: form2CompanyInfoKey,
          formKey: formKey2,
          companyNameController: companyNameController,
          visitingChargesController: visitingChargesController,
          advanceBookingDaysController: advanceBookingDaysController,
          aboutCompanyController: aboutCompanyController,
          numberOfMemberController: numberOfMemberController,
          pickLogoImage: pickLogoImage,
          pickBannerImage: pickBannerImage,
          companyNmFocus: companyNmFocus,
          visitingChargeFocus: visitingChargeFocus,
          advanceBookingDaysFocus: advanceBookingDaysFocus,
          aboutCompanyFocus: aboutCompanyFocus,
          numberOfMemberFocus: numberOfMemberFocus,
          selectCompanyType: selectCompanyType,
          isIndividualType: isIndividualType,
          pickedLocalImages: pickedLocalImages,
          selectedOtherImages: selectedOtherImages,
          previouslyAddedOtherImages: previouslyAddedOtherImages,
          selectCompanyTypes: selectCompanyTypes,
          showCameraAndGalleryOption:
              ({required PickImage imageController, required String title}) {
                return showCameraAndGalleryOption(
                  imageController: imageController,
                  title: title,
                );
              },
          onPreviousImageDeleted: (deletedImage) {
            deletedPreviouslyAddedImages.add(deletedImage);
          },
          // Multi-language support for company name, about, and description
          languages: languages,
          defaultLanguage: defaultLanguage,
          selectedLanguageIndex: selectedLanguageIndex,
          onLanguageChanged: _onLanguageChanged,
          companyNameControllers: companyNameControllers,
          aboutCompanyControllers: aboutCompanyControllers,
          descriptionControllers: longDescriptionControllers,
          getCompanyNameValidator: _getCompanyNameValidator,
          getAboutCompanyValidator: _getAboutCompanyValidator,
          getDescriptionValidator: _getLongDescriptionValidator,
        );
        break;
      case 3:
        currentForm = Form3Description(
          htmlController: htmlController,
          initialHTML: longDescription,
          // Multi-language support
          languages: languages,
          defaultLanguage: defaultLanguage,
          selectedLanguageIndex: selectedLanguageIndex,
          onLanguageChanged: _onLanguageChanged,
          longDescriptionControllers: longDescriptionControllers,
        );
        break;
      case 4:
        currentForm = SEO(
          formKey: formKey4,
          seoTitleController: seoTitleController,
          seoDescriptionController: seoDescriptionController,
          seoKeywordsController: seoKeywordsController,
          seoSchemaMarkupController: seoSchemaMarkupController,
          pickSeoOgImage: pickSeoOgImage,
          seoTitleFocus: seoTitleFocus,
          seoDescriptionFocus: seoDescriptionFocus,
          seoKeywordsFocus: seoKeywordsFocus,
          seoSchemaMarkupFocus: seoSchemaMarkupFocus,
          pickedLocalImages: pickedLocalImages,
          showCameraAndGalleryOption:
              ({required PickImage imageController, required String title}) {
                return showCameraAndGalleryOption(
                  imageController: imageController,
                  title: title,
                );
              },
        );
        break;
      case 5:
        currentForm = Form5WorkingDays(
          formKey: formKey5,
          isChecked: isChecked,
          selectedStartTime: selectedStartTime,
          selectedEndTime: selectedEndTime,
          daysOfWeek: daysOfWeek,
          onTimeSelected: (selectedTime, index, isStartTime) {
            _selectTime(
              selectedTime: selectedTime,
              indexVal: index,
              isTimePickerForStarTime: isStartTime,
            );
          },
          onDayToggled: (index, newValue) {
            setState(() {
              pickedLocalImages = pickedLocalImages;
              isChecked[index] = newValue;
            });
          },
        );
        break;
      case 6:
        currentForm = Form6BankInfo(
          formKey: formKey6,
          bankNameController: bankNameController,
          bankCodeController: bankCodeController,
          accountNameController: accountNameController,
          accountNumberController: accountNumberController,
          swiftCodeController: swiftCodeController,
          taxNameController: taxNameController,
          taxNumberController: taxNumberController,
          bankNameFocus: bankNameFocus,
          bankCodeFocus: bankCodeFocus,
          accountNameFocus: accountNameFocus,
          accountNumberFocus: accountNumberFocus,
          swiftCodeFocus: swiftCodeFocus,
          taxNameFocus: taxNameFocus,
          taxNumberFocus: taxNumberFocus,
        );
        break;
      case 7:
        currentForm = LocationInfo(
          formKey: formKey7,
          cityController: cityController,
          latitudeController: latitudeController,
          longitudeController: longitudeController,
          addressController: addressController,
          cityFocus: cityFocus,
          latitudeFocus: latitudeFocus,
          longitudeFocus: longitudeFocus,
          addressFocus: addressFocus,
        );
        break;
      default:
        currentForm = PersonalInfo(
          formKey: formKey1,
          userNameController: userNameController,
          emailController: emailController,
          mobileNumberController: mobileNumberController,
          pickNationalIdImage: pickNationalIdImage,
          pickAddressProofImage: pickAddressProofImage,
          pickPassportImage: pickPassportImage,
          userNmFocus: userNmFocus,
          emailFocus: emailFocus,
          mobNoFocus: mobNoFocus,
          pickedLocalImages: pickedLocalImages,
          atStore: atStore,
          atDoorstepAllowed: atDoorstepAllowed,
          isPreBookingChatAllowed: isPreBookingChatAllowed,
          isPostBookingChatAllowed: isPostBookingChatAllowed,
          onAtStoreChanged: (value) {
            setState(() {
              atStore = value;
            });
          },
          onAtDoorstepChanged: (value) {
            setState(() {
              atDoorstepAllowed = value;
            });
          },
          onPreBookingChatChanged: (value) {
            setState(() {
              isPreBookingChatAllowed = value;
            });
          },
          onPostBookingChatChanged: (value) {
            setState(() {
              isPostBookingChatAllowed = value;
            });
          },
          showCameraAndGalleryOption:
              ({required PickImage imageController, required String title}) {
                return showCameraAndGalleryOption(
                  imageController: imageController,
                  title: title,
                );
              },
          // Multi-language support for username
          languages: languages.isNotEmpty ? languages : null,
          defaultLanguage: defaultLanguage,
          selectedLanguageIndex: selectedLanguageIndex,
          onLanguageChanged: _onLanguageChanged,
          userNameControllers: userNameControllers.isNotEmpty
              ? userNameControllers
              : null,
          getUserNameValidator: _getUserNameValidator,
        );
        break;
    }
    return currentPage == 3
        ? currentForm
        : SingleChildScrollView(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(vertical: 10),
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: currentForm,
          );
  }

  Future<void> _selectTime({
    required TimeOfDay selectedTime,
    required int indexVal,
    required bool isTimePickerForStarTime,
  }) async {
    try {
      final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: selectedTime, //TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: context.colorScheme.accentColor,
                onPrimary: AppColors.whiteColors,
                surface: context.colorScheme.secondaryColor,
                onSurface: context.colorScheme.blackColor,
              ),
              timePickerTheme: TimePickerThemeData(
                dayPeriodColor: context.colorScheme.accentColor.withAlpha(50),
              ),
            ),
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: false),
              child: child!,
            ),
          );
        },
      );

      if (isTimePickerForStarTime) {
        // Convert times to minutes for easier comparison
        final int startTimeInMinutes = timeOfDay!.hour * 60 + timeOfDay.minute;
        final int endTimeInMinutes =
            selectedEndTime[indexVal].hour * 60 +
            selectedEndTime[indexVal].minute;

        // Check if start time is before end time
        if (startTimeInMinutes < endTimeInMinutes) {
          selectedStartTime[indexVal] = timeOfDay;
        } else if (mounted) {
          UiUtils.showMessage(
            context,
            'startTimeMustBeBeforeEndTime',
            ToastificationType.warning,
          );
        }
      } else {
        // Convert times to minutes for easier comparison
        final int startTimeInMinutes =
            selectedStartTime[indexVal].hour * 60 +
            selectedStartTime[indexVal].minute;
        final int endTimeInMinutes = timeOfDay!.hour * 60 + timeOfDay.minute;

        // Check if end time is after start time
        if (endTimeInMinutes > startTimeInMinutes) {
          selectedEndTime[indexVal] = timeOfDay;
        } else if (mounted) {
          UiUtils.showMessage(
            context,
            'endTimeMustBeAfterStartTime',
            ToastificationType.warning,
          );
        }
      }
    } catch (_) {}

    setState(() {
      pickedLocalImages = pickedLocalImages;
    });
  }

  Widget idImageWidget({
    required String titleTxt,
    required String imageHintText,
    required PickImage imageController,
    required String imageType,
    required String oldImage,
  }) {
    return CustomContainer(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width / 1.4,
      color: context.colorScheme.secondaryColor,
      borderRadius: UiUtils.borderRadiusOf10,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(titleTxt, fontSize: 16, fontWeight: FontWeight.w500),
              const SizedBox(height: 5),
              pickedLocalImages[imageType] != ''
                  ? CustomText(
                      pickedLocalImages[imageType].split('/').last,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      maxLines: 1,
                      color: context.colorScheme.lightGreyColor,
                    )
                  : oldImage != 'null'
                  ? CustomText(
                      oldImage.split('/').last,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      maxLines: 1,
                      color: context.colorScheme.lightGreyColor,
                    )
                  : const SizedBox(height: 12),
              const SizedBox(height: 5),
              imagePicker(
                imageType: imageType,
                imageController: imageController,
                oldImage: oldImage,
                hintLabel: imageHintText,
                width: MediaQuery.of(context).size.width / 1.5,
                onImagePicked: (newImage) {
                  setState(() {
                    pickedLocalImages[imageType] = newImage;
                  });
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget bennerPicker({
    required PickImage imageController,
    required String oldImage,
    required String hintLabel,
    required String imageType,
  }) {
    return imageController.ListenImageChange((BuildContext context, image) {
      if (image == null) {
        if (pickedLocalImages[imageType] != '') {
          return GestureDetector(
            onTap: () {
              showCameraAndGalleryOption(
                imageController: imageController,
                title: hintLabel,
              );
            },
            child: Center(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(UiUtils.borderRadiusOf10),
                ),
                child: Image.file(
                  File(pickedLocalImages[imageType]!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }

        if (oldImage.isNotEmpty) {
          return GestureDetector(
            onTap: () {
              showCameraAndGalleryOption(
                imageController: imageController,
                title: hintLabel,
              );
            },
            child: Center(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(UiUtils.borderRadiusOf10),
                ),
                child: CustomCachedNetworkImage(
                  imageUrl: oldImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }

        return CustomInkWellContainer(
          onTap: () {
            showCameraAndGalleryOption(
              imageController: imageController,
              title: hintLabel,
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomSvgPicture(
                svgImage: AppAssets.camera,
                color: context.colorScheme.accentColor,
                height: 20,
                width: 20,
              ),
              const SizedBox(height: 10),
              CustomText(
                'uploadBannerImage'.translate(context: context),
                color: context.colorScheme.accentColor,
                fontSize: 12,
              ),
            ],
          ),
        );
      }

      pickedLocalImages[imageType] = image?.path;

      return GestureDetector(
        onTap: () {
          showCameraAndGalleryOption(
            imageController: imageController,
            title: hintLabel,
          );
        },
        child: Center(
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(UiUtils.borderRadiusOf10),
            ),
            child: Image.file(File(image.path), fit: BoxFit.cover),
          ),
        ),
      );
    });
  }

  Widget logoPicker({
    required PickImage imageController,
    required String oldImage,
    required String hintLabel,
    required String imageType,
  }) {
    return imageController.ListenImageChange((BuildContext context, image) {
      if (image == null) {
        if (pickedLocalImages[imageType] != '') {
          return GestureDetector(
            onTap: () {
              showCameraAndGalleryOption(
                imageController: imageController,
                title: hintLabel,
              );
            },
            child: Center(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(UiUtils.borderRadiusOf50),
                ),
                child: Image.file(
                  File(pickedLocalImages[imageType]!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }

        if (oldImage.isNotEmpty) {
          return GestureDetector(
            onTap: () {
              showCameraAndGalleryOption(
                imageController: imageController,
                title: hintLabel,
              );
            },
            child: Center(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(UiUtils.borderRadiusOf50),
                ),
                child: CustomCachedNetworkImage(
                  imageUrl: oldImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }

        return CustomInkWellContainer(
          onTap: () {
            showCameraAndGalleryOption(
              imageController: imageController,
              title: hintLabel,
            );
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomSvgPicture(
                  svgImage: AppAssets.camera,
                  color: context.colorScheme.accentColor,
                  height: 20,
                  width: 20,
                ),
                CustomText(
                  "logoLbl".translate(context: context),
                  color: context.colorScheme.accentColor,
                  fontSize: 12,
                ),
              ],
            ),
          ),
        );
      }

      pickedLocalImages[imageType] = image?.path;

      return GestureDetector(
        onTap: () {
          showCameraAndGalleryOption(
            imageController: imageController,
            title: hintLabel,
          );
        },
        child: Center(
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(UiUtils.borderRadiusOf50),
            ),
            child: Image.file(File(image.path), fit: BoxFit.cover),
          ),
        ),
      );
    });
  }

  Widget imagePicker({
    required PickImage imageController,
    required String oldImage,
    required String hintLabel,
    required String imageType,
    double? width,
    required void Function(String newImagePath) onImagePicked,
  }) {
    return imageController.ListenImageChange((BuildContext context, image) {
      if (image == null) {
        if (pickedLocalImages[imageType] != '') {
          return GestureDetector(
            onTap: () {
              showCameraAndGalleryOption(
                imageController: imageController,
                title: hintLabel,
              ).then((_) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onImagePicked(pickedLocalImages[imageType]!);
                });
              });
            },
            child: CustomContainer(
              color: context.colorScheme.accentColor.withAlpha(20),
              borderRadius: UiUtils.borderRadiusOf10,
              height: 100,
              width: (width ?? MediaQuery.sizeOf(context).width) - 5.0,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(UiUtils.borderRadiusOf10),
                ),
                child: Image.file(
                  File(pickedLocalImages[imageType]!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }

        if (oldImage.isNotEmpty) {
          return GestureDetector(
            onTap: () {
              showCameraAndGalleryOption(
                imageController: imageController,
                title: hintLabel,
              ).then((_) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onImagePicked(pickedLocalImages[imageType]!);
                });
              });
            },
            child: Stack(
              children: [
                CustomContainer(
                  borderRadius: UiUtils.borderRadiusOf10,
                  height: 100,
                  width: (width ?? MediaQuery.sizeOf(context).width) - 5.0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(UiUtils.borderRadiusOf10),
                    ),
                    child: CustomCachedNetworkImage(
                      imageUrl: oldImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                CustomContainer(
                  borderRadius: UiUtils.borderRadiusOf10,
                  color: context.colorScheme.lightGreyColor.withAlpha(40),
                  height: 100,
                  width: (width ?? MediaQuery.sizeOf(context).width) - 5.0,
                  child: Center(
                    child: CustomSvgPicture(
                      svgImage: AppAssets.edit,
                      color: AppColors.whiteColors,
                      height: 25,
                      width: 25,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return CustomInkWellContainer(
          onTap: () {
            showCameraAndGalleryOption(
              imageController: imageController,
              title: hintLabel,
            ).then((_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onImagePicked(pickedLocalImages[imageType]!);
              });
            });
          },
          child: CustomContainer(
            borderRadius: UiUtils.borderRadiusOf10,
            color: context.colorScheme.accentColor.withAlpha(20),
            height: 100,
            width: (width ?? MediaQuery.sizeOf(context).width) - 5.0,
            child: Center(
              child: CustomSvgPicture(
                svgImage: AppAssets.addCircle,
                color: context.colorScheme.accentColor,
                height: 50,
                width: 50,
              ),
            ),
          ),
        );
      }

      pickedLocalImages[imageType] = image?.path;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onImagePicked(image!.path);
      });

      return GestureDetector(
        onTap: () {
          showCameraAndGalleryOption(
            imageController: imageController,
            title: hintLabel,
          ).then((_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onImagePicked(image.path);
            });
          });
        },
        child: CustomContainer(
          borderRadius: UiUtils.borderRadiusOf10,
          height: 100,
          width: (width ?? MediaQuery.sizeOf(context).width) - 5.0,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(UiUtils.borderRadiusOf10),
            ),
            child: Image.file(File(image.path), fit: BoxFit.cover),
          ),
        ),
      );
    });
  }

  Widget buildDropDown(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
    required String initialValue,
    String? value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title,
          color: Theme.of(context).colorScheme.blackColor,
          fontWeight: FontWeight.w400,
        ),
        const SizedBox(height: 10),
        CustomFormDropdown(
          onTap: () {
            onTap.call();
          },
          initialTitle: initialValue,
          selectedValue: value,
          validator: (String? p0) {
            return Validator.nullCheck(context, p0);
          },
        ),
      ],
    );
  }

  Future showCameraAndGalleryOption({
    required PickImage imageController,
    required String title,
  }) {
    return UiUtils.showModelBottomSheets(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      context: context,
      child: ShowImagePickerOptionBottomSheet(
        title: title,
        onCameraButtonClick: () {
          imageController.pick(source: ImageSource.camera);
        },
        onGalleryButtonClick: () {
          imageController.pick(source: ImageSource.gallery);
        },
      ),
    );
  }

  Future<void> selectCompanyTypes() async {
    final List<Map<String, dynamic>> itemList = [
      {
        'title': 'Individual'.translate(context: context),
        'id': '0',
        "isSelected": selectCompanyType?['value'] == "0",
      },
      {
        'title': 'Organisation'.translate(context: context),
        'id': '1',
        "isSelected": selectCompanyType?['value'] == "1",
      },
    ];
    UiUtils.showModelBottomSheets(
      context: context,
      child: SelectableListBottomSheet(
        bottomSheetTitle: "selectType",
        itemList: itemList,
      ),
    ).then((value) {
      if (value != null) {
        selectCompanyType = {
          'title': value["selectedItemName"],
          'value': value["selectedItemId"],
        };

        if (value?['selectedItemName'] == 'Individual') {
          numberOfMemberController.text = '1';
          isIndividualType = true;
        } else {
          isIndividualType = false;
        }
        setState(() {
          pickedLocalImages = pickedLocalImages;
        });
      }
    });
  }
}
