import 'package:edemand_partner/app/generalImports.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

extension StringExtension on String {
  String convertToAgo({required BuildContext context}) {
    final Duration diff = DateTime.now().difference(DateTime.parse(this));

    if (diff.inDays >= 365) {
      return "${(diff.inDays / 365).toStringAsFixed(0)} ${"yearAgo".translate(context: context)}";
    } else if (diff.inDays >= 31) {
      return "${(diff.inDays / 31).toStringAsFixed(0)} ${"monthsAgo".translate(context: context)}";
    } else if (diff.inDays >= 1) {
      return "${diff.inDays} ${"daysAgo".translate(context: context)}";
    } else if (diff.inHours >= 1) {
      return "${diff.inHours} ${"hoursAgo".translate(context: context)}";
    } else if (diff.inMinutes >= 1) {
      return "${diff.inMinutes} ${"minutesAgo".translate(context: context)}";
    } else if (diff.inSeconds >= 1) {
      return "${diff.inSeconds} ${"secondsAgo".translate(context: context)}";
    }
    return 'justNow'.translate(context: context);
  }

  String translate({required BuildContext context}) {
    return (AppLocalization.of(context)!.getTranslatedValues(this) ?? this)
        .trim();
  }

  // String getFirebaseError() {
  //   if (this == 'invalid-verification-code') {
  //     return 'invalid_verification_code';
  //   } else if (this == 'invalid-phone-number') {
  //     return 'invalid_phone_number';
  //   } else if (this == 'too-many-requests') {
  //     return 'too_many_requests';
  //   } else if (this == 'network-request-failed') {
  //     return 'network_request_failed';
  //   } else {
  //     return 'somethingWentWrongTitle';
  //   }
  // }

  /// Replace extra coma from String
  ///
  String removeExtraComma() {
    const String middleDuplicateComaRegex = ',(.?),';
    const String leadingAndTrailingComa = r'(^,)|(,$)';
    final RegExp removeComaFromString = RegExp(
      middleDuplicateComaRegex,
      caseSensitive: false,
      multiLine: true,
    );

    final RegExp leadingAndTrailing = RegExp(
      leadingAndTrailingComa,
      multiLine: true,
      caseSensitive: false,
    );

    final String filteredText = trim()
        .replaceAll(removeComaFromString, ',')
        .replaceAll(leadingAndTrailing, '');

    return filteredText;
  }

  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String trimLatLong() {
    return length < 10 ? this : substring(0, indexOf('.') + 7);
  }

  String formatDate() {
    return DateFormat(
      "${dateAndTimeSetting["dateFormat"]}",
    ).format(DateTime.parse("$this 00:00:00.000Z"));
  }

  String formatTime() {
    if (dateAndTimeSetting["use24HourFormat"]) return this;
    return DateFormat(
      "hh:mm a",
    ).format(DateFormat('HH:mm').parse(this)).toString();
  }

  String formatDateAndTimeOnlyDate() {
    final Map<String, String> dateAndTimeSetting = {"dateFormat": "MM/dd/yyyy"};
    return DateFormat(
      dateAndTimeSetting["dateFormat"],
    ).format(DateTime.parse(this));
  }

  String formatAccountNumber() {
    if (length > 5) {
      return '*' * (length - 4) + substring(length - 4);
    }
    return this;
  }

  String formatDateAndTime() {
    if (dateAndTimeSetting["use24HourFormat"]) {
      final String date = split(" ").first;
      return "${date.formatDate()} ${split(" ")[1]}";
    }
    return DateFormat(
      '${dateAndTimeSetting["dateFormat"]} hh:mm a',
    ).format(DateTime.parse(this));
  }

  //price format
  String priceFormat(BuildContext context) {
    // Handle null or empty strings
    if (isEmpty || this == 'null' || this == '') {
      return NumberFormat.currency(
        locale: Platform.localeName,
        name: context
            .read<FetchSystemSettingsCubit>()
            .SystemCurrencyCountryCode,
        symbol: context.read<FetchSystemSettingsCubit>().SystemCurrency,
        decimalDigits: int.parse(
          context.read<FetchSystemSettingsCubit>().SystemDecimalPoint,
        ),
      ).format(0.0);
    }

    try {
      final double newPrice = double.parse(replaceAll(",", ''));
      return NumberFormat.currency(
        locale: Platform.localeName,
        name: context
            .read<FetchSystemSettingsCubit>()
            .SystemCurrencyCountryCode,
        symbol: context.read<FetchSystemSettingsCubit>().SystemCurrency,
        decimalDigits: int.parse(
          context.read<FetchSystemSettingsCubit>().SystemDecimalPoint,
        ),
      ).format(newPrice);
    } catch (e) {
      // Return formatted zero if parsing fails
      return NumberFormat.currency(
        locale: Platform.localeName,
        name: context
            .read<FetchSystemSettingsCubit>()
            .SystemCurrencyCountryCode,
        symbol: context.read<FetchSystemSettingsCubit>().SystemCurrency,
        decimalDigits: int.parse(
          context.read<FetchSystemSettingsCubit>().SystemDecimalPoint,
        ),
      ).format(0.0);
    }
  }

  String extractFileName() {
    try {
      return split('/').last;
    } catch (_) {
      return '';
    }
  }

  String formatPercentage() {
    return '${toString()} %';
  }

  void debugPrint() {
    if (kDebugMode) {
    }
  }

  bool isImage() => [
    'png',
    'jpg',
    'jpeg',
    'gif',
    'webp',
    'bmp',
    'wbmp',
    'pbm',
    'pgm',
    'ppm',
    'tga',
    'ico',
    'cur',
  ].contains(toLowerCase().split('.').lastOrNull ?? '');

  dynamic toInt() {
    if (isEmpty) return this;
    return int.tryParse(this);
  }
}
