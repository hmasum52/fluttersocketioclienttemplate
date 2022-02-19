import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttersocketioclient/debug.dart';
import 'package:fluttersocketioclient/dummy.dart';
import 'package:fluttersocketioclient/models/chat_message.dart';
import 'package:fluttersocketioclient/models/scoket_events.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as sio;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter socket io client'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static String TAG = "MyHomePage";

  late sio.Socket socket;

  bool userId = true;

  List<ChatMessage> messages = [];

  ScrollController _messagListController = ScrollController();

  @override
  void initState() {
    super.initState();
    connectDartSocketClient();
  }

  void _sendMessage(String msg) {
    log.d(TAG, "_onMessageSent: $msg");

    ChatMessage chatMessage = ChatMessage(
        senderId: userId ? "1" : "2",
        sender: "Masum",
        receiver: "Abrar",
        receiverId: userId ? "2" : "1",
        message: msg,
        sentTime: DateTime.now());
    setState(() {
      messages.add(chatMessage);
      _scrollToBottom();
    });

    // send to server
    log.d(TAG, "sending: ${chatMessage.toJson()}");
    socket.emit(SocketEvents.SEND_MESSAGE, chatMessage.toJson());
  }

  void _scrollToBottom() {
    _messagListController.animateTo(
        _messagListController.position.maxScrollExtent,
        duration: Duration(milliseconds: 50),
        curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            userId = !userId;
            socket.emit(SocketEvents.USER_REGISTER, userId ? "1" : "2");
          });
        },
        child: Icon(userId ? Icons.toggle_on : Icons.toggle_off),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: width * 0.2),
        child: Column(
          children: [
            Expanded(
              child: MessageContainer(
                messages: messages,
                messageListController: _messagListController,
                userId: userId? "1" : "2",
              ),
            ),
            Container(
              child: SendMessageContainer(
                sendMessage: _sendMessage, 
              ),
            ),
          ],
        ),
      ),
    );
  }

  void connectDartSocketClient() {
    log.d(TAG, "inside dartSocketClient");
    String localHost = "http://localhost:3002";
    String url = "https://8doq1v.sse.codesandbox.io/";
    socket = sio.io(
        false ? url : localHost,
        sio.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect()
            .build());
    //https://stackoverflow.com/questions/68058896/latest-version-of-socket-io-nodejs-is-not-connecting-to-flutter-applications
    socket.connect();
    log.d(TAG, "socket connected: ${socket.connected}");
    //socket.onConnect((data) => null)
    socket.onConnect((data) {
      log.d(TAG, "connected");
      socket.emit(SocketEvents.USER_REGISTER, userId ? "1" : "2");
    });

    addSocketMessageListener();
  }

  void addSocketMessageListener() {
    socket.on(SocketEvents.RECEIVE_MESSAGE, (data) {
      log.d(TAG, "addSocketMessageListener $data");
      ChatMessage chatMessage = ChatMessage.fromJson(data);
      setState(() {
        messages.add(chatMessage);
        _scrollToBottom();
      });
    });
  }
}

class MessageContainer extends StatelessWidget {
  List<ChatMessage> messages;
  String userId;

  MessageContainer({
    Key? key,
    required this.messages,
    required this.messageListController,
    required this.userId,
  }) : super(key: key);

  ScrollController messageListController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      controller: messageListController,
      itemCount: messages.length + 1,
      itemBuilder: (BuildContext context, int idx) {
        return idx != messages.length
            ? MessageItem(chatMessage: messages[idx], userId: userId,)
            : Container(
                height: 70,
              );
      },
    );
  }
}

class MessageItem extends StatelessWidget {
  ChatMessage chatMessage;

  MessageItem({Key? key, required this.userId, required this.chatMessage})
      : super(key: key);

  bool sentByMe = true;
  String userId;

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('dd MMM yyyy, hh:mma');
    TextTheme textTheme = Theme.of(context).textTheme;
    sentByMe = chatMessage.senderId == userId;
    Color msgTextColor = sentByMe ? Colors.white : Colors.black;
    Color timeTextColor = sentByMe ? Colors.white70 : Colors.black87;

    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: sentByMe ? Colors.blue : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chatMessage.message,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(color: msgTextColor),
            ),
            Text(
              dateFormat.format(chatMessage.sentTime.toLocal()),
              style: textTheme.labelSmall?.copyWith(
                  color: timeTextColor,
                  fontFamily: GoogleFonts.openSans().fontFamily,
                  letterSpacing: 0.02),
            )
          ],
        ),
      ),
    );
  }
}

class SendMessageContainer extends StatelessWidget {
  static String TAG = "SendMessageContainer";
  Function sendMessage;

  SendMessageContainer({
    Key? key,
    required this.sendMessage,
  }) : super(key: key);

  TextEditingController msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        style: Theme.of(context).textTheme.subtitle1,
        cursorColor: Colors.amber,
        controller: msgController,
        onSubmitted: (value) {
          log.d(TAG, value);
          if (value != "") {
            sendMessage(value);
            msgController.text = "";
          }
        },
        decoration: InputDecoration(
          labelText: "Enter message",
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          labelStyle: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: Theme.of(context).textTheme.subtitle2?.fontSize,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).primaryColor,
              ),
              child: IconButton(
                onPressed: () {
                  String msg = msgController.text;
                  if (msg != "") {
                    sendMessage(msg);
                    msgController.text = "";
                  }
                },
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
