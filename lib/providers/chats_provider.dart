import 'package:flutter/material.dart';

import '../models/chat_model.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatlist = [];
  List<ChatModel> get getChatList {
    return chatlist;
  }

  void addUserMessage({required String msg}) {
    chatlist.add(ChatModel(msg: msg, chatIndex: 0));
    notifyListeners();
  }

  Future<void> sendMessagesAndGetAnswers(
      {required String msg, required String chosenModelId}) async {
    chatlist.addAll(await ApiService.sendMessage(
      message: msg,
      modelId: chosenModelId,
    ));
    notifyListeners();
  }
}
