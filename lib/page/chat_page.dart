import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:local_gpt_flutter/model/chat_model.dart';
import 'package:local_gpt_flutter/services/chat_code.dart';
import 'package:syntax_highlight/syntax_highlight.dart';
import 'package:text_highlight/text_highlight.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatModel> _messages = [];
  bool _isGenerating = false;

  late ChatwithLlamaCode chatwithLlamaCode;

  late TextEditingController _controller;

  late Highlighter highlighter;
  late ScrollController _scrollController;
  @override
  void initState() {
    _controller = TextEditingController();
    _scrollController = ScrollController();
    Dio dio = Dio()..interceptors.add(LogInterceptor(responseBody: true));
    chatwithLlamaCode = ChatwithLlamaCode(dio);
    super.initState();
  }

  CancelToken cancelToken = CancelToken();

  _sendData() async {
    setState(() {
      _isGenerating = true;
    });
    final data = await chatwithLlamaCode.sendCode(
        _controller.text, "http://127.0.0.1:8080/api/prompt",
        cancelToken: cancelToken);

    final chatModel = ChatModel.fromJson(data.data);

    // setState(() {
    // if (_messages.value.isEmpty) {
    //   _messages.add([chatModel]);
    // } else {
    setState(() {
      _messages.add(chatModel);
      _isGenerating = false;
    });
    // }
    // });
  }

  @override
  void didChangeDependencies() async {
    highlighter = Highlighter(
      language: 'dart',
      theme: await HighlighterTheme.loadDarkTheme(),
    );

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Llama 2'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 14,
            child: Builder(
              builder: (BuildContext context) {
                return Container(
                    child: _messages.isEmpty
                        ? const Center(child: Text("No messages yet"))
                        : ListView.separated(
                            controller: _scrollController,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemCount: _messages.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText(
                                      "Q: ${_messages[index].prompt}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    MarkdownBody(
                                      fitContent: true,
                                      styleSheet: MarkdownStyleSheet(
                                        codeblockPadding:
                                            const EdgeInsets.all(10),
                                        codeblockDecoration: BoxDecoration(
                                          color: Colors.grey[900],
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      selectable: true,
                                      shrinkWrap: true,
                                      syntaxHighlighter: CodeHighlighter(
                                          highlighter: highlighter),
                                      data: _messages[index].query.replaceAll(
                                          "You are an AI Coding Assitant and your task is to solve coding",
                                          ""),
                                    ),
                                    Text("${_messages[index].timestamp}")
                                  ],
                                ),
                              );
                            },
                          ));
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  if (_isGenerating)
                    FilledButton.icon(
                      icon: const Icon(Icons.stop),
                      label: const Text("stop"),
                      onPressed: () {
                        setState(() {
                          cancelToken.cancel(["cancelled"]);
                          _isGenerating = false;
                        });
                      },
                    ),
                  Row(
                    children: [
                      IconButton.filled(
                        icon: const Icon(Icons.add),
                        onPressed: () {},
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextField(
                          onSubmitted: (value) async {
                            await _sendData();
                            _controller.clear();

                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                          controller: _controller,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            suffixIcon: GestureDetector(
                                onTap: () async {
                                  await _sendData();
                                  _controller.clear();

                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                },
                                child: const Icon(Icons.send)),
                            labelText: 'Type a message',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CodeHighlighter extends SyntaxHighlighter {
  final Highlighter highlighter;

  CodeHighlighter({required this.highlighter});
  @override
  TextSpan format(String source) {
    return highlighter.highlight(source);
  }
}
