import 'package:edemand_partner/ui/widgets/bottomSheets/layouts/additionalChargesBottomSheet.dart';
import 'package:edemand_partner/ui/widgets/dialog/layouts/verifyOTPDialog.dart';
import 'package:edemand_partner/ui/screens/booking/widgets/customerInfoWidget.dart';
import 'package:edemand_partner/ui/screens/booking/widgets/statusAndInvoiceWidget.dart';
import 'package:edemand_partner/ui/screens/booking/widgets/bookingDateAndTimeWidget.dart';
import 'package:edemand_partner/ui/screens/booking/widgets/uploadedProofWidget.dart';
import 'package:edemand_partner/ui/screens/booking/widgets/serviceDetailsWidget.dart';
import 'package:edemand_partner/ui/screens/booking/widgets/notesWidget.dart';
import 'package:edemand_partner/ui/screens/booking/widgets/priceSectionWidget.dart';
import 'package:flutter/material.dart';
import '../../../app/generalImports.dart';

typedef PaymentGatewayDetails = ({String paymentType, String paymentImage});

class BookingDetails extends StatefulWidget {
  const BookingDetails({super.key, required this.bookingsModel});

  final BookingsModel bookingsModel;

  @override
  BookingDetailsState createState() => BookingDetailsState();

  static Route<BookingDetails> route(RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (_) => BlocProvider.value(
        value: arguments['cubit'] as UpdateBookingStatusCubit,
        child: BookingDetails(bookingsModel: arguments['bookingsModel']),
      ),
    );
  }
}

class BookingDetailsState extends State<BookingDetails> {
  ScrollController? scrollController = ScrollController();
  Map<String, String>? currentStatusOfBooking;
  Map<String, String>? temporarySelectedStatusOfBooking;
  int totalServiceQuantity = 0;

  DateTime? selectedRescheduleDate;
  String? selectedRescheduleTime;
  List<Map<String, String>> filters = [];
  List<Map<String, dynamic>>? selectedProofFiles;
  List<Map<String, dynamic>>? additionalCharged;
  ValueNotifier<bool> isBillDetailsCollapsed = ValueNotifier(true);
  String? otpFromProvider;
  @override
  void initState() {
    scrollController!.addListener(() => setState(() {}));
    _getTotalQuantity();
    Future.delayed(Duration.zero, () {
      filters = [
        {'value': '1', 'title': 'awaiting'.translate(context: context)},
        {'value': '2', 'title': 'confirmed'.translate(context: context)},
        {'value': '3', 'title': 'started'.translate(context: context)},
        {'value': '4', 'title': 'rescheduled'.translate(context: context)},
        {'value': '5', 'title': 'booking_ended'.translate(context: context)},
        {'value': '6', 'title': 'completed'.translate(context: context)},
        {'value': '7', 'title': 'cancelled'.translate(context: context)},
      ];
    });
    _getTranslatedInitialStatus();
    super.initState();
  }

  void _getTotalQuantity() {
    widget.bookingsModel.services?.forEach((Services service) {
      totalServiceQuantity += int.parse(service.quantity!);
    });
    setState(() {});
  }

  void _getTranslatedInitialStatus() {
    Future.delayed(Duration.zero, () {
      final String? initialStatusValue = getStatusForApi
          .where(
            (Map<String, String> e) =>
                e['title'] == widget.bookingsModel.status,
          )
          .toList()[0]['value'];
      currentStatusOfBooking = filters.where((Map<String, String> element) {
        return element['value'] == initialStatusValue;
      }).toList()[0];

      setState(() {});
    });
  }

  // Don't translate this because we need to send this title in api;
  List<Map<String, String>> getStatusForApi = [
    {'value': '1', 'title': 'awaiting'},
    {'value': '2', 'title': 'confirmed'},
    {'value': '3', 'title': 'started'},
    {'value': '4', 'title': 'rescheduled'},
    {'value': '5', 'title': 'booking_ended'},
    {'value': '6', 'title': 'completed'},
    {'value': '7', 'title': 'cancelled'},
  ];

