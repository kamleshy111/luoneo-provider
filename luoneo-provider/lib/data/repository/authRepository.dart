import '../../app/generalImports.dart';

class AuthRepository {
  static String? verificationId;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isLoggedIn {
    return _auth.currentUser != null;
  }

  Future<void> verifyPhoneNumber(
    String phoneNumber, {
    Function(dynamic err)? onError,
    VoidCallback? onCodeSent,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential complete) {},
      verificationFailed: (FirebaseAuthException err) {
        onError?.call(err);
      },
      codeSent: (String verification, int? forceResendingToken) {
        verificationId = verification;
        // this is force resending token
        HiveRepository.setResendToken = forceResendingToken;
        if (onCodeSent != null) {
          onCodeSent();
        }
      },
      forceResendingToken: HiveRepository.getResendToken,
      codeAutoRetrievalTimeout: (String timeout) {},
    );
  }

  Future<Map<String, dynamic>> sendVerificationCodeUsingSMSGateway({
    required final String phoneNumberWithoutCountryCode,
    required final String countryCode,
  }) async {
    final Map<String, dynamic> response = await ApiClient.post(
      url: ApiUrl.resendOTP,
      parameter: {
        ApiParam.mobile: '$countryCode$phoneNumberWithoutCountryCode',
      },
      useAuthToken: false,
    );

    return response;
  }

  Future<UserCredential?> verifyOTPUsingFirebase({required String code}) async {
    if (verificationId != null) {
      final PhoneAuthCredential phoneAuthCredential =
          PhoneAuthProvider.credential(
            verificationId: verificationId!,
            smsCode: code,
          );

      final UserCredential userCredential = await _auth.signInWithCredential(
        phoneAuthCredential,
      );
      return userCredential;
    }
    return null;
  }

  Future<Map<String, dynamic>> verifyOTPUsingSMSGateway({
    required final String phoneNumberWithOutCountryCode,
    required final String countryCode,
    required final String otp,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        ApiParam.mobile: phoneNumberWithOutCountryCode,
        ApiParam.countryCode: countryCode,
        ApiParam.otp: otp,
      };

      final response = await ApiClient.post(
        parameter: parameter,
        url: ApiUrl.verifyOTP,
        useAuthToken: false,
      );
      return {"error": response['error'], "message": response['message']};
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> verifyUserMobileNumberFromAPI({
    required String mobileNumber,
    required String countryCode,
  }) async {
    try {
      final Map<String, dynamic> parameter = {
        ApiParam.mobile: mobileNumber,
        ApiParam.countryCode: countryCode,
      };

      final Map<String, dynamic> response = await ApiClient.post(
        parameter: parameter,
        url: ApiUrl.verifyUser,
        useAuthToken: false,
      );

      return {
        'error': response['error'],
        'message': response['message'] ?? '',
        'messageCode': response['message_code'] ?? '',
        'authenticationMode': response['authentication_mode'] ?? '',
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String phoneNumber,
    required String password,
    required String countryCode,
    String? fcmId,
  }) async {
    final Map<String, dynamic> parameters = {
      ApiParam.mobile: phoneNumber,
      ApiParam.password: password,
      ApiParam.countryCode: countryCode,
    };
    if (fcmId != null) {
      parameters[ApiParam.fcmId] = fcmId;
      parameters[ApiParam.platform] = Platform.isAndroid ? "android" : "ios";
    }
    final Map<String, dynamic> response = await ApiClient.post(
      url: ApiUrl.loginApi,
      parameter: parameters,
      useAuthToken: false,
    );

    if (response['token'] != null) {
      HiveRepository.setUserToken = response['token'];
      HiveRepository.setUserData(response['data']);
    }

    if (response['data'] == null) {
      return {
        'userDetails': null,
        'error': true,
        'message': response['message'] ?? '',
      };
    }

    return {
      'userDetails': ProviderDetails.fromJson(response['data'] ?? {}),
      'error': response['error'] ?? false,
      'message': response['message'] ?? '',
    };
  }

  Future logout(BuildContext context) async {
    Future.delayed(Duration.zero, () {
      HiveRepository.setUserLoggedIn = false;
      HiveRepository.clearBoxValues(boxName: HiveRepository.userDetailBoxKey);
      context.read<AuthenticationCubit>().setUnAuthenticated();
      NotificationService.disposeListeners();
      AppQuickActions.clearShortcutItems();
    });

    Navigator.of(context).popUntil((Route route) => route.isFirst);
    Navigator.pushReplacementNamed(context, Routes.loginScreenRoute);
  }

  Future deleteUserAccount() async {
    await ApiClient.post(
      url: ApiUrl.deleteUserAccount,
      parameter: {},
      useAuthToken: true,
    );
  }

  Future<Map<String, dynamic>> registerProvider({
    required Map<String, dynamic> parameters,
    required bool isAuthTokenRequired,
  }) async {
    try {
      final Map<String, dynamic> response = await ApiClient.post(
        url: ApiUrl.registerProvider,
        parameter: parameters,
        useAuthToken: isAuthTokenRequired,
      );
      if (response['error']) {
        throw ApiException(response["message"].toString());
      }

      final Map<String, dynamic> responseData = response['data'] != null
          ? Map.from(response['data'])
          : <String, dynamic>{};

      return {
        'providerDetails': responseData.isNotEmpty
            ? ProviderDetails.fromJson(responseData)
            : ProviderDetails(),
        'message': response['message'],
        'error': response['error'],
      };
    } catch (e) {
      return {
        'message': e.toString(),
        'error': true,
        'providerDetails': ProviderDetails(),
      };
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final Map<String, dynamic> parameters = {
        ApiParam.oldPassword: oldPassword,
        ApiParam.newPassword: newPassword,
      };
      final Map<String, dynamic> response = await ApiClient.post(
        url: ApiUrl.changePassword,
        parameter: parameters,
        useAuthToken: true,
      );
      return {'message': response['message'], 'error': response['error']};
    } catch (e) {
      return {'message': e.toString(), 'error': true};
    }
  }

  Future<Map<String, dynamic>> createNewPassword({
    required String countryCode,
    required String newPassword,
    required String mobileNumber,
  }) async {
    try {
      final Map<String, dynamic> parameters = {
        ApiParam.countryCode: countryCode,
        ApiParam.mobileNumber: mobileNumber,
        ApiParam.newPasswords: newPassword,
      };

      final Map<String, dynamic> response = await ApiClient.post(
        url: ApiUrl.createNewPassword,
        parameter: parameters,
        useAuthToken: false,
      );

      return {'message': response['message'], 'error': response['error']};
    } catch (e) {
      return {'message': e.toString(), 'error': true};
    }
  }

  Future<Map<String, dynamic>> getProviderDetails() async {
    try {
      final Map<String, dynamic> response = await ApiClient.post(
        url: ApiUrl.getUserInfo,
        parameter: {},
        useAuthToken: true,
      );
      return response;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<bool> logoutUser({required String? fcmId}) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        ApiParam.fcmId: fcmId,
      };
      final Map<String, dynamic> response = await ApiClient.post(
        url: ApiUrl.logout,
        parameter: parameters,
        useAuthToken: true,
      );
      return response['error'];
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
