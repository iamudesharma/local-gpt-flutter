import 'dart:io';

import 'package:flutter/material.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:local_gpt_flutter/services/llm.dart';

class ChatwithPdfPage extends StatefulWidget {
  const ChatwithPdfPage({super.key});

  @override
  State<ChatwithPdfPage> createState() => _ChatwithPdfPageState();
}

class _ChatwithPdfPageState extends State<ChatwithPdfPage> {
  late ChatWithPdfService chatWithPdfService;

  @override
  void initState() {
    OpenAIEmbeddings openAIEmbeddings = OpenAIEmbeddings(
        apiKey: "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");

    MemoryVectorStore memoryVectorStore =
        MemoryVectorStore(embeddings: openAIEmbeddings);
    chatWithPdfService = ChatWithPdfService(memoryVectorStore);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Pdf'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 11,
            child: Container(),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton.filled(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await chatWithPdfService.loadPdf();
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: GestureDetector(
                            onTap: () async {
                              await chatWithPdfService.searchLLM(
                                  query: "how is udesh");
                            },
                            child: Icon(Icons.send)),
                        labelText: 'Type a message',
                      ),
                    ),
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