  Future<void> _onDropDownClick(List<Map<String, String>> filters) async {
    //get current status of booking
    if (widget.bookingsModel.status != null &&
        temporarySelectedStatusOfBooking == null) {
      final String? statusValue = getStatusForApi
          .where(
            (Map<String, String> e) =>
                e['title'] == widget.bookingsModel.status,
          )
          .toList()[0]['value'];
      currentStatusOfBooking = filters.where((Map<String, String> element) {
        return element['value'] == statusValue;
      }).toList()[0];
    } else {
      currentStatusOfBooking = temporarySelectedStatusOfBooking;
    }

    //show bottomSheet to select new status
    var selectedStatusOfBooking = await UiUtils.showModelBottomSheets(
      context: context,
      child: UpdateStatusBottomSheet(
        selectedItem: currentStatusOfBooking!,
        itemValues: [...filters],
      ),
    );

    if (selectedStatusOfBooking?['selectedStatus'] != null) {
      //if selectedStatus is started then show uploadFiles bottomSheet
      if (selectedStatusOfBooking['selectedStatus']['title'] ==
          'started'.translate(context: context)) {
        UiUtils.showModelBottomSheets(
          context: context,
          child: UploadProofBottomSheet(preSelectedFiles: selectedProofFiles),
        ).then((value) {
          selectedProofFiles = value;
          setState(() {});
        });
      }

      //if selectedStatus is booking_ended then show uploadFiles bottomSheet
      if (selectedStatusOfBooking['selectedStatus']['title'] ==
          'booking_ended'.translate(context: context)) {
        await UiUtils.showModelBottomSheets(
          context: context,
          child: UploadProofBottomSheet(preSelectedFiles: selectedProofFiles),
        ).then((value) {
          selectedProofFiles = value;
          setState(() {});
        });

        await UiUtils.showModelBottomSheets(
          context: context,
          useSafeArea: true,
          child: AdditionalChargesBottomSheet(
            additionalCharges:
                additionalCharged, // pass any preselected charges if needed
          ),
        ).then((charges) {
          additionalCharged = charges;
          setState(() {}); // Update state after additional charges are set
        });
      } else {
        temporarySelectedStatusOfBooking =
            selectedStatusOfBooking['selectedStatus'];
        currentStatusOfBooking = selectedStatusOfBooking['selectedStatus'];
      }

      //if OTP validation is required then show OTP dialog
      if (currentStatusOfBooking?['title'] ==
              'completed'.translate(context: context) &&
          context
              .read<FetchSystemSettingsCubit>()
              .isOrderOTPConfirmationEnable) {
        UiUtils.showAnimatedDialog(
          context: context,
          child: VerifyOTPDialog(
            otp: widget.bookingsModel.otp ?? '0',
            confirmButtonPressed: () {
              temporarySelectedStatusOfBooking =
                  selectedStatusOfBooking['selectedStatus'];
              currentStatusOfBooking =
                  selectedStatusOfBooking['selectedStatus'];
              setState(() {});
            },
          ),
        ).then((value) {
          if (value != null) {
            otpFromProvider = value.toString();
          } else {
            otpFromProvider = '';
          }
        });
      } else if (currentStatusOfBooking?['title'] ==
              'completed'.translate(context: context) &&
          context
              .read<FetchSystemSettingsCubit>()
              .isOrderOTPConfirmationEnable &&
          widget.bookingsModel.paymentMethod == "cod") {
        UiUtils.showAnimatedDialog(
          context: context,
          child: CustomDialogLayout(
            title: "collectCashFromCustomer",
            confirmButtonName: "okay",
            cancelButtonName: "cancel",
            confirmButtonBackgroundColor: Theme.of(
              context,
            ).colorScheme.accentColor,
            cancelButtonBackgroundColor: Theme.of(
              context,
            ).colorScheme.secondaryColor,
            showProgressIndicator: false,
            cancelButtonPressed: () {
              Navigator.pop(context);
            },
            confirmButtonPressed: () {
              Navigator.pop(context);
              temporarySelectedStatusOfBooking =
                  selectedStatusOfBooking['selectedStatus'];
              currentStatusOfBooking =
                  selectedStatusOfBooking['selectedStatus'];
              setState(() {});
            },
          ),
        );
      } else if (currentStatusOfBooking?['title'] ==
              'completed'.translate(context: context) &&
          context
                  .read<FetchSystemSettingsCubit>()
                  .isOrderOTPConfirmationEnable ==
              false &&
          widget.bookingsModel.paymentMethod == "cod") {
        UiUtils.showAnimatedDialog(
          context: context,
          child: CustomDialogLayout(
            title: "collectdCash",
            confirmButtonName: "okay",
            cancelButtonName: "cancel",
            confirmButtonBackgroundColor: Theme.of(
              context,
            ).colorScheme.accentColor,
            cancelButtonBackgroundColor: Theme.of(
              context,
            ).colorScheme.secondaryColor,
            showProgressIndicator: false,
            cancelButtonPressed: () {
              Navigator.pop(context);
            },
            confirmButtonPressed: () {
              Navigator.pop(context);
              temporarySelectedStatusOfBooking =
                  selectedStatusOfBooking['selectedStatus'];
              currentStatusOfBooking =
                  selectedStatusOfBooking['selectedStatus'];
              setState(() {});
            },
          ),
        );
      } else {
        temporarySelectedStatusOfBooking =
            selectedStatusOfBooking['selectedStatus'];
        currentStatusOfBooking = selectedStatusOfBooking['selectedStatus'];
      }

      //if selectedStatus is reschedule then show select new date and time bottomSheet
      if (selectedStatusOfBooking['selectedStatus']['title'] ==
          'rescheduled'.translate(context: context)) {
        final Map? result = await UiUtils.showModelBottomSheets(
          context: context,
          isScrollControlled: true,
          enableDrag: true,
          child: CustomContainer(
            height: context.screenHeight * 0.7,
            borderRadiusStyle: const BorderRadius.only(
              topRight: Radius.circular(UiUtils.borderRadiusOf20),
              topLeft: Radius.circular(UiUtils.borderRadiusOf20),
            ),
            child: CalenderBottomSheet(
              advanceBookingDays: widget.bookingsModel.advanceBookingDays!,
            ),
          ),
        );

        selectedRescheduleDate = result?['selectedDate'];
        selectedRescheduleTime = result?['selectedTime'];

        if (selectedRescheduleDate == null || selectedRescheduleTime == null) {
          // Revert to the original selected status when reschedule is cancelled
          final String? originalStatusValue = getStatusForApi
              .where(
                (Map<String, String> e) =>
                    e['title'] == widget.bookingsModel.status,
              )
              .toList()[0]['value'];
          final Map<String, String> originalStatus = filters.where((Map<String, String> element) {
            return element['value'] == originalStatusValue;
          }).toList()[0];

          selectedStatusOfBooking = originalStatus;
          temporarySelectedStatusOfBooking = originalStatus;
          currentStatusOfBooking = originalStatus;
          setState(() {});
        }
      } else {
        //reset the values if choose different one
        selectedRescheduleDate = null;
        selectedRescheduleTime = null;
      }
    }
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          context.watch<UpdateBookingStatusCubit>().state
              is! UpdateBookingStatusInProgress,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: AppBar(
          surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
          backgroundColor: Theme.of(context).colorScheme.secondaryColor,
          elevation: 10,
          // centerTitle: true,
          leading: CustomBackArrow(
            canGoBack:
                context.watch<UpdateBookingStatusCubit>().state
                    is! UpdateBookingStatusInProgress,
          ),
          title: Column(
            children: [
              CustomText(
                'bookingInformation'.translate(context: context),
                color: context.colorScheme.blackColor,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              if (widget.bookingsModel.customJobRequestId != null)
                CustomText(
                  'customServiceRequest'.translate(context: context),
                  color: context.colorScheme.lightGreyColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
            ],
          ),
        ),

        body: mainWidget(),

        bottomNavigationBar: bottomBarWidget(),
      ),
    );
  }

