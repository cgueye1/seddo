import 'package:dio/dio.dart';

import '../services/api_service.dart';




class DefaultRepository {
  final Dio dio = ApiService().dio;




  Future<Response<dynamic>>  saveBodyFree(body, url) async {
    print(url);
    try {
      final response = await dio.post(url,
          data: body,
          options: Options(headers: {
            "Content-Type": 'application/json',
          }));

      return response;
    } on DioError catch (e) {
      print("dsdsds${e}");
      throw e;
    }
  }
  Future saveBody(body, url) async {
    try {
      final response = await dio.post(url,
          data: body,
          options: Options(headers: {

            "Content-Type": 'application/json',
            //"Access-Control-Allow-Origin":"*"
          }));
      print(response.statusCode);

      return response;
    } on DioError catch (e) {
      print("dsdsds${e.response!.data}");
      throw e;
    }
  }

  Future getData(path) async {
    final response = await dio.get(path,
        options: Options(headers: {

          "Content-Type": 'application/json',
        }));
    try {

      return response;
    } catch (e) {
      print("dsdsds${e}");
      throw e;
    }
  }



}
