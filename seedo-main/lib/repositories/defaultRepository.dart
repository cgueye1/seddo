
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:solimus_vefa/utils/const.dart';

import '../utils/sharedPreferences.dart';



class Repository {
  final Dio dio;
 Repository({required this.dio});


  Future<Response<dynamic>>  saveBodyFree(body, url) async {
    print(url);
    try {
      var token = await ControleSharedPreferences.getString(APIConstants.TOKEN);
      final response = await dio.post(url,
          data: body,
          options: Options(headers: {

            "Content-Type": 'application/json',
           // "Access-Control-Allow-Origin":"*"
          }));

      return response;
    } on DioError catch (e) {
      print("dsdsds${e}");
      throw e;
    }
  }
  Future saveBody(body, url) async {
    try {
      var token = await ControleSharedPreferences.getString(APIConstants.TOKEN);
      final response = await dio.post(url,
          data: body,
          options: Options(headers: {
            "Authorization": "Bearer $token",
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
  Future deleteData(url) async {
    try {
      var token = await ControleSharedPreferences.getString(APIConstants.TOKEN);
      final response = await dio.delete(url,
        //  data: body,
          options: Options(headers: {
            "Authorization": "Bearer $token",
            "Content-Type": 'application/json',
          }));
      print(response.statusCode);

      return response;
    } on DioError catch (e) {
      print("dsdsds${e.response!.data}");
      throw e;
    }
  }
  Future updateData(body, url) async {
    try {
      var token = await ControleSharedPreferences.getString(APIConstants.TOKEN);
      final response = await dio.put(url,
            data: body,
          options: Options(headers: {
            "Authorization": "Bearer $token",
            "Content-Type": 'application/json',
          }));
      print(response.statusCode);

      return response;
    } on DioError catch (e) {
      print("dsdsds${e}");
      print("error${e.response!.data}");
      throw e;
    }
  }
//      "Authorization": "Bearer $token",
  Future getData(path) async {
    var token = await ControleSharedPreferences.getString(APIConstants.TOKEN);
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
  Future<Response<dynamic>>  getDataOk(path) async {
    var token = await ControleSharedPreferences.getString(APIConstants.TOKEN);
    Map<String , dynamic>? header={};
    if(token==null){
      header={
        "Content-Type": 'application/json',
      };
    } else {
      header={
          "Authorization": "Bearer $token",
          "Content-Type": 'application/json',
      };
    }

    final response = await dio.get(path,
        options: Options(headers: header));
    try {

      return response;
    } catch (e) {
      print("dsdsds${e}");
      throw e;
    }
  }


  Future uploadFiles(File file,path) async {

    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename:fileName),
    });
    try {

      var  response = await dio.post(path, data: formData);
      print( response);
        if(response.statusCode==200){
          return response.data;
        } else {
          return {"path": "cb.jpeg"};
        }



    } on DioError  catch (ex) {

      throw Exception(ex.message);
    }

  }

  Future uploadMP3(File file,path) async {

    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename:fileName),
    });
    try {

      var  response = await dio.post(path, data: formData);
      if(response.statusCode==200){
        return response.data;
      } else {
        return {"path": "cb.jpeg"};
      }


    } on DioError  catch (ex) {

      throw Exception(ex.message);
    }

  }

  Future postFormData(FormData formData,path) async {


    try {
      var token = await ControleSharedPreferences.getString(APIConstants.TOKEN);

      var header={
        "Authorization": "Bearer $token",
        "Content-Type": 'application/json',
      };
      final response = await dio.post(
          path, data: formData,    options: Options(headers: header)
      );


        return response;



    } on DioError  catch (ex) {
      print("___oklm$ex");

      throw Exception(ex.message);
    }

  }


  Future putFormData(FormData formData,path) async {


    try {
      var token = await ControleSharedPreferences.getString(APIConstants.TOKEN);

      var header={
        "Authorization": "Bearer $token",
        "Content-Type": 'application/json',
      };
      final response = await dio.put(
          path, data: formData,    options: Options(headers: header)
      );


      return response;



    } on DioError  catch (ex) {
      print("___oklm$ex");

      throw Exception(ex.message);
    }

  }

}
