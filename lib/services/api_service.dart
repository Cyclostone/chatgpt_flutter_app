import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_gpt_app_mk1/constants/api_consts.dart';
import 'package:chat_gpt_app_mk1/models/chat_model.dart';
import 'package:chat_gpt_app_mk1/models/models_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<List<ModelsModel>> getModels() async {
    try {
      var response = await http.get(
        Uri.parse("$BASE_URL/models"),
        headers: {'Authorization': 'Bearer $API_KEY'},
      );

      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['error'] != null) {
        // log("jsonResponsep['error'] ${jsonResponse['error']['message']}");
        throw HttpException(jsonResponse['error']['message']);
      }

      List temp = [];
      for (var value in jsonResponse['data']) {
        temp.add(value);
        log('temp ${value['id']}');
      }
      return ModelsModel.modelsFromSnapshot(temp);
      // print('jsonResponse $jsonResponse');
    } catch (error) {
      log('error : $error');
      rethrow;
    }
  }

  // Send Message fct
  static Future<List<ChatModel>> sendMessage(
      {required String message, required String modelId}) async {
    try {
      log("modelId $modelId");
      var response = await http.post(Uri.parse("$BASE_URL/completions"),
          headers: {
            'Authorization': 'Bearer $API_KEY',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            "model": modelId,
            "prompt": message,
            "max_tokens": 100,
          }));

      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['error'] != null) {
        // log("jsonResponsep['error'] ${jsonResponse['error']['message']}");
        throw HttpException(jsonResponse['error']['message']);
      }

      List<ChatModel> chatList = [];

      if (jsonResponse['choices'].length > 0) {
        log("jsonResponse[choices]text ${jsonResponse['choices'][0]['text']}");
        chatList = List.generate(
          jsonResponse['choices'].length,
          (index) => ChatModel(
              msg: jsonResponse['choices'][index]['text'], chatIndex: 1),
        );
      }
      return chatList;
      // print('jsonResponse $jsonResponse');
    } catch (error) {
      log('chatModel error : $error');
      rethrow;
    }
  }
}

Future<List<ChatModel>> sendMessage_v2(
      {required String message, required String modelId}) async {
    try {
      log("modelId $modelId");
      var response = await http.post(Uri.parse("$BASE_URL/chat/completions"),
          headers: {
            'Authorization': 'Bearer $API_KEY',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            "model": modelId,
            "prompt": message,
            "max_tokens": 100,
          }));

      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['error'] != null) {
        // log("jsonResponsep['error'] ${jsonResponse['error']['message']}");
        throw HttpException(jsonResponse['error']['message']);
      }

      List<ChatModel> chatList = [];

      if (jsonResponse['choices'].length > 0) {
        log("jsonResponse[choices]text ${jsonResponse['choices'][0]['text']}");
        chatList = List.generate(
          jsonResponse['choices'].length,
          (index) => ChatModel(
              msg: jsonResponse['choices'][index]['text'], chatIndex: 1),
        );
      }
      return chatList;
      // print('jsonResponse $jsonResponse');
    } catch (error) {
      log('chatModel error : $error');
      rethrow;
    }
  }
