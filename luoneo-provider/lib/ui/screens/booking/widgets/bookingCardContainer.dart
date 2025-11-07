import 'package:flutter/material.dart';

import '../../../../app/generalImports.dart';

class BookingCardContainer extends StatefulWidget {
  const BookingCardContainer({
    super.key,
    required this.bookingModel,
    this.isFrom,
  });

  final BookingsModel bookingModel;
  final String? isFrom;

  @override
  State<BookingCardContainer> createState() => _BookingCardContainerState();
}

class _BookingCardContainerState extends State<BookingCardContainer> {
  BookingsModel? bookingModel;

  @override
  void initState() {
    bookingModel = widget.bookingModel;
    super.initState();
  }

  Widget invoiceAndStatus(BookingsModel bookingModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CustomText(
              'invoiceNumber'.translate(context: context),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            const SizedBox(width: 5),
            CustomText(
              bookingModel.invoiceNo ?? '',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: context.colorScheme.accentColor,
            ),
          ],
        ),
        Row(
          children: [
            CustomText(
              bookingModel.translatedStatus.toString().capitalize(),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: UiUtils.getStatusColor(
                context: context,
                statusVal: bookingModel.status.toString(),
              ),
            ),
            const SizedBox(width: 5),
            CustomSvgPicture(
              svgImage: AppAssets.arrowNext,
              color: context.colorScheme.lightGreyColor,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context
        .watch<FetchSystemSettingsCubit>()
        .state; // Use watch for UI updates
    final bool systemWisePostbooking = (state is FetchSystemSettingsSuccess)
        ? state.generalSettings.allowPostBookingChat ?? false
        : false;

    final bool systemWisePrebooking = (state is FetchSystemSettingsSuccess)
        ? state.generalSettings.allowPreBookingChat ?? false
        : false;

    final bool isPreBookingChat =
        context
            .read<ProviderDetailsCubit>()
            .state
            .providerDetails
            .providerInformation!
            .isPreBookingChatAllowed ==
        '1';
    final bool isPostBookingChat =
        context
            .read<ProviderDetailsCubit>()
            .state
            .providerDetails
            .providerInformation!
            .isPostBookingChatAllowed ==
        '1';
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.bookingDetails,
          arguments: {
            'bookingsModel': bookingModel,
            'cubit': context.read<UpdateBookingStatusCubit>(),
          },
        );
      },
      child: CustomContainer(
        padding: const EdgeInsetsDirectional.all(10),
        borderRadius: UiUtils.borderRadiusOf10,
        color: Theme.of(context).colorScheme.secondaryColor,
        border: Border.all(
          color: context.colorScheme.lightGreyColor,
          width: 0.2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            invoiceAndStatus(bookingModel!),
            CustomDivider(
              color: context.colorScheme.lightGreyColor,
              thickness: 0.2,
            ),
            if (bookingModel!.addressId != "0")
              Row(
                children: [
                  CustomSvgPicture(
                    svgImage: AppAssets.mapPic,
                    color: context.colorScheme.accentColor,
                    height: 16,
                    width: 16,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: CustomText(bookingModel!.address ?? '', maxLines: 1),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            DateAndTime(bookingModel: bookingModel!),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CustomText(
                bookingModel!.services![0].serviceTitle ?? '',
                fontWeight: FontWeight.w500,
                maxLines: 1,
              ),
            ),
            if (widget.isFrom == "home") const Spacer(),
            if (bookingModel!.services!.length >= 2) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: CustomText(
                  bookingModel!.services![1].serviceTitle ?? '',
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                ),
              ),
              if (bookingModel!.services!.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: CustomText(
                    "+${bookingModel!.services!.length - 2} ${'moreServices'.translate(context: context)}",
                    fontWeight: FontWeight.w500,
                    color: context.colorScheme.accentColor,
                    showUnderline: true,
                    underlineOrLineColor: context.colorScheme.accentColor,
                  ),
                ),
            ],
            const SizedBox(height: 8),
            CustomText(
              (bookingModel!.finalTotal ?? "0")
                  .replaceAll(',', '')
                  .toString()
                  .priceFormat(context),
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
            CustomDivider(
              color: context.colorScheme.lightGreyColor,
              thickness: 0.2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        'customer'.translate(context: context),
                        color: context.colorScheme.lightGreyColor,
                        fontSize: 12,
                      ),
                      const SizedBox(height: 5),
                      CustomText(
                        bookingModel!.customer ?? '',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                bookingModel!.status.toString() == 'awaiting'
                    ? BlocConsumer<
                        UpdateBookingStatusCubit,
                        UpdateBookingStatusState
                      >(
                        listener:
                            (
                              BuildContext context,
                              UpdateBookingStatusState updateState,
                            ) {
                              if (updateState is UpdateBookingStatusSuccess) {
                                if (updateState.error == 'true') {
                                  return;
                                }

                                context
                                    .read<FetchBookingsCubit>()
                                    .updateBookingDetailsLocally(
                                      bookingID: updateState.orderId.toString(),
                                      bookingStatus: updateState.status,
                                      listOfUploadedImages:
                                          updateState.imagesList,
                                    );
                              }
                            },
                        builder:
                            (
                              BuildContext context,
                              UpdateBookingStatusState updateState,
                            ) {
                              return Row(
                                children: [
                                  CustomInkWellContainer(
                                    borderRadius: BorderRadius.circular(5),
                                    onTap: () {
                                      if (updateState
                                          is UpdateBookingStatusInProgress) {
                                        return;
                                      }
                                      context
                                          .read<UpdateBookingStatusCubit>()
                                          .updateBookingStatus(
                                            orderId: int.parse(
                                              bookingModel!.id!,
                                            ),
                                            customerId: int.parse(
                                              bookingModel!.customerId!,
                                            ),
                                            status: 'cancelled',
                                            otp: '',
                                          );
                                    },
                                    child: CustomContainer(
                                      height: 36,
                                      width: 36,
                                      padding: const EdgeInsets.all(5),
                                      borderRadius: 5,
                                      color: AppColors.redColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      child: CustomSvgPicture(
                                        svgImage: AppAssets.close,
                                        color:
                                            updateState
                                                is UpdateBookingStatusInProgress
                                            ? AppColors.redColor.withValues(
                                                alpha: 0.3,
                                              )
                                            : AppColors.redColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  CustomInkWellContainer(
                                    borderRadius: BorderRadius.circular(5),
                                    onTap: () {
                                      if (updateState
                                          is UpdateBookingStatusInProgress) {
                                        return;
                                      }
                                      context
                                          .read<UpdateBookingStatusCubit>()
                                          .updateBookingStatus(
                                            orderId: int.parse(
                                              bookingModel!.id!,
                                            ),
                                            customerId: int.parse(
                                              bookingModel!.customerId!,
                                            ),
                                            status: 'confirmed',
                                            otp: '',
                                          );
                                    },
                                    child: CustomContainer(
                                      padding: const EdgeInsets.all(5),
                                      height: 36,
                                      width: 36,
                                      borderRadius: 5,
                                      color: AppColors.greenColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      child: CustomSvgPicture(
                                        svgImage: AppAssets.check,
                                        color:
                                            updateState
                                                is UpdateBookingStatusInProgress
                                            ? AppColors.greenColor.withValues(
                                                alpha: 0.3,
                                              )
                                            : AppColors.greenColor,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                      )
                    : Row(
                        children: [
                          CustomInkWellContainer(
                            borderRadius: BorderRadius.circular(5),
                            onTap: () {
                              if (systemWisePrebooking &&
                                  systemWisePostbooking &&
                                  isPreBookingChat &&
                                  isPostBookingChat) {
                                Navigator.pushNamed(
                                  context,
                                  Routes.chatMessages,
                                  arguments: {
                                    "chatUser": ChatUser(
                                      id: bookingModel!.customerId ?? "-",
                                      bookingId: bookingModel!.id.toString(),
                                      bookingStatus: bookingModel!.status
                                          .toString(),
                                      name: bookingModel!.customer.toString(),
                                      receiverType: "2",
                                      unReadChats: 0,
                                      profile: bookingModel!.profileImage,
                                      senderId:
                                          context
                                              .read<ProviderDetailsCubit>()
                                              .providerDetails
                                              .user
                                              ?.id ??
                                          "0",
                                    ),
                                  },
                                );
                              }
                            },
                            child: CustomContainer(
                              height: 36,
                              width: 36,
                              borderRadius: UiUtils.borderRadiusOf5,
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              color:
                                  systemWisePrebooking &&
                                      systemWisePostbooking &&
                                      isPreBookingChat &&
                                      isPostBookingChat
                                  ? Theme.of(context).colorScheme.accentColor
                                        .withValues(alpha: 0.1)
                                  : context.colorScheme.lightGreyColor
                                        .withValues(alpha: 0.1),
                              child: CustomSvgPicture(
                                svgImage: AppAssets.drChat,
                                color:
                                    systemWisePrebooking &&
                                        systemWisePostbooking &&
                                        isPreBookingChat &&
                                        isPostBookingChat
                                    ? Theme.of(context).colorScheme.accentColor
                                    : context.colorScheme.lightGreyColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          CustomInkWellContainer(
                            borderRadius: BorderRadius.circular(5),
                            onTap: () {
                              if (bookingModel!.status.toString() ==
                                      "cancelled" ||
                                  bookingModel!.status.toString() ==
                                      "completed") {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Text(
                                        'youCantCallToProviderMessage'
                                            .translate(context: context),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'ok'.translate(context: context),
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.accentColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                try {
                                  launchUrl(
                                    Uri.parse(
                                      "tel:${bookingModel!.customerNo}",
                                    ),
                                  );
                                } catch (e) {
                                  UiUtils.showMessage(
                                    context,
                                    'somethingWentWrongTitle',
                                    ToastificationType.error,
                                  );
                                }
                              }
                            },
                            child: CustomContainer(
                              height: 36,
                              width: 36,
                              borderRadius: 5,
                              color: Theme.of(
                                context,
                              ).colorScheme.accentColor.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.call,
                                color: Theme.of(
                                  context,
                                ).colorScheme.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
