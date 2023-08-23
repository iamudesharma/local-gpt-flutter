import 'package:dio/dio.dart';

const String saveDocument = '/api/save_document';

const String _runIngest = "/api/run_ingest";

const String _prompt = "/api/prompt_route";

const String base_url = "";

class ChatLlama2Services {
  final Dio dio;

  ChatLlama2Services(this.dio);

  // Future<Response> saveDocument(String document) async {
  //   return await dio.post();
  // }

  Future<Response> runIngest(String document) async {
    return await dio.post(base_url + _runIngest, data: {"document": document});
  }

  Future<Response> prompt(String promptText) async {
    final formData = FormData.fromMap({
      'user_prompt': promptText,
    });
    return await dio.post(base_url + _prompt, data: formData);
  }
}
