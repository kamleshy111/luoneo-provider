import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  CategoriesState createState() => CategoriesState();

  static Route<Categories> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (BuildContext context) => FetchCategoriesCubit(),
          ),
        ],
        child: const Categories(),
      ),
    );
  }
}

class CategoriesState extends State<Categories> {
  DateTime currDate = DateTime.now();
  TimeOfDay currTime = TimeOfDay.now();
  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(_pageScrollListen);
  late Map categoryStatus = {
    '0': 'deActive'.translate(context: context),
    '1': 'active'.translate(context: context),
  };
  late List<String> selectedCategoryIds = context
      .read<ProviderDetailsCubit>()
      .getSubscribedCategories();

  void _pageScrollListen() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchCategoriesCubit>().hasMoreCategories()) {
        context.read<FetchCategoriesCubit>().fetchMoreCategories();
      }
    }
  }

  @override
  void initState() {
    context.read<FetchCategoriesCubit>().fetchCategories();
    context.read<ProviderDetailsCubit>().providerDetails;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    categoryStatus = {
      '0': 'deActive'.translate(context: context),
      '1': 'active'.translate(context: context),
    };
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          context.watch<ManageCategoryPreferenceCubit>().state
              is! ManageCategoryPreferenceInProgress,
      child: InterstitialAdWidget(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primaryColor,
          appBar: AppBar(
            elevation: 1,
            backgroundColor: Theme.of(context).colorScheme.secondaryColor,
            surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
            // centerTitle: true,
            title: CustomText(
              'subscribeCategoriesLbl'.translate(context: context),
              color: Theme.of(context).colorScheme.blackColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            leading: CustomBackArrow(
              canGoBack:
                  context.watch<ManageCategoryPreferenceCubit>().state
                      is! ManageCategoryPreferenceInProgress,
            ),
          ),
          bottomSheet: bottomBarWidget(),
          bottomNavigationBar: const BannerAdWidget(),
          body: mainWidget(),
        ),
      ),
    );
  }

  Widget bottomBarWidget() {
    return BlocConsumer<
      ManageCategoryPreferenceCubit,
      ManageCategoryPreferenceState
    >(
      listener: (context, state) {
        if (state is ManageCategoryPreferenceFailure) {
          UiUtils.showMessage(
            context,
            'selectCategory',
            ToastificationType.error,
          );
        } else if (state is ManageCategoryPreferenceSuccess) {
          context
              .read<ProviderDetailsCubit>()
              .updateProviderCustomJobCategories(selectedCategoryIds);

          UiUtils.showMessage(
            context,
            'categoryUpdated',
            ToastificationType.success,
            onMessageClosed: () {
              // Additional actions if needed after success
            },
          );
        }
      },
      builder: (context, state) {
        final bool isLoading = state is ManageCategoryPreferenceInProgress;
        return CustomContainer(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: CustomRoundedButton(
            textSize: 15,
            widthPercentage: 1,
            backgroundColor: Theme.of(context).colorScheme.accentColor,
            buttonTitle: 'subscribeCategoriesLbl'.translate(context: context),
            showBorder: false,
            child: isLoading
                ? Center(
                    child: CustomCircularProgressIndicator(
                      color: AppColors.whiteColors,
                    ),
                  )
                : null,
            onTap: () {
              if (isLoading) {
                return;
              }
              context
                  .read<ManageCategoryPreferenceCubit>()
                  .ManageCategoryPreference(categoryId: selectedCategoryIds);
            },
          ),
        );
      },
    );
  }

  Widget mainWidget() {
    return CustomRefreshIndicator(
      onRefresh: () async {
        context.read<FetchCategoriesCubit>().fetchCategories();
      },
      child: BlocBuilder<FetchCategoriesCubit, FetchCategoriesState>(
        builder: (BuildContext context, FetchCategoriesState state) {
          if (state is FetchCategoriesFailure) {
            return Center(
              child: ErrorContainer(
                onTapRetry: () {
                  context.read<FetchCategoriesCubit>().fetchCategories();
                },
                errorMessage: state.errorMessage.translate(context: context),
              ),
            );
          }

          if (state is FetchCategoriesSuccess) {
            if (state.categories.isEmpty) {
              return NoDataContainer(
                titleKey: 'noDataFound'.translate(context: context),
                subTitleKey: 'noDataFoundSubTitle'.translate(context: context),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              clipBehavior: Clip.none,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  ListView.separated(
                    padding: const EdgeInsets.only(bottom: 60),
                    controller: _pageScrollController,
                    shrinkWrap: true,
                    itemCount: state.categories.length,
                    physics: const NeverScrollableScrollPhysics(),
                    clipBehavior: Clip.none,
                    itemBuilder: (BuildContext context, int index) {
                      final CategoryModel category = state.categories[index];
                      final bool isSelected = selectedCategoryIds.contains(
                        category.id,
                      );

                      return GestureDetector(
                        onTap: () {
                          if (selectedCategoryIds.contains(category.id)) {
                            selectedCategoryIds.remove(category.id);
                          } else {
                            selectedCategoryIds.add(category.id!);
                          }
                          setState(() {});
                        },
                        child: CustomContainer(
                          padding: const EdgeInsetsDirectional.all(10),
                          color: Theme.of(context).colorScheme.secondaryColor,
                          borderRadius: UiUtils.borderRadiusOf10,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  UiUtils.borderRadiusOf5,
                                ),
                                child: CustomCachedNetworkImage(
                                  imageUrl: category.categoryImage!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: CustomText(
                                              category.translatedName!,
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.blackColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 25,
                                          width: 25,
                                          child: CustomCheckBox(
                                            value: isSelected,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                if (selectedCategoryIds
                                                    .contains(category.id)) {
                                                  selectedCategoryIds.remove(
                                                    category.id,
                                                  );
                                                } else {
                                                  selectedCategoryIds.add(
                                                    category.id!,
                                                  );
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    setCommissionAndStatus(
                                      lhs: 'statusLbl'.translate(
                                        context: context,
                                      ),
                                      rhs: categoryStatus[category.status],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 10),
                  ),
                  if (state.isLoadingMoreCategories)
                    CustomCircularProgressIndicator(
                      color: AppColors.whiteColors,
                    ),
                ],
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: 8,
            physics: const NeverScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    height: context.screenHeight * 0.19,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget setCommissionAndStatus({required String lhs, required String rhs}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomText(
            lhs,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.blackColor,
          ),
        ),
        CustomText(
          (lhs == 'adminCommLbl'.translate(context: context))
              ? rhs.formatPercentage()
              : rhs,
          fontWeight: (lhs == 'adminCommLbl'.translate(context: context))
              ? FontWeight.w700
              : FontWeight.w400,
          fontSize: 13,
          color: rhs == 'active'.translate(context: context)
              ? AppColors.greenColor
              : AppColors.redColor,
        ),
      ],
    );
  }
}
