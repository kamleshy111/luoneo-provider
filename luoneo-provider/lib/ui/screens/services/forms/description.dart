import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:edemand_partner/app/generalImports.dart';

class Form4 extends StatefulWidget {
  const Form4({
    super.key,
    required this.serviceId,
    required this.controller,
    required this.longDescription,
    // Multi-language support
    this.languages,
    this.defaultLanguage,
    this.selectedLanguageIndex,
    this.onLanguageChanged,
    this.longDescriptionControllers,
  });

  final HtmlEditorController controller;
  final String? longDescription;
  final String? serviceId;

  // Multi-language support
  final List<AppLanguage>? languages;
  final AppLanguage? defaultLanguage;
  final int? selectedLanguageIndex;
  final Function(int)? onLanguageChanged;
  final Map<String, TextEditingController>? longDescriptionControllers;

  @override
  State<Form4> createState() => Form4State();
}

class Form4State extends State<Form4> with WidgetsBindingObserver {
  Timer? _autoSaveTimer;
  Timer? _contentChangeDebounceTimer;
  bool _isChangingLanguage = false;
  bool _isLoadingContent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startAutoSaveTimer();

    // Load initial content after widget is built with multiple attempts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentLanguageContentWithRetry(0);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoSaveTimer?.cancel();
    _contentChangeDebounceTimer?.cancel();
    _saveCurrentContent(); // Save before disposing
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Save content when app goes to background or keyboard closes
      _saveCurrentContent();
    }
  }

  void _startAutoSaveTimer() {
    // Increased auto-save interval to reduce conflicts during typing
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_isChangingLanguage) {
        _saveCurrentContent();
      }
    });
  }

  // Public method to force content restoration and UI update
  Future<void> forceRestoreAndUpdateUI() async {
    await _loadCurrentLanguageContent();
    if (mounted) {
      setState(() {});
    }
  }

  // Method to force UI refresh
  void forceUIRefresh() {
    if (mounted) {
      setState(() {});
    }
  }

  // Debounced content change to prevent conflicts during typing
  void _debounceContentChange(String? content) {
    // Cancel previous timer if exists
    _contentChangeDebounceTimer?.cancel();

    // Set new timer with 500ms delay
    _contentChangeDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted && !_isChangingLanguage) {
        // Save to parent controller immediately for better preservation
        if (widget.languages != null &&
            widget.selectedLanguageIndex != null &&
            widget.selectedLanguageIndex! < widget.languages!.length &&
            widget.longDescriptionControllers != null) {
          final langCode =
              widget.languages![widget.selectedLanguageIndex!].languageCode;
          widget.longDescriptionControllers![langCode]?.text = content ?? '';
        }
      }
    });
  }

  // Method to handle widget updates (when parent data changes)
  @override
  void didUpdateWidget(Form4 oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if language selection changed
    if (oldWidget.selectedLanguageIndex != widget.selectedLanguageIndex) {
      _isChangingLanguage = true;

      // Cancel any pending content changes during language switch
      _contentChangeDebounceTimer?.cancel();

      // Load content for new language with single smooth transition
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadCurrentLanguageContentSmoothly();
      });
    }

    // Check if controllers were updated externally (only if not changing language)
    if (!_isChangingLanguage &&
        oldWidget.longDescriptionControllers !=
            widget.longDescriptionControllers) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadCurrentLanguageContentSmoothly();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateServiceCubit, CreateServiceCubitState>(
      listener: (BuildContext context, CreateServiceCubitState state) {
        if (state is CreateServiceFailure) {
          UiUtils.showMessage(
            context,
            state.errorMessage,
            ToastificationType.error,
          );
        }

        if (state is CreateServiceSuccess) {
          widget.serviceId != null
              ? context.read<FetchServicesCubit>().editService(state.service)
              : context.read<FetchServicesCubit>().addServiceToCubit(
                  state.service,
                );
          // context.read<FetchServicesCubit>().editService(state.service);
          UiUtils.showMessage(
            context,
            'serviceSavedSuccessfully',
            ToastificationType.success,
            onMessageClosed: () {
              Navigator.pop(context, state.service);
            },
          );
        }
      },
      builder: (BuildContext context, CreateServiceCubitState state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primaryColor,
          body: SafeArea(
            child: Column(
              children: [
                // Language Tabs
                if (widget.languages != null &&
                    widget.languages!.isNotEmpty) ...[
                  Container(
                    margin: const EdgeInsets.only(
                      bottom: 20,
                      left: 15,
                      right: 15,
                      top: 15,
                    ),
                    child: Row(
                      children: widget.languages!.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final AppLanguage language = entry.value;
                        final bool isSelected =
                            widget.selectedLanguageIndex == index;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (widget.selectedLanguageIndex != index &&
                                  !_isLoadingContent) {
                                _isLoadingContent = true;

                                // Save current content before switching
                                await _saveCurrentContent();

                                // Force save to ensure content is preserved
                                await _saveCurrentContent();

                                // Change language in parent immediately
                                widget.onLanguageChanged?.call(index);

                                // Load content for new language (will happen in didUpdateWidget)
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.accentColor
                                    : AppColors.lightPrimaryColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.accentColor
                                      : Theme.of(
                                          context,
                                        ).colorScheme.lightGreyColor,
                                ),
                              ),
                              child: Text(
                                language.languageName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.lightPrimaryColor
                                      : Theme.of(
                                          context,
                                        ).colorScheme.blackColor,
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

                // HTML Editor - Full Page with bottom spacing
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                      bottom: 10, // 10px spacing from bottom button
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Focus(
                                onFocusChange: (hasFocus) {
                                  if (!hasFocus) {
                                    // Save content when HTML editor loses focus
                                    _saveCurrentContent();
                                    _forceSaveCurrentContent();
                                  }
                                },
                                child: GestureDetector(
                                  onTap: () {
                                    // Trigger auto-save when user interacts with editor
                                    _saveCurrentContent();
                                    _forceSaveCurrentContent();
                                  },
                                  child: CustomHTMLEditor(
                                    key: const ValueKey('html_editor_stable'),
                                    controller: widget.controller,
                                    initialHTML: _getCurrentLanguageContent(),
                                    hint: _getHintText(),
                                    onContentChanged: (content) {
                                      // Add debouncing to prevent conflicts during rapid changes
                                      _debounceContentChange(content);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper methods for multi-language support
  String? _getCurrentLanguageContent() {
    if (widget.languages == null ||
        widget.languages!.isEmpty ||
        widget.selectedLanguageIndex == null ||
        widget.longDescriptionControllers == null) {
      return widget.longDescription;
    }

    final languageCode =
        widget.languages![widget.selectedLanguageIndex!].languageCode;
    final content =
        widget.longDescriptionControllers?[languageCode]?.text ?? '';
    return content;
  }

  String _getHintText() {
    if (widget.languages == null ||
        widget.languages!.isEmpty ||
        widget.selectedLanguageIndex == null) {
      return 'describeServiceInDetail'.translate(context: context);
    }

    final language = widget.languages![widget.selectedLanguageIndex!];
    final isDefaultLanguage =
        language.languageCode == widget.defaultLanguage?.languageCode;

    if (isDefaultLanguage) {
      // Long description is optional for all languages including default
      return 'describeServiceInDetail'.translate(context: context);
    } else {
      return '${'describeServiceInDetail'.translate(context: context)} (${language.languageName})';
    }
  }

  Future<void> _saveCurrentContent() async {
    try {
      final currentContent = await widget.controller.getText();

      if (widget.languages != null &&
          widget.selectedLanguageIndex != null &&
          widget.selectedLanguageIndex! < widget.languages!.length) {
        final langCode =
            widget.languages![widget.selectedLanguageIndex!].languageCode;

        // Save content to the controller for current language
        if (widget.longDescriptionControllers != null) {
          widget.longDescriptionControllers![langCode]?.text = currentContent;
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Force save current content to ensure preservation during language switching
  Future<void> _forceSaveCurrentContent() async {
    await _saveCurrentContent();
  }

  // Smoother language content loading without aggressive retries
  Future<void> _loadCurrentLanguageContentSmoothly() async {
    try {
      if (widget.languages != null &&
          widget.languages!.isNotEmpty &&
          widget.selectedLanguageIndex != null &&
          widget.selectedLanguageIndex! < widget.languages!.length &&
          widget.longDescriptionControllers != null) {
        final langCode =
            widget.languages![widget.selectedLanguageIndex!].languageCode;
        final content =
            widget.longDescriptionControllers?[langCode]?.text ?? '';

        // Set content with single attempt, no aggressive retries
        widget.controller.setText(content);

        // Reset language changing flag immediately to prevent further UI updates
        _isChangingLanguage = false;
        _isLoadingContent = false;

        // Single UI update after content is set
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      _isChangingLanguage = false;
      _isLoadingContent = false;
    }
  }

  // Enhanced method with retry mechanism for loading content
  Future<void> _loadCurrentLanguageContentWithRetry(int attemptNumber) async {
    const maxAttempts = 5;

    if (attemptNumber >= maxAttempts) {
      return;
    }

    try {
      if (widget.languages != null &&
          widget.languages!.isNotEmpty &&
          widget.selectedLanguageIndex != null &&
          widget.selectedLanguageIndex! < widget.languages!.length &&
          widget.longDescriptionControllers != null) {
        final langCode =
            widget.languages![widget.selectedLanguageIndex!].languageCode;
        final content =
            widget.longDescriptionControllers?[langCode]?.text ?? '';

        // Set the content in the HTML editor with retry mechanism
        await _setHTMLEditorContent(content);

        // Verify content was actually set
        final verifyContent = await widget.controller.getText();
        if (verifyContent != content && attemptNumber < maxAttempts - 1) {
          final delay = Duration(milliseconds: 300 * (attemptNumber + 1));
          Future.delayed(delay, () {
            if (mounted) {
              _loadCurrentLanguageContentWithRetry(attemptNumber + 1);
            }
          });
          return;
        }
      }
    } catch (e) {
      if (attemptNumber < maxAttempts - 1) {
        final delay = Duration(milliseconds: 300 * (attemptNumber + 1));
        Future.delayed(delay, () {
          if (mounted) {
            _loadCurrentLanguageContentWithRetry(attemptNumber + 1);
          }
        });
      }
    }
  }

  Future<void> _loadCurrentLanguageContent() async {
    try {
      if (widget.languages != null &&
          widget.languages!.isNotEmpty &&
          widget.selectedLanguageIndex != null &&
          widget.selectedLanguageIndex! < widget.languages!.length &&
          widget.longDescriptionControllers != null) {
        final langCode =
            widget.languages![widget.selectedLanguageIndex!].languageCode;
        final content =
            widget.longDescriptionControllers?[langCode]?.text ?? '';

        // Set the content in the HTML editor with retry mechanism
        await _setHTMLEditorContent(content);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Helper method to set HTML editor content with minimal UI updates
  Future<void> _setHTMLEditorContent(String content) async {
    try {
      // Set the new content directly without clearing first
      widget.controller.setText(content);

      // Single UI update after content is set
      if (mounted) {
        setState(() {});
      }

      // Brief wait for the HTML editor to process
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      // Handle error silently
    }
  }
}
