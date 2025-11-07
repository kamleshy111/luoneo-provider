import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

import '../../../app/generalImports.dart';
import 'forms/details.dart';
import 'forms/media.dart';
import 'forms/seo.dart';
import 'forms/faqs.dart';
import 'forms/description.dart';

class ManageService extends StatefulWidget {
  const ManageService({super.key, this.service});

  final ServiceModel? service;

  @override
  ManageServiceState createState() => ManageServiceState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final Map? arguments = routeSettings.arguments as Map?;

    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (BuildContext context) => CreateServiceCubit(),
        child: ManageService(service: arguments?['service']),
      ),
    );
  }
}

class ManageServiceState extends State<ManageService> {
  int currIndex = 1;
  int totalForms = 5;

  //form 1
  bool isOnSiteAllowed = false;
  bool isPayLaterAllowed = true;
  bool isCancelAllowed = false;
  bool isDoorStepAllowed = false;
  bool isStoreAllowed = false;
  bool serviceStatus = true;

  // Multi-language support
  List<AppLanguage> languages = [];
  AppLanguage? defaultLanguage;
  int selectedLanguageIndex = 0;
  StreamSubscription? _languageListSubscription;
  Map<String, TextEditingController> titleControllers = {};
  Map<String, TextEditingController> descriptionControllers = {};
  Map<String, TextEditingController> tagsControllers = {};
  Map<String, TextEditingController> longDescriptionControllers = {};
  Map<String, List<TextEditingController>> faqQuestionControllers = {};
  Map<String, List<TextEditingController>> faqAnswerControllers = {};

  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();
  final GlobalKey<Form1State> form1StateKey = GlobalKey<Form1State>();

  late List<String> _participant = [
    "details",
    "media",
    "seo",
    "faqs",
    "descriptionLbl",
  ];

  ScrollController scrollController = ScrollController();

  late TextEditingController serviceTitleController = TextEditingController();
  late TextEditingController surviceSlugController = TextEditingController(
    text: widget.service?.slug,
  );
  late TextEditingController serviceTagController = TextEditingController();
  late TextEditingController serviceDescrController = TextEditingController();

  late TextEditingController cancelBeforeController = TextEditingController(
    text: widget.service?.cancelableTill,
  );
  FocusNode serviceTitleFocus = FocusNode();
  FocusNode serviceSlugFocus = FocusNode();
  FocusNode serviceTagFocus = FocusNode();
  FocusNode serviceDescrFocus = FocusNode();

  FocusNode cancelBeforeFocus = FocusNode();

  late int selectedCategory = 0;
  String? selectedCategoryTitle;
  late int selectedTax = 0;
  String selectedTaxTitle = '';
  late int selectedSubCategory = 0;
  Map? selectedPriceType;

  //form 2
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();

  late TextEditingController priceController = TextEditingController(
    text: widget.service?.price,
  );
  late TextEditingController discountPriceController = TextEditingController(
    text: widget.service?.discountedPrice,
  );
  late TextEditingController memReqTaskController = TextEditingController(
    text: widget.service?.numberOfMembersRequired,
  );
  late TextEditingController durationTaskController = TextEditingController(
    text: widget.service?.duration,
  );
  late TextEditingController qtyAllowedTaskController = TextEditingController(
    text: widget.service?.maxQuantityAllowed,
  );

  FocusNode priceFocus = FocusNode();
  FocusNode discountPriceFocus = FocusNode();
  FocusNode memReqTaskFocus = FocusNode();
  FocusNode durationTaskFocus = FocusNode();
  FocusNode qtyAllowedTaskFocus = FocusNode();

  List<String> tagsList = [];
  List<Map<String, dynamic>> finalTagList = [];
  PickImage imagePicker = PickImage();

  void _addTag(String tag) {
    setState(() {
      tagsList.add(tag);
      _updateFinalTagList();
      // Update the serviceTagController with current tags
      serviceTagController.text = tagsList.join(', ');
    });
  }

  void _removeTag(int index) {
    setState(() {
      if (tagsList.isNotEmpty) {
        tagsList.removeAt(index);
        _updateFinalTagList();
        // Update the serviceTagController with current tags
        serviceTagController.text = tagsList.join(', ');
      }
    });
  }

  void _updateFinalTagList() {
    finalTagList.clear();
    for (int i = 0; i < tagsList.length; i++) {
      finalTagList.add({'id': i, 'text': tagsList[i]});
    }
  }

  //SEO form
  final GlobalKey<FormState> formKeySEO = GlobalKey<FormState>();
  late TextEditingController seoTitleController = TextEditingController(
    text: widget.service?.seoTitle,
  );
  late TextEditingController seoDescriptionController = TextEditingController(
    text: widget.service?.seoDescription,
  );
  late TextEditingController seoKeywordsController = TextEditingController(
    text: widget.service?.seoKeywords,
  );
  late TextEditingController seoSchemaMarkupController = TextEditingController(
    text: widget.service?.seoSchemaMarkup,
  );

  FocusNode seoTitleFocus = FocusNode();
  FocusNode seoDescriptionFocus = FocusNode();
  FocusNode seoKeywordsFocus = FocusNode();
  FocusNode seoSchemaMarkupFocus = FocusNode();

  PickImage pickSeoOgImage = PickImage();
  String pickedSeoOgImagePath = '';
  Map<String, dynamic> pickedLocalImages = {'seoOgImage': ''};

  Map priceTypeFilter = {'0': 'included', '1': 'excluded'};
  String pickedServiceImage = '';

  bool fileTapLoading = false;

  final GlobalKey<FormState> formKey3 = GlobalKey<FormState>();
  final GlobalKey<Form3State> form3StateKey = GlobalKey<Form3State>();
  final GlobalKey<Form4State> form4StateKey = GlobalKey<Form4State>();
  ValueNotifier<List<TextEditingController>> faqQuestionTextEditors =
      ValueNotifier([]);
  ValueNotifier<List<TextEditingController>> faqAnswersTextEditors =
      ValueNotifier([]);

  final HtmlEditorController controller = HtmlEditorController();
  String? longDescription;

  ValueNotifier<List<String>> selectedOtherImages = ValueNotifier([]);
  ValueNotifier<List<String>> previouslyAddedOtherImages = ValueNotifier([]);
  Set<String> deletedPreviouslyAddedImages = {};

  ValueNotifier<List<String>> selectedFiles = ValueNotifier([]);
  ValueNotifier<List<String>> previouslyAddedFiles = ValueNotifier([]);
  Set<String> deletedPreviouslyAddedFiles = {};