  Widget onMapsBtn() {
    return CustomInkWellContainer(
      onTap: () async {
        UiUtils.openMap(
          context,
          latitude: widget.bookingsModel.latitude,
          longitude: widget.bookingsModel.longitude,
        );
      },
      child: CustomContainer(
        padding: const EdgeInsets.all(10),
        color: Theme.of(context).colorScheme.accentColor.withValues(alpha: 0.3),
        borderRadius: UiUtils.borderRadiusOf5,
        child: Text(
          'onMapsLbl'.translate(context: context),
          style: TextStyle(color: Theme.of(context).colorScheme.accentColor),
        ),
      ),
    );
  }

  Widget bottomBarWidget() {
    return BlocConsumer<UpdateBookingStatusCubit, UpdateBookingStatusState>(
      listener: (BuildContext context, UpdateBookingStatusState state) {
        // if (state is UpdateBookingStatusFailure) {
        //   UiUtils.showMessage(
        //       context,
        //       state.errorMessage.translate(context: context),
        //       ToastificationType.error);
        // }
        if (state is UpdateBookingStatusSuccess) {
          if (state.error == 'true') {
            UiUtils.showMessage(
              context,
              state.message,
              ToastificationType.error,
            );
            setState(() {
              selectedProofFiles = [];
              additionalCharged = [];
            });
            return;
          }

          context.read<FetchBookingsCubit>().updateBookingDetailsLocally(
            bookingID: state.orderId.toString(),
            bookingStatus: state.status,
            listOfUploadedImages: state.imagesList,
            listOfAdditionalCharged: state.additionalCharges,
          );

          UiUtils.showMessage(
            context,
            'updatedSuccessfully',
            ToastificationType.success,
          );
        }
      },
      builder: (BuildContext context, UpdateBookingStatusState state) {
        Widget? child;
        if (state is UpdateBookingStatusInProgress) {
          child = CustomCircularProgressIndicator(color: AppColors.whiteColors);
        }
        return CustomContainer(
          color: Theme.of(context).colorScheme.secondaryColor,
          child: Padding( padding: EdgeInsetsDirectional.only(
            start: 15,
            end: 15,
            top: 10,
            bottom: 10 + MediaQuery.of(context).padding.bottom,
          ),

            child: SizedBox(
              width: MediaQuery.sizeOf(context).width / 2,
              height:
                  (selectedRescheduleDate == null ||
                      selectedRescheduleTime == null)
                  ? 50
                  : 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedRescheduleDate != null &&
                      selectedRescheduleTime != null) ...[
                    SizedBox(
                      height: 70,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'selectedDate'.translate(context: context),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  selectedRescheduleDate.toString().split(
                                    ' ',
                                  )[0],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'selectedTime'.translate(context: context),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(selectedRescheduleTime ?? ''),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: CustomFormDropdown(
                            initialTitle:
                                currentStatusOfBooking?['title']
                                    .toString()
                                    .capitalize() ??
                                widget.bookingsModel.translatedStatus
                                    .toString()
                                    .capitalize(),
                            selectedValue: currentStatusOfBooking?['title'],
                            onTap: () {
                              _onDropDownClick(filters);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: CustomRoundedButton(
                            showBorder: false,
                            buttonTitle: 'update'.translate(context: context),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.accentColor,
                            widthPercentage: 1,
                            height: 50,
                            textSize: 14,
                            child: child,
                            onTap: () {
                              if (state is UpdateBookingStatusInProgress) {
                                return;
                              }
                              Map<String, String>? bookingStatus;

                              final List<Map<String, String>>
                              selectedBookingStatus = getStatusForApi.where((
                                Map<String, String> element,
                              ) {
                                return element['value'] ==
                                    currentStatusOfBooking?['value'];
                              }).toList();
                              if (selectedBookingStatus.isNotEmpty) {
                                bookingStatus = selectedBookingStatus[0];
                              }
                              if (currentStatusOfBooking?['title'] ==
                                      'completed'.translate(context: context) &&
                                  context
                                      .read<FetchSystemSettingsCubit>()
                                      .isOrderOTPConfirmationEnable) {
                                if (otpFromProvider == null ||
                                    otpFromProvider!.trim().isEmpty) {
                                  UiUtils.showMessage(
                                    context,
                                    'pleaseEnterOTP',
                                    ToastificationType.error,
                                  );
                                  return;
                                } else if (otpFromProvider!.trim() !=
                                        widget.bookingsModel.otp ||
                                    otpFromProvider!.trim() == '0') {
                                  UiUtils.showMessage(
                                    context,
                                    'invalidOTP',
                                    ToastificationType.error,
                                  );
                                  return;
                                }
                              }

                              context
                                  .read<UpdateBookingStatusCubit>()
                                  .updateBookingStatus(
                                    orderId: int.parse(
                                      widget.bookingsModel.id!,
                                    ),
                                    customerId: int.parse(
                                      widget.bookingsModel.customerId!,
                                    ),
                                    status:
                                        bookingStatus?['title'] ??
                                        widget.bookingsModel.status!,

                                    //OTP validation applied locally, so status is completed then OTP verified already, so directly passing the OTP
                                    otp: otpFromProvider ?? '',
                                    date: selectedRescheduleDate
                                        .toString()
                                        .split(' ')[0],
                                    time: selectedRescheduleTime,
                                    proofData: selectedProofFiles,
                                    additionalCharges: additionalCharged,
                                  );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget mainWidget() {
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomerInfoWidget(bookingsModel: widget.bookingsModel),
          const SizedBox(height: 10),
          StatusAndInvoiceWidget(bookingsModel: widget.bookingsModel),
          const SizedBox(height: 10),
          BookingDateAndTimeWidget(bookingsModel: widget.bookingsModel),
          Visibility(
            visible: widget.bookingsModel.workStartedProof!.isNotEmpty,
            child: UploadedProofWidget(
              title: 'workStartedProof',
              proofData: widget.bookingsModel.workStartedProof!,
            ),
          ),
          Visibility(
            visible: widget.bookingsModel.workCompletedProof!.isNotEmpty,
            child: UploadedProofWidget(
              title: 'workCompletedProof',
              proofData: widget.bookingsModel.workCompletedProof!,
            ),
          ),
          NotesWidget(remarks: widget.bookingsModel.remarks ?? ''),
          ServiceDetailsWidget(bookingsModel: widget.bookingsModel),
          PriceSectionWidget(
            bookingsModel: widget.bookingsModel,
            isBillDetailsCollapsed: isBillDetailsCollapsed,
          ),
        ],
      ),
    );
  }
}
