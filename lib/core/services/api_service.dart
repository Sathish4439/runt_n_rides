import 'package:dio/dio.dart';
import 'package:RUTSNRIDES/core/constant/const_data.dart';
import 'package:RUTSNRIDES/core/services/endpoint.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:RUTSNRIDES/core/storage/local_storage.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ApiService {
  final Dio _dio;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: EndPoints.baseUrl,
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.readData(CosntString.token);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print('➡️ REQUEST ➡️');
          print('URL: ${options.baseUrl}${options.path}');
          print('Method: ${options.method}');
          print('Headers: ${options.headers}');
          print('QueryParams: ${options.queryParameters}');
          print('Body: ${options.data}');
          print('--------------------------------');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ RESPONSE ✅');
          print(
            'URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}',
          );
          print('Status Code: ${response.statusCode}');
          print('Data: ${response.data}');
          print('--------------------------------');
          handler.next(response);
        },
        onError: (DioError e, handler) async {
          print('❌ ERROR ❌');
          if (e.response != null) {
            print('URL: ${e.requestOptions.baseUrl}${e.requestOptions.path}');
            print('Status Code: ${e.response?.statusCode}');
            print('Response Data: ${e.response?.data}');

            // Handle 401 globally
            if (e.response?.statusCode == 401) {
              await SecureStorageService.deleteAllData();
              print("⚠️ Session expired. User logged out.");
            }
          } else {
            print('Error: ${e.message}');
          }
          print('--------------------------------');
          handler.next(e);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    ResponseType responseType = ResponseType.json,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: Options(responseType: responseType),
      );
    } on DioError catch (e) {
      throw await _handleDioError(e);
    }
  }

  Future<Response<T>> postFile<T>(
    String path, {
    required String fileKey,
    required String filePath,
    Map<String, dynamic>? data,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?data,
        fileKey: await MultipartFile.fromFile(
          filePath,
          filename: filePath.split("/").last,
        ),
      });

      return await _dio.post<T>(
        path,
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );
    } on DioError catch (e) {
      throw await _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    ResponseType responseType = ResponseType.json,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(responseType: responseType),
      );
    } on DioError catch (e) {
      throw await _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    ResponseType responseType = ResponseType.json,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(responseType: responseType),
      );
    } on DioError catch (e) {
      throw await _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    ResponseType responseType = ResponseType.json,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(responseType: responseType),
      );
    } on DioError catch (e) {
      throw await _handleDioError(e);
    }
  }

  Future<Exception> _handleDioError(DioError e) async {
    String message = 'Something went wrong';
    if (e.response != null) {
      final statusCode = e.response?.statusCode ?? 0;
      final data = e.response?.data;

      if (data != null && data is Map && data.containsKey('message')) {
        message = data['message'];
      } else {
        switch (statusCode) {
          case 400:
            message = 'Bad request';
            break;
          case 401:
            message = 'Unauthorized. Please login again.';
            break;
          case 403:
            message = 'Forbidden';
            break;
          case 404:
            message = 'Not found';
            break;
          case 500:
            message = 'Internal server error';
            break;
          default:
            message = 'Error $statusCode: ${e.response?.statusMessage}';
        }
      }
    } else {
      if (e.type == DioErrorType.connectionTimeout ||
          e.type == DioErrorType.sendTimeout ||
          e.type == DioErrorType.receiveTimeout) {
        message = 'Connection timed out. Please try again.';
      } else if (e.type == DioErrorType.cancel) {
        message = 'Request was cancelled.';
      } else {
        message = 'Network error. Please check your internet connection.';
      }
    }

    return Exception(message);
  }
}
