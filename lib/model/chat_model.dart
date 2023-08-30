// To parse this JSON data, do
//
//     final chatModel = chatModelFromJson(jsonString);

import 'dart:convert';

ChatModel chatModelFromJson(String str) => ChatModel.fromJson(json.decode(str));

String chatModelToJson(ChatModel data) => json.encode(data.toJson());

class ChatModel {
    String prompt;
    String query;
    String timestamp;

    ChatModel({
        required this.prompt,
        required this.query,
        required this.timestamp,
    });

    factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        prompt: json["prompt"],
        query: json["query"],
        timestamp: json["timestamp"],
    );

    Map<String, dynamic> toJson() => {
        "prompt": prompt,
        "query": query,
        "timestamp": timestamp,
    };
}
