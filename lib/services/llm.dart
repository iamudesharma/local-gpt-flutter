import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain/src/documents/transformers/text_splitters/character.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:langchain/src/chains/question_answering/stuff.dart';
import 'package:local_gpt_flutter/utils/pdf_picker.dart';
// import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ChatWithPdfService {
  final MemoryVectorStore memoryVectorStore;

  ChatWithPdfService(this.memoryVectorStore);

  loadPdf() async {
    final pickPdf = await pdfPicker();

    if (pickPdf != null) {
      final path = await getPDFtext(pickPdf);

      _loadPdf(path: path, memoryVectorStore: memoryVectorStore);
    }
  }

  searchLLM({required String query}) async {
    final openAi =
        OpenAI(apiKey: "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");

    final docs = await memoryVectorStore.similaritySearch(query: query, k: 4);

    final langchain = StuffDocumentsQAChain(
      llm: openAi,
    );

    langchain.run(docs[0]);
  }
}

Future<String> getPDFtext(dynamic path) async {
  // ignore: unnecessary_type_check
  if (path is File) {
    final PdfDocument document =
        PdfDocument(inputBytes: path.readAsBytesSync());
//Extract the text from all the pages.
    String text = PdfTextExtractor(document).extractText();
    print(text);
//Dispose the document.
    document.dispose();
    return text;
  } else {
    if (kIsWeb) {
      Uint8List _path = path;
      final PdfDocument document =
          PdfDocument(inputBytes: _path.buffer.asUint8List());
//Extract the text from all the pages.
      String text = PdfTextExtractor(document).extractText();
      print(text);
//Dispose the document.
      document.dispose();
      return text;
    }
    return "";
  }
  //Load an existing PDF document.
}

_loadPdf(
    {required String path,
    required MemoryVectorStore memoryVectorStore}) async {
  final pdfText = await getPDFtext(path);

  final text_splitters = RecursiveCharacterTextSplitter();

  final data = text_splitters.createDocuments(
    text_splitters.splitText(pdfText),
  );

  memoryVectorStore.addDocuments(documents: data);
}
