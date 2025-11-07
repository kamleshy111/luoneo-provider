import '../../app/generalImports.dart';

class SettingsRepository {
  Future getSystemSettings({required bool isAnonymous}) async {
    try {
      final Map<String, dynamic> response = await ApiClient.post(
        url: ApiUrl.getSettings,
        parameter: {},
        useAuthToken: isAnonymous ? false : true,
      );
      return response['data'];
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future updateFCM({
    required final String fcmId,
    required final String platform,
  }) async {
    await ApiClient.post(
      url: ApiUrl.updateFcm,
      parameter: {ApiParam.fcmId: fcmId, ApiParam.platform: platform},
      useAuthToken: true,
    );
  }

  Future<String> createRazorpayOrderId({
    required final String subscriptionID,
  }) async {
    try {
      final Map<String, dynamic> parameters = {
        ApiParam.subscriptionID: subscriptionID,
      };
      final result = await ApiClient.post(
        parameter: parameters,
        url: ApiUrl.createRazorpayOrder,
        useAuthToken: true,
      );

      return result['data']['id'];
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> sendQueryToAdmin({
    required final Map<String, dynamic> parameter,
  }) async {
    try {
      final response = await ApiClient.post(
        url: ApiUrl.sendQuery,
        parameter: parameter,
        useAuthToken: true,
      );

      return {"message": response["message"], "error": response['error']};
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<LanguageListModel> getLanguageList() async {
    try {
      final response = await ApiClient.get(
        url: ApiUrl.getLanguageList,
        useAuthToken: false,
      );

      return LanguageListModel.fromJson(response);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  ///This method is used to fetch language JSON data
  Future<Map<String, dynamic>> getLanguageJsonData(String languageCode) async {
    try {
      final response = await ApiClient.post(
        url: ApiUrl.getLanguageJsonData,
        parameter: {
          ApiParam.languageCode: languageCode,
          ApiParam.platform: 'provider_app',
        },
        useAuthToken: false,
      );

      return response['data'] ?? {};
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