  @override
  void dispose() {
    // Cancel stream subscription to prevent memory leaks
    _languageListSubscription?.cancel();

    selectedOtherImages.dispose();
    previouslyAddedOtherImages.dispose();
    selectedFiles.dispose();
    previouslyAddedFiles.dispose();
    faqAnswersTextEditors.dispose();
    faqQuestionTextEditors.dispose();
    serviceTitleController.dispose();
    surviceSlugController.dispose();
    serviceTagController.dispose();
    serviceDescrController.dispose();
    cancelBeforeController.dispose();
    serviceTitleFocus.dispose();
    serviceSlugFocus.dispose();
    serviceTagFocus.dispose();
    serviceDescrFocus.dispose();
    cancelBeforeFocus.dispose();
    priceController.dispose();
    discountPriceController.dispose();
    memReqTaskController.dispose();
    durationTaskController.dispose();
    qtyAllowedTaskController.dispose();
    priceFocus.dispose();
    discountPriceFocus.dispose();
    memReqTaskFocus.dispose();
    durationTaskFocus.dispose();
    qtyAllowedTaskFocus.dispose();
    seoTitleController.dispose();
    seoDescriptionController.dispose();
    seoKeywordsController.dispose();
    seoSchemaMarkupController.dispose();
    seoTitleFocus.dispose();
    seoDescriptionFocus.dispose();
    seoKeywordsFocus.dispose();
    seoSchemaMarkupFocus.dispose();
    pickSeoOgImage.dispose();
    super.dispose();
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

        // Process service data after controllers are initialized
        if (widget.service != null) {
          _processServiceData();
        }

        // Populate translated controllers after processing service data
        _populateTranslatedControllers();

        // Notify Form1 to refresh its data with translated content
        _refreshForm1WithTranslatedData();

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

  void _initializeEmptyControllers() {
    // Initialize with empty maps to prevent late initialization errors
    titleControllers = {};
    descriptionControllers = {};
    tagsControllers = {};
    longDescriptionControllers = {};
    faqQuestionControllers = {};
    faqAnswerControllers = {};
  }

  void _initializeControllers() {
    // Clear existing controllers
    titleControllers.clear();
    descriptionControllers.clear();
    tagsControllers.clear();
    longDescriptionControllers.clear();
    faqQuestionControllers.clear();
    faqAnswerControllers.clear();

    for (var lang in languages) {
      final String code = lang.languageCode;

      // Initialize title controllers
      titleControllers[code] = TextEditingController(
        text: code == defaultLanguage?.languageCode
            ? serviceTitleController.text
            : '',
      );

      // Initialize description controllers
      descriptionControllers[code] = TextEditingController(
        text: code == defaultLanguage?.languageCode
            ? serviceDescrController.text
            : '',
      );

      // Initialize tags controllers
      tagsControllers[code] = TextEditingController(
        text: code == defaultLanguage?.languageCode
            ? serviceTagController.text
            : '',
      );

      // Initialize long description controllers
      longDescriptionControllers[code] = TextEditingController(
        text: code == defaultLanguage?.languageCode
            ? (longDescription ?? '')
            : '',
      );

      // Initialize FAQ controllers
      faqQuestionControllers[code] = [];
      faqAnswerControllers[code] = [];
    }

    // Note: Translated data will be populated separately after service data processing
  }

  void _processServiceData() {
    if (widget.service == null) return;

    // Process basic service data
    serviceTitleController.text = widget.service?.title ?? '';
    serviceDescrController.text = widget.service?.description ?? '';
    serviceTagController.text = widget.service?.tags ?? '';
    surviceSlugController.text = widget.service?.slug ?? '';
    cancelBeforeController.text = widget.service?.cancelableTill ?? '';
    longDescription = widget.service?.longDescription ?? '';

    if (widget.service?.isPayLaterAllowed != null) {
      isPayLaterAllowed = widget.service?.isPayLaterAllowed == '0'
          ? false
          : true;
    }
    if (widget.service?.isDoorStepAllowed != null) {
      isDoorStepAllowed = widget.service?.isDoorStepAllowed == '0'
          ? false
          : true;
    }
    if (widget.service?.isCancelable != null) {
      isCancelAllowed = widget.service?.isCancelable == '0' ? false : true;
    }
    if (widget.service?.isStoreAllowed != null) {
      isStoreAllowed = widget.service?.isStoreAllowed == '0' ? false : true;
    }
    if (widget.service?.status != null || widget.service?.status != '') {
      serviceStatus = widget.service?.status == "deactive" ? false : true;
    }

    // Get tags for all languages from translatedFields
    if (languages.isNotEmpty) {
      // Initialize tags for all languages
      for (final language in languages) {
        final langCode = language.languageCode;
        final langTags = widget.service!.getTranslatedTags(langCode);
        if (langTags?.isNotEmpty == true) {
          // Update tags controller for this language
          tagsControllers[langCode]?.text = langTags!;
        }
      }

      // Set current language tags for main widget
      final currentLangCode = languages[selectedLanguageIndex].languageCode;
      final currentTags = widget.service!.getTranslatedTags(currentLangCode);
      if (currentTags?.isEmpty ?? true) {
        tagsList = [];
      } else {
        // Split comma-separated tags
        tagsList = currentTags!
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();
      }
    } else {
      tagsList = [];
    }
    _updateFinalTagList();

    // Refresh Form1 to update tag chips before clearing controllers
    _refreshForm1WithTranslatedData();

    // Don't clear tags controllers - they are needed for language-wise tag display
    // Tags controllers should retain their values for proper autofilling in different languages

    // Get current language long description from translatedFields
    if (languages.isNotEmpty) {
      final currentLangCode = languages[selectedLanguageIndex].languageCode;
      final currentLongDesc = widget.service!.getTranslatedLongDescription(
        currentLangCode,
      );
      if (currentLongDesc != null) {
        longDescription = currentLongDesc;
      }
    }

    if (faqQuestionTextEditors.value.isEmpty ||
        faqAnswersTextEditors.value.isEmpty) {
      faqQuestionTextEditors.value.add(TextEditingController());
      faqAnswersTextEditors.value.add(TextEditingController());
    }

    previouslyAddedOtherImages.value = [...?widget.service?.otherImages];
    previouslyAddedFiles.value = [...?widget.service?.files];
  }

  void _populateTranslatedControllers() {
    if (languages.isEmpty) return;

    // Populate title controllers
    if (widget.service?.translatedFields?['title'] != null) {
      for (var lang in languages) {
        final String code = lang.languageCode;
        final translatedValue =
            widget.service?.translatedFields?['title']?[code];
        if (translatedValue != null) {
          titleControllers[code]?.text = translatedValue;
        }
      }
    }

    // Populate description controllers
    if (widget.service?.translatedFields?['description'] != null) {
      for (var lang in languages) {
        final String code = lang.languageCode;
        final translatedValue =
            widget.service?.translatedFields?['description']?[code];
        if (translatedValue != null) {
          descriptionControllers[code]?.text = translatedValue;
        }
      }
    }

    // Populate tags controllers
    if (widget.service?.translatedFields?['tags'] != null) {
      for (var lang in languages) {
        final String code = lang.languageCode;
        final translatedValue =
            widget.service?.translatedFields?['tags']?[code];
        if (translatedValue != null) {
          if (translatedValue is List) {
            tagsControllers[code]?.text = translatedValue.join(',');
          } else {
            tagsControllers[code]?.text = translatedValue.toString();
          }
        }
      }
    } else {}

    // Refresh Form1 to update tag chips before clearing controllers
    _refreshForm1WithTranslatedData();

    // Don't clear tags controllers - they are needed for language-wise tag display
    // Tags controllers should retain their values for proper autofilling in different languages

    // Populate long description controllers
    if (widget.service?.translatedFields?['long_description'] != null) {
      for (var lang in languages) {
        final String code = lang.languageCode;
        final translatedValue =
            widget.service?.translatedFields?['long_description']?[code];
        if (translatedValue != null) {
          longDescriptionControllers[code]?.text = translatedValue;
        }
      }
    }

    // Populate FAQ controllers
    if (widget.service?.translatedFields?['faqs'] != null) {
      for (var lang in languages) {
        final String code = lang.languageCode;
        final faqData = widget.service?.translatedFields?['faqs']?[code];
        if (faqData is List && faqData.isNotEmpty) {
          faqQuestionControllers[code] = [];
          faqAnswerControllers[code] = [];

          for (final faq in faqData) {
            faqQuestionControllers[code]!.add(
              TextEditingController(text: faq['question']?.toString() ?? ''),
            );
            faqAnswerControllers[code]!.add(
              TextEditingController(text: faq['answer']?.toString() ?? ''),
            );
          }
        }
      }
    } else if (widget.service?.faqs != null &&
        widget.service!.faqs!.isNotEmpty) {
      // Fallback: If no translated FAQs but service has FAQs, populate default language
      final defaultLangCode = languages.isNotEmpty
          ? languages[0].languageCode
          : 'en';
      faqQuestionControllers[defaultLangCode] = [];
      faqAnswerControllers[defaultLangCode] = [];

      for (final faq in widget.service!.faqs!) {
        faqQuestionControllers[defaultLangCode]!.add(
          TextEditingController(text: faq.question ?? ''),
        );
        faqAnswerControllers[defaultLangCode]!.add(
          TextEditingController(text: faq.answer ?? ''),
        );
      }
    }

    // Sync FAQ data to main widget controllers for default language
    _syncFaqDataToMainControllers();
  }

  // Method to sync FAQ data to main widget controllers
  void _syncFaqDataToMainControllers() {
    if (languages.isEmpty) return;

    final defaultLangCode = languages[0].languageCode;
    final defaultQuestions = faqQuestionControllers[defaultLangCode] ?? [];
    final defaultAnswers = faqAnswerControllers[defaultLangCode] ?? [];

    // Clear existing main widget controllers
    faqQuestionTextEditors.value.clear();
    faqAnswersTextEditors.value.clear();

    // Add FAQ data to main widget controllers
    for (
      int i = 0;
      i < defaultQuestions.length && i < defaultAnswers.length;
      i++
    ) {
      faqQuestionTextEditors.value.add(
        TextEditingController(text: defaultQuestions[i].text),
      );
      faqAnswersTextEditors.value.add(
        TextEditingController(text: defaultAnswers[i].text),
      );
    }
  }

  // Method to refresh Form1 with translated data
  void _refreshForm1WithTranslatedData() {
    if (form1StateKey.currentState != null) {
      try {
        // Refresh Form1's data from parent's controllers
        form1StateKey.currentState!.refreshFromParentControllers();
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  // Method to set HTML editor text with simple retry
  void _setHtmlEditorTextWithRetry(String text) {
    // Wait a bit longer for HTML editor to be ready
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        controller.setText(text);
      } catch (e) {
        Future.delayed(const Duration(seconds: 2), () {
          try {
            controller.setText(text);
            // ignore: empty_catches
          } catch (e) {}
        });
      }
    });
  }

  // Method to clear HTML editor with simple retry
  void _clearHtmlEditorWithRetry() {
    // Wait a bit longer for HTML editor to be ready
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        controller.clear();
      } catch (e) {
        Future.delayed(const Duration(seconds: 2), () {
          try {
            controller.clear();
            // ignore: empty_catches
          } catch (e) {}
        });
      }
    });
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
      if (currIndex == 1) {
        // Service details form
        if (!_areServiceRequiredFieldsFilled()) {
          UiUtils.showMessage(
            context,
            'pleaseCompleteDefaultLanguageFieldsFirst',
            ToastificationType.warning,
          );
          return false;
        }
      }
      // Note: Other forms are optional, so no validation needed
    }

    return true;
  }

  // Check if service required fields are filled in default language
  bool _areServiceRequiredFieldsFilled() {
    // Check required service fields
    final hasTitle = serviceTitleController.text.trim().isNotEmpty;
    final hasDescription = serviceDescrController.text.trim().isNotEmpty;
    final hasCategory = selectedCategory > 0;

    return hasTitle && hasDescription && hasCategory;
  }

  // Check if long description is filled in default language
  bool _isDefaultLanguageLongDescriptionFilled() {
    if (languages.isEmpty) return false;

    final defaultLangCode = languages[0].languageCode;

    // Check in the language-specific controller first
    final defaultLangController = longDescriptionControllers[defaultLangCode];
    if (defaultLangController != null &&
        defaultLangController.text.trim().isNotEmpty) {
      return true;
    }

    // Check in the main longDescription variable as fallback
    if (longDescription != null && longDescription!.trim().isNotEmpty) {
      return true;
    }

    return false;
  }

  Future<void> _onLanguageChanged(int index) async {
    if (index >= 0 && index < languages.length) {
      // Check if can switch from default language to other languages
      if (!_canSwitchLanguage(index)) {
        return;
      }

      // Save current HTML content to the previous language controller
      if (selectedLanguageIndex < languages.length) {
        final previousLangCode = languages[selectedLanguageIndex].languageCode;
        final textController = longDescriptionControllers[previousLangCode];
        if (textController != null) {
          try {
            final text = await controller.getText();
            if (text.trim().isNotEmpty) {
              textController.text = text;
            }
          } catch (e) {
            // Handle error silently - HTML editor might not be ready
          }
        }
      }

      // Update the selected language index first
      setState(() {
        selectedLanguageIndex = index;
      });

      // Refresh Form1 widget's data from controllers after language change
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Notify Form1 to refresh tag data from parent controllers
        if (form1StateKey.currentState != null) {
          form1StateKey.currentState!.refreshFromParentControllers();
        }

        // Clear form validation errors when switching languages
        if (formKey1.currentState != null) {
          // Force form to revalidate with current values, which will clear
          // validation errors for non-default languages
          formKey1.currentState!.validate();
        }
      });

      // Load HTML content for the new language with proper error handling
      if (index < languages.length) {
        final newLangCode = languages[index].languageCode;
        final textController = longDescriptionControllers[newLangCode];

        try {
          if (textController != null && textController.text.isNotEmpty) {
            // Try to set text with retry mechanism
            _setHtmlEditorTextWithRetry(textController.text);
          } else {
            // Try to clear with retry mechanism
            _clearHtmlEditorWithRetry();
          }
        } catch (e) {
          // Handle error silently - HTML editor might not be ready
        }
      }
    }
  }

  // Method to get title data for API (following provider registration pattern)
  Map<String, String> getTitleData() {
    final Map<String, String> titleData = {};

    for (var lang in languages) {
      final String code = lang.languageCode;
      final controller = titleControllers[code];
      if (controller != null && controller.text.trim().isNotEmpty) {
        titleData[code] = controller.text.trim();
      }
    }

    return titleData;
  }

  // Method to get description data for API (following provider registration pattern)
  Map<String, String> getDescriptionData() {
    final Map<String, String> descriptionData = {};

    for (var lang in languages) {
      final String code = lang.languageCode;
      final controller = descriptionControllers[code];
      if (controller != null && controller.text.trim().isNotEmpty) {
        descriptionData[code] = controller.text.trim();
      }
    }

    return descriptionData;
  }

  // Method to sync tag data from Form1 to parent controllers
  void _syncTagDataFromForm1() {
    if (form1StateKey.currentState != null) {
      try {
        final form1TagData = form1StateKey.currentState!.getTagData();

        // Update parent's tagsControllers with Form1 data
        for (var lang in languages) {
          final String code = lang.languageCode;
          if (form1TagData.containsKey(code)) {
            tagsControllers[code]?.text = form1TagData[code]!;
          }
        }
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  // Method to get tags data for API (following provider registration pattern)
  Map<String, String> getTagsData() {
    final Map<String, String> tagsData = {};

    // First sync tag data from Form1 to parent controllers
    _syncTagDataFromForm1();

    // Get tags data from Form1 if available
    if (form1StateKey.currentState != null) {
      try {
        final form1TagData = form1StateKey.currentState!.getTagData();
        if (form1TagData.isNotEmpty) {
          return form1TagData;
        }
        // ignore: empty_catches
      } catch (e) {}
    }

    // Fallback: get from language controllers
    for (var lang in languages) {
      final String code = lang.languageCode;
      final controller = tagsControllers[code];
      if (controller != null && controller.text.trim().isNotEmpty) {
        tagsData[code] = controller.text.trim();
      }
    }

    return tagsData;
  }

  // Method to get long description data for API (following provider registration pattern)
  Map<String, String> getLongDescriptionData() {
    final Map<String, String> longDescriptionData = {};

    for (var lang in languages) {
      final String code = lang.languageCode;
      final controller = longDescriptionControllers[code];
      if (controller != null && controller.text.trim().isNotEmpty) {
        longDescriptionData[code] = controller.text.trim();
      }
    }

    return longDescriptionData;
  }

  // Method to sync FAQ data from Form3 to parent controllers
  void _syncFaqDataFromForm3() {
    if (form3StateKey.currentState != null) {
      try {
        final form3FaqData = form3StateKey.currentState!.getFaqData();

        // Update parent's FAQ controllers with Form3 data
        for (var lang in languages) {
          final String code = lang.languageCode;
          if (form3FaqData.containsKey(code)) {
            final faqs = form3FaqData[code]!;

            // Clear existing controllers for this language
            faqQuestionControllers[code]?.forEach(
              (controller) => controller.dispose(),
            );
            faqAnswerControllers[code]?.forEach(
              (controller) => controller.dispose(),
            );

            // Create new controllers for this language
            faqQuestionControllers[code] = [];
            faqAnswerControllers[code] = [];

            for (final faq in faqs) {
              faqQuestionControllers[code]!.add(
                TextEditingController(text: faq['question'] ?? ''),
              );
              faqAnswerControllers[code]!.add(
                TextEditingController(text: faq['answer'] ?? ''),
              );
            }
          }
        }
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  // Method to get FAQ data for API (following provider registration pattern)
  Map<String, List<Map<String, String>>> getFaqData() {
    final Map<String, List<Map<String, String>>> faqData = {};

    // First sync FAQ data from Form3 to parent controllers
    _syncFaqDataFromForm3();

    // Get FAQ data from Form3 if available
    if (form3StateKey.currentState != null) {
      try {
        final form3FaqData = form3StateKey.currentState!.getFaqData();
        if (form3FaqData.isNotEmpty) {
          return form3FaqData;
        }
        // ignore: empty_catches
      } catch (e) {}
    }

    // Fallback: get from language-specific FAQ controllers (for backward compatibility)
    for (var lang in languages) {
      final String code = lang.languageCode;
      final currentFaqs = <Map<String, String>>[];

      // Use language-specific controllers if available
      if (faqQuestionControllers.containsKey(code) &&
          faqAnswerControllers.containsKey(code)) {
        final questions = faqQuestionControllers[code] ?? [];
        final answers = faqAnswerControllers[code] ?? [];

        for (int i = 0; i < questions.length && i < answers.length; i++) {
          final question = questions[i].text.trim();
          final answer = answers[i].text.trim();
          if (question.isNotEmpty && answer.isNotEmpty) {
            currentFaqs.add({'question': question, 'answer': answer});
          }
        }
      } else if (code == languages.first.languageCode) {
        // Only for default language, use main FAQ controllers as final fallback
        for (int i = 0; i < faqQuestionTextEditors.value.length; i++) {
          final question = faqQuestionTextEditors.value[i].text.trim();
          final answer = faqAnswersTextEditors.value[i].text.trim();
          if (question.isNotEmpty && answer.isNotEmpty) {
            currentFaqs.add({'question': question, 'answer': answer});
          }
        }
      }

      if (currentFaqs.isNotEmpty) {
        faqData[code] = currentFaqs;
      }
    }

    return faqData;
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

  @override
  void initState() {
    super.initState();
    // Initialize empty controllers first to prevent late initialization errors
    _initializeEmptyControllers();
    _initializeLanguages();
    Future.delayed(Duration.zero, () {
      if (context.read<ProviderDetailsCubit>().getProviderType() == "0") {
        memReqTaskController.text = "1";
      }
    });
    selectedCategory = int.parse(widget.service?.categoryId ?? '0');
    selectedCategoryTitle = widget.service?.categoryName;

    selectedTax = int.parse(widget.service?.taxId ?? '0');
    selectedTaxTitle = widget.service?.taxId == null
        ? ''
        : '${widget.service?.taxTitle} (${widget.service?.taxPercentage}%)';

    // Populate main controllers with service data
    if (widget.service != null) {
      serviceTitleController.text = widget.service!.title ?? '';
      serviceDescrController.text = widget.service!.description ?? '';
      serviceTagController.text = widget.service!.tags ?? '';
      longDescription = widget.service!.longDescription;

      // Populate main FAQ controllers with service data
      if (widget.service!.faqs != null && widget.service!.faqs!.isNotEmpty) {
        faqQuestionTextEditors.value.clear();
        faqAnswersTextEditors.value.clear();

        for (final faq in widget.service!.faqs!) {
          faqQuestionTextEditors.value.add(
            TextEditingController(text: faq.question ?? ''),
          );
          faqAnswersTextEditors.value.add(
            TextEditingController(text: faq.answer ?? ''),
          );
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    if (selectedPriceType == null) {
      if (widget.service?.taxType == 'included') {
        selectedPriceType = {
          'title': 'taxIncluded'.translate(context: context),
          'value': '0',
        };
      } else {
        selectedPriceType = {
          'title': 'taxExcluded'.translate(context: context),
          'value': '1',
        };
      }
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.secondaryColor,
        surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
        title: CustomText(
          widget.service?.id != null
              ? 'editServiceBtnLbl'.translate(context: context)
              : 'createServiceTxtLbl'.translate(context: context),
          color: Theme.of(context).colorScheme.blackColor,
          fontWeight: FontWeight.bold,
        ),
        leading: CustomBackArrow(
          onTap: () async {
            if (currIndex != 1) {
              // Save current form data before going back
              await _saveCurrentFormData();
              setState(() {
                currIndex--;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 85),
          child: SizedBox(
            height: 85,
            child: EasyStepper(
              internalPadding: 0,
              borderThickness: 0,
              stepBorderRadius: 0,
              padding: EdgeInsets.zero,
              showStepBorder: false,
              activeStep: currIndex - 1,
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
              finishedStepBackgroundColor: context.colorScheme.secondaryColor,
              finishedStepIconColor: context.colorScheme.accentColor,
              finishedStepBorderColor: context.colorScheme.accentColor,
              finishedStepBorderType: BorderType.normal,
              showLoadingAnimation: false,
              unreachedStepBackgroundColor: context.colorScheme.primaryColor
                  .withValues(alpha: 0.2),
              onStepReached: (index) async {
                if (index + 1 != currIndex) {
                  // Validate current form before changing
                  FormState? form = formKey1.currentState;
                  switch (currIndex) {
                    case 4:
                      form = formKey3.currentState;
                      break;
                    case 3:
                      form = formKeySEO.currentState;
                      break;
                    case 2:
                      form = formKey2.currentState;
                      break;
                    default:
                      form = formKey1.currentState;
                      break;
                  }

                  if (form != null) {
                    form.save();
                    if (form.validate()) {
                      setState(() {
                        currIndex = index + 1;
                      });
                      if (scrollController.hasClients &&
                          scrollController.offset != 0) {
                        scrollController.jumpTo(0);
                      }
                    }
                  } else {
                    setState(() {
                      currIndex = index + 1;
                    });
                    if (scrollController.hasClients &&
                        scrollController.offset != 0) {
                      scrollController.jumpTo(0);
                    }
                  }
                }
              },
              steps: List.generate(
                _participant.length,
                (index) => EasyStep(
                  customStep: CustomSvgPicture(
                    svgImage: AppAssets.bClock,
                    color: index <= currIndex - 1
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
                    color: index == currIndex - 1
                        ? context.colorScheme.accentColor
                        : context.colorScheme.blackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigation(),
      body: screenBuilder(currIndex),
    );
  }

  Widget screenBuilder(int currentPage) {
    Widget currentForm = Form1(
      key: form1StateKey,
      context: context,
      formKey1: formKey1,
      serviceTitleController: serviceTitleController,
      surviceSlugController: surviceSlugController,
      serviceTagController: serviceTagController,
      serviceDescrController: serviceDescrController,
      cancelBeforeController: cancelBeforeController,
      serviceTitleFocus: serviceTitleFocus,
      serviceSlugFocus: serviceSlugFocus,
      serviceTagFocus: serviceTagFocus,
      serviceDescrFocus: serviceDescrFocus,
      cancelBeforeFocus: cancelBeforeFocus,
      selectedCategoryTitle: selectedCategoryTitle,
      selectedTaxTitle: selectedTaxTitle,
      isPayLaterAllowed: isPayLaterAllowed,
      isStoreAllowed: isStoreAllowed,
      isDoorStepAllowed: isDoorStepAllowed,
      serviceStatus: serviceStatus,
      isCancelAllowed: isCancelAllowed,
      finalTagList: finalTagList,
      tagsList: tagsList,
      onCategorySelect: selectCategoryBottomSheet,
      onTaxSelect: selectTaxesBottomSheet,
      onPayLaterChanged: (value) {
        setState(() {
          isPayLaterAllowed = value;
        });
      },
      onStoreAllowedChanged: (value) {
        setState(() {
          isStoreAllowed = value;
        });
      },
      onDoorStepAllowedChanged: (value) {
        setState(() {
          isDoorStepAllowed = value;
        });
      },
      onStatusChanged: (value) {
        setState(() {
          serviceStatus = value;
        });
      },
      onCancelAllowedChanged: (value) {
        setState(() {
          isCancelAllowed = value;
        });
      },
      onTagAdded: _addTag,
      onTagRemoved: _removeTag,
      // Multi-language support
      languages: languages.isNotEmpty ? languages : null,
      defaultLanguage: defaultLanguage,
      selectedLanguageIndex: selectedLanguageIndex,
      onLanguageChanged: _onLanguageChanged,
      titleControllers: languages.isNotEmpty ? titleControllers : null,
      descriptionControllers: languages.isNotEmpty
          ? descriptionControllers
          : null,
      tagControllers: languages.isNotEmpty ? tagsControllers : null,
    );

    switch (currIndex) {
      case 5:
        currentForm = Form4(
          key: form4StateKey,
          controller: controller,
          longDescription: longDescription,
          serviceId: widget.service?.id,
          // Multi-language support
          languages: languages,
          defaultLanguage: defaultLanguage,
          selectedLanguageIndex: selectedLanguageIndex,
          onLanguageChanged: _onLanguageChanged,
          longDescriptionControllers: longDescriptionControllers,
        );

        break;
      case 4:
        currentForm = Form3(
          key: form3StateKey,
          formKey3: formKey3,
          faqQuestionTextEditors: faqQuestionTextEditors,
          faqAnswersTextEditors: faqAnswersTextEditors,
          context: context,
          // Multi-language support
          languages: languages.isNotEmpty ? languages : null,
          defaultLanguage: defaultLanguage,
          selectedLanguageIndex: selectedLanguageIndex,
          onLanguageChanged: _onLanguageChanged,
          faqQuestionControllers: languages.isNotEmpty
              ? faqQuestionControllers
              : null,
          faqAnswerControllers: languages.isNotEmpty
              ? faqAnswerControllers
              : null,
        );

        break;
      case 3:
        currentForm = FormSEO(
          formKey: formKeySEO,
          seoTitleController: seoTitleController,
          seoDescriptionController: seoDescriptionController,
          seoKeywordsController: seoKeywordsController,
          seoSchemaMarkupController: seoSchemaMarkupController,
          pickSeoOgImage: pickSeoOgImage,
          seoTitleFocus: seoTitleFocus,
          seoDescriptionFocus: seoDescriptionFocus,
          seoKeywordsFocus: seoKeywordsFocus,
          seoSchemaMarkupFocus: seoSchemaMarkupFocus,
          pickedSeoOgImage: pickedSeoOgImagePath,
          showCameraAndGalleryOption: showCameraAndGalleryOption,
          service: widget.service,
          context: context,
          pickedLocalImages: pickedLocalImages,
        );
        break;
      case 2:
        currentForm = Form2(
          formKey2: formKey2,
          priceController: priceController,
          discountPriceController: discountPriceController,
          memReqTaskController: memReqTaskController,
          durationTaskController: durationTaskController,
          qtyAllowedTaskController: qtyAllowedTaskController,
          priceFocus: priceFocus,
          discountPriceFocus: discountPriceFocus,
          memReqTaskFocus: memReqTaskFocus,
          durationTaskFocus: durationTaskFocus,
          qtyAllowedTaskFocus: qtyAllowedTaskFocus,
          selectedPriceType: selectedPriceType,
          selectedTaxTitle: selectedTaxTitle,
          onPriceTypeSelect: () {
            final List<Map<String, dynamic>> values = [
              {
                'title': 'taxIncluded'.translate(context: context),
                'id': '0',
                "isSelected": selectedPriceType?["value"] == "0",
              },
              {
                'title': 'taxExcluded'.translate(context: context),
                'id': '1',
                "isSelected": selectedPriceType?["value"] == "1",
              },
            ];

            UiUtils.showModelBottomSheets(
              context: context,
              child: SelectableListBottomSheet(
                bottomSheetTitle: "priceType",
                itemList: values,
              ),
            ).then((value) {
              if (value != null) {
                selectedPriceType = {
                  'title': value["selectedItemName"],
                  'value': value["selectedItemId"],
                };

                setState(() {});
              }
            });
          },
          onTaxSelect: selectTaxesBottomSheet,
          imagePicker: imagePicker,
          pickedServiceImage: pickedServiceImage,
          selectedOtherImages: selectedOtherImages,
          previouslyAddedOtherImages: previouslyAddedOtherImages,
          selectedFiles: selectedFiles,
          previouslyAddedFiles: previouslyAddedFiles,
          onPreviousImageDeleted: (deletedImage) {
            deletedPreviouslyAddedImages.add(deletedImage);
          },
          onPreviousFileDeleted: (deletedFile) {
            deletedPreviouslyAddedFiles.add(deletedFile);
          },
          onServiceImagePick: (source) {
            pickedServiceImage = imagePicker.pickedFile?.path ?? '';
          },
          service: widget.service,
          context: context,
        );
        break;
      default:
        currentForm = Form1(
          key: form1StateKey,
          context: context,
          formKey1: formKey1,
          serviceTitleController: serviceTitleController,
          surviceSlugController: surviceSlugController,
          serviceTagController: serviceTagController,
          serviceDescrController: serviceDescrController,
          cancelBeforeController: cancelBeforeController,
          serviceTitleFocus: serviceTitleFocus,
          serviceSlugFocus: serviceSlugFocus,
          serviceTagFocus: serviceTagFocus,
          serviceDescrFocus: serviceDescrFocus,
          cancelBeforeFocus: cancelBeforeFocus,
          selectedCategoryTitle: selectedCategoryTitle,
          selectedTaxTitle: selectedTaxTitle,
          isPayLaterAllowed: isPayLaterAllowed,
          isStoreAllowed: isStoreAllowed,
          isDoorStepAllowed: isDoorStepAllowed,
          serviceStatus: serviceStatus,
          isCancelAllowed: isCancelAllowed,
          finalTagList: finalTagList,
          tagsList: tagsList,
          onCategorySelect: selectCategoryBottomSheet,
          onTaxSelect: selectTaxesBottomSheet,
          onPayLaterChanged: (value) {
            setState(() {
              isPayLaterAllowed = value;
            });
          },
          onStoreAllowedChanged: (value) {
            setState(() {
              isStoreAllowed = value;
            });
          },
          onDoorStepAllowedChanged: (value) {
            setState(() {
              isDoorStepAllowed = value;
            });
          },
          onStatusChanged: (value) {
            setState(() {
              serviceStatus = value;
            });
          },
          onCancelAllowedChanged: (value) {
            setState(() {
              isCancelAllowed = value;
            });
          },
          onTagAdded: _addTag,
          onTagRemoved: _removeTag,
          // Multi-language support
          languages: languages.isNotEmpty ? languages : null,
          defaultLanguage: defaultLanguage,
          selectedLanguageIndex: selectedLanguageIndex,
          onLanguageChanged: _onLanguageChanged,
          titleControllers: titleControllers.isNotEmpty
              ? titleControllers
              : null,
          descriptionControllers: descriptionControllers.isNotEmpty
              ? descriptionControllers
              : null,
          tagControllers: tagsControllers.isNotEmpty ? tagsControllers : null,
        );

        break;
    }
    return currIndex == 5
        ? currentForm
        : SingleChildScrollView(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.all(15),
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: currentForm,
          );
  }

  Future selectCategoryBottomSheet() {
    return UiUtils.showModelBottomSheets(
      context: context,
      enableDrag: true,
      child: BlocBuilder<FetchServiceCategoryCubit, FetchServiceCategoryState>(
        builder: (BuildContext context, FetchServiceCategoryState state) {
          if (state is FetchServiceCategoryFailure) {
            return Center(
              child: ErrorContainer(
                showRetryButton: false,
                onTapRetry: () {},
                errorMessage: state.errorMessage.translate(context: context),
              ),
            );
          }
          if (state is FetchServiceCategorySuccess) {
            if (state.serviceCategories.isEmpty) {
              return NoDataContainer(
                titleKey: 'noDataFound'.translate(context: context),
                subTitleKey: 'noDataFoundSubTitle'.translate(context: context),
              );
            }

            final List<Map<String, dynamic>> values = state.serviceCategories
                .map((element) {
                  return {
                    "title": element.translatedName,
                    "id": element.id,
                    "isSelected":
                        selectedCategory == int.parse(element.id ?? '0'),
                  };
                })
                .toList();

            return SelectableListBottomSheet(
              bottomSheetTitle: "selectCategoryLbl",
              itemList: values,
            );
          }
          return Center(
            child: CustomCircularProgressIndicator(
              color: AppColors.whiteColors,
            ),
          );
        },
      ),
    ).then((value) {
      if (value != null) {
        selectedCategory = int.parse(value["selectedItemId"].toString());
        selectedCategoryTitle = value["selectedItemName"];
        setState(() {});
      }
    });
  }

  Future selectTaxesBottomSheet() {
    return UiUtils.showModelBottomSheets(
      context: context,
      enableDrag: true,
      child: BlocBuilder<FetchTaxesCubit, FetchTaxesState>(
        builder: (BuildContext context, FetchTaxesState state) {
          if (state is FetchTaxesFailure) {
            return Center(
              child: ErrorContainer(
                showRetryButton: false,
                onTapRetry: () {},
                errorMessage: state.errorMessage,
              ),
            );
          }
          if (state is FetchTaxesSuccess) {
            if (state.taxes.isEmpty) {
              return NoDataContainer(
                titleKey: 'noDataFound'.translate(context: context),
                subTitleKey: 'noDataFoundSubTitle'.translate(context: context),
              );
            }
            final List<Map<String, dynamic>> itemList = [];
            state.taxes.forEach((element) {
              itemList.add({
                "title": "${element.title!} (${element.percentage}%)",
                "id": element.id,
                "isSelected": selectedTax == int.parse(element.id ?? '0'),
              });
            });

            return SelectableListBottomSheet(
              bottomSheetTitle: "chooseTaxes",
              itemList: itemList,
            );
          }
          return Center(
            child: CustomCircularProgressIndicator(
              color: AppColors.whiteColors,
            ),
          );
        },
      ),
    ).then((value) {
      if (value != null) {
        selectedTax = int.parse(value["selectedItemId"]);
        selectedTaxTitle = value["selectedItemName"];
        setState(() {});
      }
    });
  }

  // Method to save current form data before navigation
  Future<void> _saveCurrentFormData() async {
    try {
      // Save HTML editor content if on long description page
      if (currIndex == 5) {
        final tempText = await controller.getText();
        if (tempText.trim().isNotEmpty) {
          longDescription = tempText;
          // Also save to current language's HTML content
          if (languages.isNotEmpty &&
              selectedLanguageIndex < languages.length) {
            final langCode = languages[selectedLanguageIndex].languageCode;
            longDescriptionControllers[langCode]?.text = tempText;
          }
        }
      }

      // Save form data if on other forms
      switch (currIndex) {
        case 1:
          // Form1 data is automatically saved in controllers
          formKey1.currentState?.save();
          break;
        case 2:
          // Form2 data is automatically saved in controllers
          formKey2.currentState?.save();
          break;
        case 3:
          // FormSEO data is automatically saved in controllers
          formKeySEO.currentState?.save();
          break;
        case 4:
          // Form3 (FAQs) data - save multi-language FAQ data
          formKey3.currentState?.save();
          if (form3StateKey.currentState != null) {
            form3StateKey.currentState!.saveData();
          }
          break;
        case 5:
          // Form4 (Long Description) - already handled above

          break;
      }
    } catch (e) {
      // Handle errors silently
      // Handle errors silently
    }
  }

  Padding bottomNavigation() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: CustomContainer(
        color: context.colorScheme.secondaryColor,
        padding: EdgeInsetsDirectional.only(
          start: 15,
          end: 15,
          top: 10,
          bottom: 10 + MediaQuery.of(context).padding.bottom,
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currIndex > 1) ...[
              Expanded(flex: 1, child: nextPrevBtnWidget(false)),
              const SizedBox(width: 10),
            ],
            Expanded(flex: 5, child: nextPrevBtnWidget(true)),
          ],
        ),
      ),
    );
  }

  CustomRoundedButton nextPrevBtnWidget(bool isNext) {
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
      onTap: () {
        UiUtils.removeFocus();
        onNextPrevBtnClick(isNext: isNext, currentPage: currIndex);
      },
      buttonTitleWidget: isNext && currIndex >= _participant.length
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
      child:
          context.watch<CreateServiceCubit>().state is CreateServiceInProgress
          ? CustomCircularProgressIndicator(color: AppColors.whiteColors)
          : null,
    );
  }

  Future<void> onNextPrevBtnClick({
    required bool isNext,
    required int currentPage,
  }) async {
    UiUtils.removeFocus();

    if (currIndex == 5) {
      try {
        final tempText = await controller.getText();
        longDescription = tempText; // Always update, even if empty
        // Also save to current language's controller
        if (languages.isNotEmpty && selectedLanguageIndex < languages.length) {
          final langCode = languages[selectedLanguageIndex].languageCode;
          longDescriptionControllers[langCode]?.text = tempText;
        }
        controller.clearFocus();
      } catch (e) {
        // Error getting HTML content
      }
    }
    if (isNext) {
      FormState? form = formKey1.currentState; //default value
      switch (currIndex) {
        case 4:
          form = formKey3.currentState;
          break;
        case 3:
          form = formKeySEO.currentState;
          break;
        case 2:
          form = formKey2.currentState;
          break;
        default:
          form = formKey1.currentState;
          break;
      }
      if (form == null && currIndex != 5) return;

      if (form != null) {
        form.save();
      }

      //not validating the faqs and long description pages
      if (currIndex > 3 || form!.validate()) {
        // Save current form data before proceeding (next button)
        await _saveCurrentFormData();

        if (currIndex < totalForms) {
          if (currIndex == 1) {
            // Check if tags exist - try multiple sources
            final defaultLanguageData = form1StateKey.currentState
                ?.getDefaultLanguageData();
            final defaultTags = defaultLanguageData?['tags'] ?? '';
            final hasGlobalTags = finalTagList.isNotEmpty;
            final hasOldTags = tagsList.isNotEmpty;

            // Check all possible tag sources
            if (defaultTags.isEmpty && !hasGlobalTags && !hasOldTags) {
              UiUtils.showMessage(
                context,
                'pleaseAddTags',
                ToastificationType.error,
              );
              return;
            }
          }
          if (currIndex == 2) {
            if (!(imagePicker.pickedFile != null ||
                widget.service?.imageOfTheService != null ||
                pickedServiceImage != '')) {
              FocusScope.of(context).unfocus();
              UiUtils.showMessage(
                context,
                "selectServiceImageToContinue",
                ToastificationType.warning,
              );
              return;
            }
          }
          currIndex++;
          scrollController.jumpTo(0);
          setState(() {});
        } else {
          // Save current form data before proceeding
          await _saveCurrentFormData();

          // Validate that long description is provided in default language before submit
          if (!_isDefaultLanguageLongDescriptionFilled()) {
            UiUtils.showMessage(
              context,
              'pleaseAddLongDescriptionInDefaultLanguage'.translate(context: context),
              ToastificationType.warning,
            );
            return;
          }

          // Get multi-language data using the simple methods (following provider registration pattern)
          final Map<String, String> formTitles = getTitleData();
          final Map<String, String> formDescriptions = getDescriptionData();
          final Map<String, String> formTags = getTagsData();
          final Map<String, String> formLongDescriptions =
              getLongDescriptionData();
          final Map<String, List<Map<String, String>>> formFaqs = getFaqData();

          // Create the translated_fields structure (following provider registration pattern)
          final Map<String, dynamic> translatedFields = {
            'title': formTitles,
            'description': formDescriptions,
            'tags': formTags,
            'long_description': formLongDescriptions,
            'faqs': formFaqs,
          };

          final CreateServiceModel createServiceModel = CreateServiceModel(
            serviceId: widget.service?.id,
            title: serviceTitleController.text,
            slug: surviceSlugController.text,
            description: serviceDescrController.text,
            price: priceController.text,
            members: memReqTaskController.text,
            maxQty: qtyAllowedTaskController.text,
            duration: int.parse(durationTaskController.text),
            cancelableTill: cancelBeforeController.text.trim().toString(),
            iscancelable: isCancelAllowed ? 1 : 0,
            is_pay_later_allowed: isPayLaterAllowed ? 1 : 0,
            isStoreAllowed: isStoreAllowed ? 1 : 0,
            status: serviceStatus ? "active" : "deactive",
            isDoorStepAllowed: isDoorStepAllowed ? 1 : 0,
            discounted_price: int.parse(discountPriceController.text),
            image: pickedServiceImage,
            categories: selectedCategory.toString(),
            tax_type: priceTypeFilter[selectedPriceType?['value']],
            tags: finalTagList.isNotEmpty
                ? finalTagList.map((tag) => tag['text']).join(',')
                : tagsList.join(','),
            taxId: selectedTax.toString(),
            other_images: selectedOtherImages.value,
            files: selectedFiles.value,
            deletedOtherImages: deletedPreviouslyAddedImages.toList(),
            deletedFiles: deletedPreviouslyAddedFiles.toList(),
            long_description: longDescription,
            seoTitle: seoTitleController.text.trim().isEmpty
                ? null
                : seoTitleController.text.trim(),
            seoDescription: seoDescriptionController.text.trim().isEmpty
                ? null
                : seoDescriptionController.text.trim(),
            seoKeywords: seoKeywordsController.text.trim().isEmpty
                ? null
                : seoKeywordsController.text.trim(),
            seoSchemaMarkup: seoSchemaMarkupController.text.trim().isEmpty
                ? null
                : seoSchemaMarkupController.text.trim(),
            seoOgImage: pickedLocalImages['seoOgImage'],
            // Use new nested translated_fields structure only
            translatedFields: translatedFields,
          );

          if (imagePicker.pickedFile != null ||
              widget.service?.imageOfTheService != null ||
              pickedServiceImage != '') {
            if (context.read<FetchSystemSettingsCubit>().isDemoModeEnable) {
              UiUtils.showDemoModeWarning(context: context);
              return;
            }

            if (context.read<CreateServiceCubit>().state
                    is CreateServiceInProgress ||
                context.read<CreateServiceCubit>().state
                    is CreateServiceSuccess) {
              return;
            } else {
              context.read<CreateServiceCubit>().createService(
                createServiceModel,
              );
            }
          } else {
            FocusScope.of(context).unfocus();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('imageRequired'.translate(context: context)),
                  content: Text(
                    'pleaseSelectImage'.translate(context: context),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('ok'.translate(context: context)),
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    } else if (currIndex > 1) {
      // Save current form data before going back (previous button)
      await _saveCurrentFormData();
      currIndex--;
      setState(() {});
    }
  }
}
