import 'package:flutter/material.dart';
import '../../../../app/generalImports.dart';

class FormSEO extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController seoTitleController;
  final TextEditingController seoDescriptionController;
  final TextEditingController seoKeywordsController;
  final TextEditingController seoSchemaMarkupController;
  final PickImage pickSeoOgImage;
  final FocusNode seoTitleFocus;
  final FocusNode seoDescriptionFocus;
  final FocusNode seoKeywordsFocus;
  final FocusNode seoSchemaMarkupFocus;
  final String pickedSeoOgImage;
  final Function showCameraAndGalleryOption;
  final ServiceModel? service;
  final BuildContext context;
  // final Function(String) onSeoOgImagePick;
  final Map<String, dynamic> pickedLocalImages;

  const FormSEO({
    Key? key,
    required this.formKey,
    required this.seoTitleController,
    required this.seoDescriptionController,
    required this.seoKeywordsController,
    required this.seoSchemaMarkupController,
    required this.pickSeoOgImage,
    required this.seoTitleFocus,
    required this.seoDescriptionFocus,
    required this.seoKeywordsFocus,
    required this.seoSchemaMarkupFocus,
    required this.pickedSeoOgImage,
    required this.showCameraAndGalleryOption,
    required this.service,
    required this.context,
    // required this.onSeoOgImagePick,
    required this.pickedLocalImages,
  }) : super(key: key);

  @override
  State<FormSEO> createState() => _FormSEOState();
}

