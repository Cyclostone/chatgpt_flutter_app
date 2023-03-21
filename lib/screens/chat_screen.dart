import 'dart:developer';

import 'package:chat_gpt_app_mk1/constants/constants.dart';
import 'package:chat_gpt_app_mk1/models/chat_model.dart';
import 'package:chat_gpt_app_mk1/services/api_service.dart';
import 'package:chat_gpt_app_mk1/services/assets_manager.dart';
import 'package:chat_gpt_app_mk1/services/services.dart';
import 'package:chat_gpt_app_mk1/widgets/chat_widget.dart';
import 'package:chat_gpt_app_mk1/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../providers/chats_provider.dart';
import '../providers/models_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;
  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;

  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // List<ChatModel> chatlist = [];

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context, listen: true);
    final chatProvider = Provider.of<ChatProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.openailogo),
        ),
        title: const Text("ChatGPT"),
        actions: [
          IconButton(
            onPressed: () async {
              await Services.showModalSheet(context: context);
            },
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                controller: _listScrollController,
                itemCount: chatProvider.getChatList.length, //chatlist.length,
                itemBuilder: ((context, index) {
                  return ChatWidget(
                    msg: chatProvider
                        .getChatList[index].msg, // chatlist[index].msg,
                    chatIndex: chatProvider.getChatList[index]
                        .chatIndex, // chatlist[index].chatIndex,
                  );
                }),
              ),
            ),
            if (_isTyping) ...[
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),
            ],
            const SizedBox(height: 15),
            Material(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: focusNode,
                        style: const TextStyle(color: Colors.white),
                        controller: textEditingController,
                        onSubmitted: (value) async {
                          await sendMessageFCT(
                              modelsProvider: modelsProvider,
                              chatProvider: chatProvider);
                        },
                        decoration: const InputDecoration.collapsed(
                            hintText:
                                "TextField is Operational, You Want to Try?",
                            hintStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await sendMessageFCT(
                            modelsProvider: modelsProvider,
                            chatProvider: chatProvider);
                      },
                      icon: const Icon(
                        Icons.send,
                      ),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void scrollListToEnd() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  Future<void> sendMessageFCT(
      {required ModelsProvider modelsProvider,
      required ChatProvider chatProvider}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "You Can't Send Multiple Messages at a time",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "Please Type a message",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      String msg = textEditingController.text;
      setState(() {
        _isTyping = true;
        chatProvider.addUserMessage(msg: msg);
        // chatlist.add(ChatModel(msg: textEditingController.text, chatIndex: 0));
        textEditingController.clear();
        focusNode.unfocus();
      });
      await chatProvider.sendMessagesAndGetAnswers(
        msg: msg,
        chosenModelId: modelsProvider.getCurrentModel,
      );
      // chatlist.addAll(await ApiService.sendMessage(
      //   message: textEditingController.text,
      //   modelId: modelsProvider.getCurrentModel,
      // ));
      setState(() {});
    } catch (error) {
      log('error: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(
          label: error.toString(),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        scrollListToEnd();
        _isTyping = false;
      });
    }
  }
}
