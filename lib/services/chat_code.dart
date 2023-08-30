import 'package:dio/dio.dart';

class ChatwithLlamaCode {
  final Dio dio;

  ChatwithLlamaCode(this.dio);

  Future<Response> sendCode(String data, String url,
      {CancelToken? cancelToken}) async {
    try {
      Response response = await dio.post(url,
          cancelToken: cancelToken,
          options: Options(),
          data: FormData.fromMap({
            'user_prompt': data,
          }),
          onSendProgress: (count, total) =>
              print('onSend count: $count, total: $total'),
          onReceiveProgress: (count, total) =>
              print('onReceived  count: $count, total: $total'));

      print(response.data);

      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }
}