class _FormSEOState extends State<FormSEO> {
  List<String> keywordsList = [];
  List<Map<String, dynamic>> finalKeywordsList = [];
  TextEditingController keywordInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize keywords from existing data if any
    if (widget.seoKeywordsController.text.isNotEmpty) {
      keywordsList = widget.seoKeywordsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      _updateFinalKeywordsList();
    }
  }

  @override
  void dispose() {
    keywordInputController.dispose();
    super.dispose();
  }

  void _updateFinalKeywordsList() {
    finalKeywordsList.clear();
    for (int i = 0; i < keywordsList.length; i++) {
      finalKeywordsList.add({'id': i, 'text': keywordsList[i]});
    }
    // Update the main controller with comma-separated values
    widget.seoKeywordsController.text = keywordsList.join(', ');
    setState(() {});
  }

  void _addKeyword() {
    if (keywordInputController.text.trim().isNotEmpty) {
      keywordsList.add(keywordInputController.text.trim());
      keywordInputController.clear();
      _updateFinalKeywordsList();
      FocusScope.of(context).unfocus();
    }
  }

  void _removeKeyword(int index) {
    if (keywordsList.isEmpty) {
      keywordsList.clear();
      finalKeywordsList.clear();
      widget.seoKeywordsController.clear();
      setState(() {});
      return;
    }
    keywordsList.removeAt(index);
    if (keywordsList.isEmpty) {
      finalKeywordsList.clear();
      widget.seoKeywordsController.clear();
    } else {
      _updateFinalKeywordsList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          CustomTextFormField(
            bottomPadding: 15,
            labelText: 'seoTitle'.translate(context: context),
            controller: widget.seoTitleController,
            currentFocusNode: widget.seoTitleFocus,
            nextFocusNode: widget.seoDescriptionFocus,
            // prefix: CustomSvgPicture(
            //   svgImage: AppAssets.search,
            //   color: context.colorScheme.accentColor,
            //   boxFit: BoxFit.scaleDown,
            // ),
            hintText: 'enterSeoTitle'.translate(context: context),
            // Optional field - no validator
          ),
          CustomTextFormField(
            labelText: 'seoDescription'.translate(context: context),
            controller: widget.seoDescriptionController,
            expands: true,
            minLines: 5,
            currentFocusNode: widget.seoDescriptionFocus,
            // validator: (String? value) {
            //   return Validator.nullCheck(context, value);
            // },
            bottomPadding: 20,
            textInputType: TextInputType.multiline,
          ),
          CustomTextFormField(
            labelText: 'seoKeywords'.translate(context: context),
            controller: keywordInputController,
            currentFocusNode: widget.seoKeywordsFocus,
            forceUnFocus: false,
            bottomPadding: finalKeywordsList.isEmpty ? 15 : 0,
            // prefix: CustomSvgPicture(
            //   svgImage: AppAssets.star,
            //   color: context.colorScheme.accentColor,
            //   boxFit: BoxFit.scaleDown,
            // ),
            hintText: 'enterSeoKeywords'.translate(context: context),
            suffixIcon: IconButton(
              onPressed: _addKeyword,
              icon: Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.accentColor,
              ),
            ),
            onSubmit: _addKeyword,
            callback: () {},
          ),
          Wrap(
            children: finalKeywordsList.map((Map<String, dynamic> item) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 10, top: 5),
                child: SizedBox(
                  height: 35,
                  child: Chip(
                    backgroundColor: Theme.of(context).colorScheme.primaryColor,
                    label: Text(item['text']),
                    onDeleted: () {
                      _removeKeyword(item['id']);
                    },
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.blackColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        UiUtils.borderRadiusOf10,
                      ),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.lightGreyColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (keywordsList.isNotEmpty) const SizedBox(height: 15),
          CustomText(
            'seoKeywordsHint'.translate(context: context),
            fontSize: 12,
            color: context.colorScheme.lightGreyColor,
            fontWeight: FontWeight.w400,
          ),
          const SizedBox(height: 15),
          CustomTextFormField(
            bottomPadding: 15,
            labelText: 'seoSchemaMarkup'.translate(context: context),
            controller: widget.seoSchemaMarkupController,
            currentFocusNode: widget.seoSchemaMarkupFocus,
            // prefix: CustomSvgPicture(
            //   svgImage: AppAssets.note,
            //   color: context.colorScheme.accentColor,
            //   boxFit: BoxFit.scaleDown,
            // ),
            hintText: 'enterSeoSchemaMarkup'.translate(context: context),
            textInputType: TextInputType.multiline,
            minLines: 4,
            expands: true,
            // Optional field - no validator
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Expanded(child: Divider(thickness: 0.5)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CustomText(
                  'seoOgImage'.translate(context: context),
                  color: Theme.of(context).colorScheme.blackColor,
                ),
              ),
              const Expanded(child: Divider(thickness: 0.5)),
            ],
          ),
          const SizedBox(height: 15),
          _seoOgImagePicker(
            context,
            imageController: widget.pickSeoOgImage,
            oldImage: widget.service?.seoOgImage ?? '',
            hintLabel: 'uploadSeoOgImage'.translate(context: context),
            imageType: 'seoOgImage',
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _seoOgImagePicker(
    BuildContext context, {
    required PickImage imageController,
    required String oldImage,
    required String hintLabel,
    required String imageType,
  }) {
    return imageController.ListenImageChange((BuildContext context, image) {
      if (image == null) {
        // Check if there's a locally picked image first
        if (widget.pickedLocalImages[imageType] != null &&
            widget.pickedLocalImages[imageType] != '') {
          return GestureDetector(
            onTap: () {
              widget.showCameraAndGalleryOption(
                imageController: imageController,
                title: hintLabel,
              );
            },
            child: CustomContainer(
              borderRadius: UiUtils.borderRadiusOf10,
              height: 150,
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(UiUtils.borderRadiusOf10),
                ),
                child: Image.file(
                  File(widget.pickedLocalImages[imageType]!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }

        if (oldImage.isNotEmpty && oldImage != 'null') {
          return GestureDetector(
            onTap: () {
              widget.showCameraAndGalleryOption(
                imageController: imageController,
                title: hintLabel,
              );
            },
            child: Stack(
              children: [
                // Background image
                CustomContainer(
                  borderRadius: UiUtils.borderRadiusOf10,
                  height: 150,
                  width: MediaQuery.of(context).size.width,
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
                // Transparent overlay with upload UI
                CustomContainer(
                  borderRadius: UiUtils.borderRadiusOf10,
                  color: context.colorScheme.accentColor.withAlpha(2),
                  height: 150,
                  width: MediaQuery.of(context).size.width,
                  border: Border.all(
                    color: context.colorScheme.accentColor,
                    width: 1,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomSvgPicture(
                        svgImage: AppAssets.camera,
                        color: context.colorScheme.accentColor,
                        height: 30,
                        width: 30,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return CustomInkWellContainer(
          onTap: () {
            widget.showCameraAndGalleryOption(
              imageController: imageController,
              title: hintLabel,
            );
          },
          child: CustomContainer(
            borderRadius: UiUtils.borderRadiusOf10,
            color: context.colorScheme.accentColor.withAlpha(20),
            height: 150,
            width: MediaQuery.of(context).size.width,
            border: Border.all(
              color: context.colorScheme.accentColor,
              width: 1,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomSvgPicture(
                  svgImage: AppAssets.camera,
                  color: context.colorScheme.accentColor,
                  height: 30,
                  width: 30,
                ),
                const SizedBox(height: 10),
                CustomText(
                  hintLabel,
                  color: context.colorScheme.accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        );
      }

      // Update pickedLocalImages when new image is selected
      widget.pickedLocalImages[imageType] = image?.path;

      return GestureDetector(
        onTap: () {
          widget.showCameraAndGalleryOption(
            imageController: imageController,
            title: hintLabel,
          );
        },
        child: CustomContainer(
          borderRadius: UiUtils.borderRadiusOf10,
          height: 150,
          width: MediaQuery.of(context).size.width,
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
}
