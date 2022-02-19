class ChatMessage {
    ChatMessage({
        required this.sender,
        required this.senderId,
        required this.receiver,
        required this.receiverId,
        required this.message,
        required this.sentTime,
    });

    String sender;
    String senderId;
    String receiver;
    String receiverId;
    String message;
    DateTime sentTime;

    factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        sender: json["sender"],
        senderId: json["sender_id"],
        receiver: json["receiver"],
        receiverId: json["receiver_id"],
        message: json["message"],
        sentTime: DateTime.parse(json["sent_time"]),
    );

    Map<String, dynamic> toJson() => {
        "sender": sender,
        "sender_id": senderId,
        "receiver": receiver,
        "receiver_id": receiverId,
        "message": message,
        "sent_time": sentTime.toIso8601String(),
    };
}
// https://app.quicktype.io/
/*
{
    "sender" : "Masum",
    "sender_id": "1",
    "receiver" : "Abrar",
    "receiver_id" : "2",
    "message" : "Hello world",
    "sent_time" : "2022-02-12T09:15:06.000Z"
}
*/