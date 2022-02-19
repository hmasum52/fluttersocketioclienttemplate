import 'package:fluttersocketioclient/models/chat_message.dart';

class Dummy {
  static ChatMessage messageTo = ChatMessage(
      senderId: "1",
      sender: "Masum",
      receiver: "Abrar",
      receiverId: "2",
      message: "Hello world",
      sentTime: DateTime.now());

  static ChatMessage messageFrom = ChatMessage(
      senderId: "2",
      sender: "Abrar",
      receiver: "Masum",
      receiverId: "1",
      message: "Hello world",
      sentTime: DateTime.now());

  static List<ChatMessage> messageList(int size) {
    List<ChatMessage> messages = [];
    for (int i = 0; i < size; i++) {
      messages.add(i%2 == 0?  messageTo : messageFrom);
    }
    return messages;
  }
}
