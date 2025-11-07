import 'package:edemand_partner/app/generalImports.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  //headers
  static Map<String, dynamic> headers({bool includeAuth = true}) {
    final String jwtToken = HiveRepository.getUserToken;
    final lang = HiveRepository.getCurrentLanguage();

    if (kDebugMode) {
    }

    final headers = <String, dynamic>{};

    if (includeAuth) {
      headers["Authorization"] = "Bearer $jwtToken";
    }

    if (lang?.languageCode != null && lang!.languageCode.isNotEmpty) {
      headers["Content-Language"] = lang.languageCode;
    }

    return headers;
  }

  static Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> parameter,
    required bool useAuthToken,
  }) async {
    try {
      final Dio dio = Dio();
      dio.interceptors.add(CurlLoggerInterceptor());

      final FormData formData = FormData.fromMap(
        parameter,
        ListFormat.multiCompatible,
      );
      if (kDebugMode) {
      }
      final Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: headers(includeAuth: useAuthToken),
        ),
      );

      if (kDebugMode) {
      }
      // if (response.data['error']) {
      //   throw ApiException(response.data['message']);
      // }
      return Map.from(response.data);
    } on FormatException catch (e) {
      if (kDebugMode) {
      }
      throw ApiException(e.message);
    } on DioException catch (e) {
      if (kDebugMode) {
      }
      if (e.response?.statusCode == 401) {
        UiUtils.authenticationError = true;
        throw ApiException('authenticationFailed');
      } else if (e.response?.statusCode == 500) {
        throw ApiException('internalServerError');
      }
      throw ApiException(
        e.error is SocketException
            ? 'noInternetFound'
            : 'somethingWentWrongTitle',
      );
    } on ApiException catch (e) {
      throw ApiException(e.toString());
    } catch (e) {
      throw ApiException('somethingWentWrongTitle');
    }
  }

  static Future<Map<String, dynamic>> get({
    required String url,
    required bool useAuthToken,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Dio dio = Dio();
      dio.interceptors.add(CurlLoggerInterceptor());
      final Response response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers(includeAuth: useAuthToken)),
      );

      if (response.data['error'] == true) {
        throw ApiException(response.data['code'].toString());
      }

      return Map.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        UiUtils.authenticationError = true;
        throw ApiException('authenticationFailed');
      } else if (e.response?.statusCode == 500) {
        throw ApiException('internalServerError');
      }
      throw ApiException(
        e.error is SocketException
            ? 'noInternetFound'
            : 'somethingWentWrongTitle',
      );
    } on ApiException {
      throw ApiException('somethingWentWrongTitle');
    } catch (e) {
      throw ApiException('somethingWentWrongTitle');
    }
  }
}
