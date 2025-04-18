import 'package:dio/dio.dart';
import 'package:seddoapp/utils/constant.dart';

import 'SharedPreferencesService.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  late Dio dio;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: APIConstants.API_BASE_URL,
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        // headers: {"Content-Type": "application/json"},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_isProtectedApi(options)) {
            String? token = await _getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  bool _isProtectedApi(RequestOptions options) {
    const protectedApis = ["/v1/user/me"];

    for (var api in protectedApis) {
      if (options.uri.toString().contains(api)) {
        return true;
      }
    }
    return false;
  }

  Future<String?> _getToken() async {
    return _sharedPreferencesService.getValue(APIConstants.AUTH_TOKEN);
  }
}
