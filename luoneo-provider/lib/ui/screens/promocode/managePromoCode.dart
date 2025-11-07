import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import '../../../app/generalImports.dart';

class ManagePromocode extends StatefulWidget {
  const ManagePromocode({super.key, this.promocode});

  final PromocodeModel? promocode;

  @override
  ManagePromocodeState createState() => ManagePromocodeState();

  static Route<ManagePromocode> route(RouteSettings routeSettings) {
    final Map? arguments = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (_) => ManagePromocode(promocode: arguments?['promocode']),
    );
  }
}

class ManagePromocodeState extends State<ManagePromocode> {
  int currIndex = 1;
  int totalForms = 2;

  //form 1
  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();
  Map? selectedDiscountType;
  ScrollController scrollController = ScrollController();

  // Multi-language support
  List<AppLanguage> languages = [];
  AppLanguage? defaultLanguage;
  int selectedLanguageIndex = 0;
  StreamSubscription? _languageListSubscription;
  bool _hasInitializedData = false;
  late Map<String, TextEditingController> messageControllers;
  Map<String, String> savedMessageData = {};
  late String? selectedStartDate = widget.promocode?.startDate
          ?.split(" ")
          .first,
      selectedEndDate = widget.promocode?.endDate?.split(" ").first;

  late TextEditingController promocodeController = TextEditingController(
    text: widget.promocode?.promoCode,
  );
  late TextEditingController startDtController = TextEditingController(
    text: widget.promocode?.startDate?.split(" ").first.toString().formatDate(),
  );
  late TextEditingController endDtController = TextEditingController(
    text: widget.promocode?.endDate?.split(" ").first.toString().formatDate(),
  );
  late TextEditingController noOfUserController = TextEditingController(
    text: widget.promocode?.noOfUsers,
  );
  late TextEditingController minOrderAmtController = TextEditingController(
    text: widget.promocode?.minimumOrderAmount,
  );
  late TextEditingController discountController = TextEditingController(
    text: widget.promocode?.discount,
  );
  late TextEditingController discountTypeController = TextEditingController(
    text: widget.promocode?.discountType.toString().translate(context: context),
  );
  late TextEditingController noOfRepeatUsageController = TextEditingController(
    text: widget.promocode?.noOfRepeatUsage,
  );
  FocusNode promocodeFocus = FocusNode();
  FocusNode startDtFocus = FocusNode();
  FocusNode endDtFocus = FocusNode();
  FocusNode noOfUserFocus = FocusNode();
  FocusNode minOrderAmtFocus = FocusNode();
  FocusNode discountFocus = FocusNode();
  FocusNode discountTypeFocus = FocusNode();
  FocusNode maxDiscFocus = FocusNode();
  FocusNode messageFocus = FocusNode();
  FocusNode noOfRepeatUsage = FocusNode();
  PickImage pickImage = PickImage();

  bool isStatus = false;
  bool isRepeatUsage = false;

  late TextEditingController maxDiscController = TextEditingController(
    text: widget.promocode?.maxDiscountAmount,
  );
  late TextEditingController messageController = TextEditingController();

  List<Map> discountTypesFilter = [];

  @override
  void dispose() {
    _languageListSubscription?.cancel();
    promocodeController.dispose();
    startDtController.dispose();
    endDtController.dispose();
    noOfUserController.dispose();
    minOrderAmtController.dispose();
    discountController.dispose();
    discountTypeController.dispose();
    noOfRepeatUsageController.dispose();
    promocodeFocus.dispose();
    endDtFocus.dispose();
    noOfUserFocus.dispose();
    minOrderAmtFocus.dispose();
    discountFocus.dispose();
    discountTypeFocus.dispose();
    maxDiscFocus.dispose();
    messageFocus.dispose();
    noOfRepeatUsage.dispose();
    pickImage.dispose();
    maxDiscController.dispose();
    messageController.dispose();

    // Dispose multi-language controllers
    for (final controller in messageControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  void _chooseImage() {
    // Dismiss keyboard when image picker is opened
    UiUtils.removeFocus();
    pickImage.pick();
  }

  void onAddPromoCode() {
    UiUtils.removeFocus();
    final FormState? form = formKey1.currentState; //default value
    if (form == null) return;

    form.save();

    // Additional validation for default language message
    if (languages.isNotEmpty && defaultLanguage != null) {
      final defaultLangCode = defaultLanguage!.languageCode;
      final defaultMessage =
          savedMessageData[defaultLangCode] ?? messageController.text;

      if (defaultMessage.trim().isEmpty) {
        UiUtils.showMessage(
          context,
          'pleaseEnterMessageForDefaultLanguage'.translate(context: context),
          ToastificationType.error,
        );
        return;
      }
    }

    if (form.validate()) {
      if (pickImage.pickedFile != null || widget.promocode?.image != null) {
        // Save current language message before submitting
        _saveCurrentLanguageMessage();

        // Prepare multi-language messages
        final Map<String, String> multiLangMessages = {};
        if (languages.isNotEmpty) {
          for (final language in languages) {
            final message = savedMessageData[language.languageCode] ?? '';
            if (message.isNotEmpty) {
              multiLangMessages[language.languageCode] = message;
            }
          }
        }

        // Create JSON encoded translated_fields
        String? translatedFieldsJson;
        if (multiLangMessages.isNotEmpty) {
          final translatedFields = {'message': multiLangMessages};
          translatedFieldsJson = jsonEncode(translatedFields);
        }

        //need to add more field in create promocode model
        final CreatePromocodeModel createPromocode = CreatePromocodeModel(
          promo_id: widget.promocode?.id,
          promoCode: promocodeController.text,
          startDate: selectedStartDate.toString(),
          endDate: selectedEndDate.toString(),
          minimumOrderAmount: minOrderAmtController.text,
          discountType: selectedDiscountType?['value'],
          discount: discountController.text,
          maxDiscountAmount: maxDiscController.text,
          message: messageController.text,
          multiLanguageMessages: multiLangMessages.isNotEmpty
              ? multiLangMessages
              : null,
          translatedFieldsJson: translatedFieldsJson,
          repeat_usage: isRepeatUsage ? '1' : '0',
          status: isStatus ? "1" : '0',
          no_of_users: noOfUserController.text,
          no_of_repeat_usage: noOfRepeatUsageController.text,
          image: pickImage.pickedFile,
        );

        if (context.read<FetchSystemSettingsCubit>().isDemoModeEnable) {
          UiUtils.showDemoModeWarning(context: context);
          return;
        }

        context.read<CreatePromocodeCubit>().createPromocode(createPromocode);
      } else {
        FocusScope.of(context).unfocus();

        //show if image is not picked
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('imageRequired'.translate(context: context)),
              content: Text('pleaseSelectImage'.translate(context: context)),
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

  @override
  void initState() {
    if (widget.promocode?.status != null) {
      if (widget.promocode?.status == '0') {
        isStatus = false;
      } else {
        isStatus = true;
      }
    }
    if (widget.promocode?.repeatUsage != null) {
      if (widget.promocode?.repeatUsage == '0') {
        isRepeatUsage = false;
      } else {
        isRepeatUsage = true;
      }
    }

    // Initialize multi-language support
    _initializeLanguageSupport();
    super.initState();
  }

  void _initializeLanguageSupport() {
    // Get language list
    context.read<LanguageListCubit>().getLanguageList();

    // Listen to language list changes
    _languageListSubscription = context.read<LanguageListCubit>().stream.listen(
      (state) {
        if (state is GetLanguageListSuccess && !_hasInitializedData) {
          _setupLanguageControllers(state.languages, state.defaultLanguage);
          _hasInitializedData = true;
        }
      },
    );
  }

  void _setupLanguageControllers(
    List<AppLanguage> languageList,
    AppLanguage? defLanguage,
  ) {
    // Reorder languages to show default language first
    languages = [];
    defaultLanguage = defLanguage;

    // Add default language first if it exists
    if (defaultLanguage != null) {
      languages.add(defaultLanguage!);
      // Add other languages except the default one
      for (final language in languageList) {
        if (language.languageCode != defaultLanguage!.languageCode) {
          languages.add(language);
        }
      }
    } else {
      languages = languageList;
    }

    // Debug mode only - uncomment for debugging
    // if (widget.promocode != null) {
    //   print('=== PROMO CODE EDIT MODE DEBUG ===');
    //   print('Promo Code ID: ${widget.promocode!.id}');
    //   print('Basic message: ${widget.promocode!.message}');
    //   print('Translated message: ${widget.promocode!.translatedMessage}');
    //   print('Translated messages map: ${widget.promocode!.translatedMessages}');
    //   print('=====================================');
    // }

    // Initialize message controllers for each language
    messageControllers = {};
    savedMessageData = {};

    for (final language in languages) {
      String initialMessage = '';

      // If editing an existing promocode, try to load the existing message
      if (widget.promocode != null) {
        // Priority 1: Try to get language-specific message from translated fields
        if (widget.promocode!.translatedMessages != null &&
            widget.promocode!.translatedMessages!.containsKey(
              language.languageCode,
            )) {
          initialMessage =
              widget.promocode!.translatedMessages![language.languageCode]!;
        }
        // Priority 2: For default language, fallback to general translated message or message
        else if (language.languageCode == defaultLanguage?.languageCode) {
          if (widget.promocode!.translatedMessage != null &&
              widget.promocode!.translatedMessage!.isNotEmpty) {
            initialMessage = widget.promocode!.translatedMessage!;
          } else if (widget.promocode!.message != null &&
              widget.promocode!.message!.isNotEmpty) {
            initialMessage = widget.promocode!.message!;
          }
        }
        // Priority 3: For non-default languages, only use translated_fields data
        // Don't auto-fill with default language message for other languages
      }

      messageControllers[language.languageCode] = TextEditingController(
        text: initialMessage,
      );
      savedMessageData[language.languageCode] = initialMessage;

      // Debug mode only - uncomment for debugging
      // if (widget.promocode != null) {
      //   print('Language: ${language.languageCode} (${language.languageName}) -> Message: "$initialMessage"');
      // }
    }

    // Set the selected language index to default language (should be 0 since it's first)
    selectedLanguageIndex = 0;

    // Update messageController to point to current language controller
    _updateCurrentMessageController();

    // Add listener to message controller to auto-enable language tabs
    messageController.addListener(() {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild and update the language tab enabled states
        });
      }
    });

    // Trigger setState to rebuild UI with languages loaded
    if (mounted) {
      setState(() {
      });
    }
  }

  void _updateCurrentMessageController() {
    if (languages.isNotEmpty && selectedLanguageIndex < languages.length) {
      final currentLangCode = languages[selectedLanguageIndex].languageCode;
      messageController =
          messageControllers[currentLangCode] ?? TextEditingController();
    }
  }

  void _saveCurrentLanguageMessage() {
    if (languages.isNotEmpty && selectedLanguageIndex < languages.length) {
      final currentLangCode = languages[selectedLanguageIndex].languageCode;
      savedMessageData[currentLangCode] = messageController.text;
    }
  }

  void _switchLanguage(int newIndex) {
    if (newIndex == selectedLanguageIndex || newIndex >= languages.length)
      return;

    // Validate current language before switching (if it's default language)
    if (selectedLanguageIndex == 0 && defaultLanguage != null) {
      final currentMessage = messageController.text.trim();
      if (currentMessage.isEmpty) {
        // Show validation error and don't switch
        UiUtils.showMessage(
          context,
          'pleaseEnterMessageForDefaultLanguage'.translate(context: context),
          ToastificationType.error,
        );
        return;
      }
    }

    // Save current language data
    _saveCurrentLanguageMessage();

    // Switch to new language
    selectedLanguageIndex = newIndex;
    _updateCurrentMessageController();

    setState(() {});
  }

  String? _validateMessage(String? value) {
    // Only require message for default language (index 0)
    if (selectedLanguageIndex == 0 && defaultLanguage != null) {
      return Validator.nullCheck(context, value);
    }
    // For other languages, message is optional
    return null;
  }

  // Match details.dart: determine if a language tab should be visually enabled
  bool _isLanguageTabEnabled(int targetIndex) {
    // Default language is always enabled
    if (targetIndex == 0) {
      return true;
    }
    // If already on non-default language, allow switching between non-defaults
    if (selectedLanguageIndex > 0) {
      return true;
    }
    // When on default language, enable other tabs only if default message is filled
    final String defaultMessage = messageController.text.trim();
    return defaultMessage.isNotEmpty;
  }

  @override
  void didChangeDependencies() {
    discountTypesFilter = [
      {
        'value': 'percentage',
        'title': 'percentage'.translate(context: context),
      },
      {'value': 'amount', 'title': 'amount'.translate(context: context)},
    ];

    if (widget.promocode?.discountType != null) {
      selectedDiscountType = discountTypesFilter
          .where(
            (Map element) => element['value'] == widget.promocode?.discountType,
          )
          .toList()[0];
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => LanguageListCubit())],
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: "promocodeLbl".translate(context: context),

          statusBarColor: context.colorScheme.secondaryColor,
          elevation: 1,
        ),
        body: BlocListener<CreatePromocodeCubit, CreatePromocodeState>(
          listener: (BuildContext context, CreatePromocodeState state) {
            if (state is CreatePromocodeFailure) {
              UiUtils.showMessage(
                context,
                state.errorMessage,
                ToastificationType.error,
              );
            }
            if (state is CreatePromocodeSuccess) {
              Navigator.pop(context);
            }
          },
          child: screenBuilder(currIndex),
        ),
      ),
    );
  }

  Widget screenBuilder(int currentPage) {
    return Stack(
      children: [
        SingleChildScrollView(
          clipBehavior: Clip.none,
          padding: const EdgeInsets.fromLTRB(
            15,
            15,
            15,
            15 + UiUtils.bottomButtonSpacing,
          ),
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: PromoCodeForm(),
        ),
        Align(alignment: Alignment.bottomCenter, child: bottomNavigation()),
      ],
    );
  }

  Widget PromoCodeForm() {
    // Show shimmer loading while languages are being loaded
    if (languages.isEmpty) {
      return const ShimmerLoadingContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            CustomShimmerContainer(
              height: 50,
              margin: EdgeInsets.only(bottom: 20),
            ),
            CustomShimmerContainer(
              height: 60,
              margin: EdgeInsets.only(bottom: 15),
            ),
            CustomShimmerContainer(
              height: 100,
              margin: EdgeInsets.only(bottom: 15),
            ),
            CustomShimmerContainer(
              height: 60,
              margin: EdgeInsets.only(bottom: 15),
            ),
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
          ],
        ),
      );
    }

    return Form(
      key: formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFormField(
            labelText: 'promocodeLbl'.translate(context: context),
            controller: promocodeController,
            currentFocusNode: promocodeFocus,
            validator: (String? value) => Validator.nullCheck(context, value),
            nextFocusNode: messageFocus,
          ),

          // Language Tabs and Message Field
          if (languages.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 10),
              child: Row(
                children: languages.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final AppLanguage language = entry.value;
                  final bool isSelected = selectedLanguageIndex == index;
                  final bool isEnabled = _isLanguageTabEnabled(index);

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _switchLanguage(index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.accentColor
                              : (isEnabled
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.secondaryColor
                                    : AppColors.grey.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.accentColor
                                : (isEnabled
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.lightGreyColor
                                      : AppColors.grey.withValues(alpha: 0.5)),
                          ),
                        ),
                        child: Text(
                          language.languageName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.lightPrimaryColor
                                : (isEnabled
                                      ? Theme.of(context).colorScheme.blackColor
                                      : AppColors.grey),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          CustomTextFormField(
            expands: true,
            heightVal: 70,
            labelText:
                languages.isNotEmpty && selectedLanguageIndex < languages.length
                ? '${'messageLbl'.translate(context: context)} (${languages[selectedLanguageIndex].languageName})'
                : 'messageLbl'.translate(context: context),
            controller: messageController,
            currentFocusNode: messageFocus,
            nextFocusNode: startDtFocus,
            textInputType: TextInputType.multiline,
            validator: (String? value) => _validateMessage(value),
          ),
          CustomText(
            'imageLbl'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
          ),
          pickImage.ListenImageChange((BuildContext context, image) {
            if (image == null) {
              if (widget.promocode?.image != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: GestureDetector(
                    onTap: _chooseImage,
                    child: CustomContainer(
                      width: MediaQuery.of(context).size.width / 0.5,
                      height: 200,
                      color: context.colorScheme.accentColor.withAlpha(30),
                      borderRadius: UiUtils.borderRadiusOf10,
                      border: Border.all(
                        color: context.colorScheme.accentColor,
                        width: 1,
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(UiUtils.borderRadiusOf10),
                        ),
                        child: CustomCachedNetworkImage(
                          imageUrl: widget.promocode!.image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: CustomInkWellContainer(
                  onTap: _chooseImage,
                  child: SetDottedBorderWithHint(
                    height: 100,
                    width: MediaQuery.sizeOf(context).width - 35,
                    radius: 7,
                    str: 'chooseImgLbl'.translate(context: context),
                    strPrefix: '',
                    borderColor: Theme.of(context).colorScheme.blackColor,
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(3.0),
              child: GestureDetector(
                onTap: _chooseImage,
                child: Stack(
                  children: [
                    SizedBox(
                      height: 200,
                      width: MediaQuery.sizeOf(context).width,
                      child: Image.file(image),
                    ),
                    SizedBox(
                      height: 210,
                      width: MediaQuery.sizeOf(context).width - 5,
                      child: DashedRect(
                        color: Theme.of(context).colorScheme.blackColor,
                        strokeWidth: 2.0,
                        gap: 4.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  labelText: 'startDateLbl'.translate(context: context),
                  controller: startDtController,
                  currentFocusNode: startDtFocus,
                  nextFocusNode: endDtFocus,
                  validator: (String? value) =>
                      Validator.nullCheck(context, value),
                  callback: () =>
                      onDateTap(isStartDate: true, startDtController),
                  isReadOnly: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextFormField(
                  labelText: 'endDateLbl'.translate(context: context),
                  controller: endDtController,
                  currentFocusNode: endDtFocus,
                  nextFocusNode: minOrderAmtFocus,
                  callback: () {
                    if (startDtController.text.isEmpty) {
                      FocusScope.of(context).unfocus();
                      UiUtils.showMessage(
                        context,
                        'selectStartDateFirst',
                        ToastificationType.warning,
                      );
                      return;
                    }
                    onDateTap(endDtController, isStartDate: false);
                  },
                  validator: (String? value) =>
                      Validator.nullCheck(context, value),
                  isReadOnly: true,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  labelText: 'minOrderAmtLbl'.translate(context: context),
                  controller: minOrderAmtController,
                  allowOnlySingleDecimalPoint: true,
                  currentFocusNode: minOrderAmtFocus,
                  nextFocusNode: noOfUserFocus,
                  validator: (String? value) =>
                      Validator.nullCheck(context, value, nonZero: true),
                  textInputType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextFormField(
                  labelText: 'noOfUserLbl'.translate(context: context),
                  controller: noOfUserController,
                  currentFocusNode: noOfUserFocus,
                  nextFocusNode: discountFocus,
                  inputFormatters: UiUtils.allowOnlyDigits(),
                  textInputType: TextInputType.number,
                  validator: (String? value) =>
                      Validator.nullCheck(context, value, nonZero: true),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  labelText: 'discountLbl'.translate(context: context),
                  controller: discountController,
                  textInputType: TextInputType.phone,
                  allowOnlySingleDecimalPoint: true,
                  currentFocusNode: discountFocus,
                  nextFocusNode: discountTypeFocus,
                  validator: (String? value) =>
                      Validator.nullCheck(context, value, nonZero: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextFormField(
                  isReadOnly: true,
                  suffixIcon: const Icon(Icons.arrow_drop_down_outlined),
                  labelText: 'discTypeLbl'.translate(context: context),
                  controller: discountTypeController,
                  validator: (String? value) {
                    if (selectedDiscountType == null) {
                      return 'chooseDiscountType'.translate(context: context);
                    }
                    return null;
                  },
                  currentFocusNode: discountTypeFocus,
                  nextFocusNode: maxDiscFocus,
                  callback: () async {
                    final List<Map<String, dynamic>> values = [
                      {
                        'id': 'percentage',
                        'title': 'percentage'.translate(context: context),
                        "isSelected":
                            selectedDiscountType?['value'] == "percentage",
                      },
                      {
                        'id': 'amount',
                        'title': 'amount'.translate(context: context),
                        "isSelected":
                            selectedDiscountType?['value'] == "amount",
                      },
                    ];
                    UiUtils.showModelBottomSheets(
                      context: context,
                      child: SelectableListBottomSheet(
                        bottomSheetTitle: "discTypeLbl",
                        itemList: values,
                      ),
                    ).then((value) {
                      if (value != null) {
                        discountTypeController.text = value['selectedItemName'];

                        selectedDiscountType = discountTypesFilter
                            .where(
                              (Map element) =>
                                  element['value'] == value["selectedItemId"],
                            )
                            .toList()[0];
                        setState(() {});
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  labelText: 'maxDiscAmtLbl'.translate(context: context),
                  controller: maxDiscController,
                  currentFocusNode: maxDiscFocus,
                  nextFocusNode: noOfRepeatUsage,
                  allowOnlySingleDecimalPoint: true,
                  textInputType: TextInputType.number,
                  validator: (String? value) {
                    return Validator.nullCheck(context, value, nonZero: true);
                  },
                ),
              ),
              if (isRepeatUsage) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextFormField(
                    labelText: 'noOfRepeatUsage'.translate(context: context),
                    controller: noOfRepeatUsageController,
                    currentFocusNode: noOfRepeatUsage,
                    inputFormatters: UiUtils.allowOnlyDigits(),
                    forceUnFocus: true,
                    validator: (String? p0) => Validator.nullCheck(context, p0),
                    textInputType: TextInputType.number,
                  ),
                ),
              ],
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CustomCheckIconTextButton(
                  onTap: () {
                    isRepeatUsage = !isRepeatUsage;
                    setState(() {});
                  },
                  isSelected: isRepeatUsage,
                  title: 'repeatUsageLbl'.translate(context: context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomCheckIconTextButton(
                  onTap: () {
                    isStatus = !isStatus;
                    setState(() {});
                  },
                  isSelected: isStatus,
                  title: 'statusLbl'.translate(context: context),
                ),
              ),
            ],
          ),
          // Extra spacing to ensure buttons are visible above the bottom button
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Future<void> onDateTap(
    TextEditingController dateInput, {
    required bool isStartDate,
  }) async {
    final DateTime? initialDate = isStartDate
        ? null
        : DateTime.parse('$selectedStartDate 00:00:00.000');

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: initialDate ?? DateTime.now().subtract(Duration.zero), //1
      lastDate: DateTime.now().add(
        const Duration(days: UiUtils.noOfDaysAllowToCreatePromoCode),
      ),
    );

    if (pickedDate != null) {
      final String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      if (isStartDate) {
        selectedStartDate = formattedDate;
      } else {
        selectedEndDate = formattedDate;
      }
      setState(() {
        dateInput.text = formattedDate.formatDate();
      });
    }
  }

  Widget setTitleAndSwitch({
    required Function()? onTap,
    required String titleText,
    required bool isAllowed,
  }) {
    return CustomInkWellContainer(
      showSplashEffect: false,
      onTap: () {
        onTap?.call();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: CustomText(
              titleText,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.blackColor,
            ),
          ),
          CustomSwitch(
            thumbColor: isAllowed ? Colors.green : Colors.red,
            value: isAllowed,
            onChanged: (bool val) {
              onTap?.call();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Padding bottomNavigation() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 5,
        left: 15,
        right: 15,
      ),
      child: CustomRoundedButton(
        widthPercentage: 1,
        textSize: 14,
        height: 55,
        titleColor: AppColors.whiteColors,
        onTap:
            (context.watch<CreatePromocodeCubit>().state
                is CreatePromocodeInProgress)
            ? () {}
            : onAddPromoCode,
        backgroundColor: Theme.of(context).colorScheme.accentColor,
        buttonTitle: widget.promocode?.id != null
            ? 'savePromoCodeTitleLbl'.translate(context: context)
            : 'addPromoCodeTitleLbl'.translate(context: context),
        showBorder: true,
        child:
            (context.watch<CreatePromocodeCubit>().state
                is CreatePromocodeInProgress)
            ? CustomCircularProgressIndicator(color: AppColors.whiteColors)
            : null,
      ),
    );
  }
}
