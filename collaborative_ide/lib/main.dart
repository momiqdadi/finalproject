import 'package:collaborative_ide/screens/login.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadGapi();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC7Zv5Jglti_nhecF-XiJjBSn9ZJZJPV2I",
      appId: "1:748620792888:web:203ee067f1782fb33a92cd",
      messagingSenderId: "748620792888",
      projectId: "idecollab-b20fc",
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TextController(),
        ),
      ],
      child: const MaterialApp(home: SignInScreen()),
    ),
  );
}

Future<void> _loadGapi() async {
  await Future.delayed(Duration(seconds: 1));
}

class WebSocketExample extends StatefulWidget {
  String path;

  WebSocketExample({super.key, required this.path});

  @override
  _WebSocketExampleState createState() => _WebSocketExampleState();
}

class _WebSocketExampleState extends State<WebSocketExample> {
  static const String kUrl = 'http://localhost:9090';
  static const String wsUrl = 'ws://localhost:8080';

  late final WebSocketChannel channel;
  late final TextEditingController _controller;
  late final TextEditingController _sessionController;
  late final TextController textController;
  bool isConnected = false;
  String? currentSessionId;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _sessionController = TextEditingController();

    loadFileContent(widget.path);
    initializeWebSocket();
  }

  void initializeWebSocket() {
    try {
      channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      setupWebSocketListener();
      setState(() => isConnected = true);
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
      setState(() => isConnected = false);
    }
  }

  void setupWebSocketListener() {
    channel.stream.listen(
      (dynamic message) {
        handleWebSocketMessage(message.toString());
      },
      onError: (error) {
        print('WebSocket error: $error');
        setState(() => isConnected = false);
      },
      onDone: () {
        print('WebSocket connection closed');
        setState(() => isConnected = false);
      },
    );
  }

  void handleWebSocketMessage(String message) {
    print('Received message: $message');

    if (message.startsWith('Joined session:')) {
      handleSessionJoined(message);
    } else if (message.startsWith('message:')) {
      handleCollaborativeEdit(message);
    } else if (message.startsWith('error:')) {
      handleError(message);
    }
  }

  void handleSessionJoined(String message) {
    var parts = message.split(', Path: ');
    if (parts.length == 2) {
      var path = parts[1].trim();
      setState(() {
        widget.path = path;
      });
      print('Session joined successfully. Path: $path');
      loadFileContent(path);
    }
  }

  void handleCollaborativeEdit(String message) {
    if (currentSessionId == null) return;

    String messagePrefix = 'message:$currentSessionId:';
    if (message.startsWith(messagePrefix)) {
      String newContent = message.substring(messagePrefix.length);

      // Only update if the content is different to avoid loops
      if (newContent != _controller.text) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.value = TextEditingValue(
            text: newContent,
            selection: TextSelection.fromPosition(
              TextPosition(offset: newContent.length),
            ),
          );
          Provider.of<TextController>(context, listen: false)
              .updateText(newContent);
        });
      }
    }
  }

  void handleError(String message) {
    String errorMessage = message.substring('error:'.length);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $errorMessage'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> loadFileContent(String path) async {
    try {
      var dio = Dio();
      var response = await dio.get(
        "$kUrl/files",
        queryParameters: {'fileName': path},
      );

      if (response.statusCode == 200) {
        setState(() {
          _controller.text = response.data;
          Provider.of<TextController>(context, listen: false)
              .updateText(response.data);
        });
      }
    } catch (e) {
      print('Error loading file content: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load file content'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void createSession() {
    String sessionId = _sessionController.text.trim();
    if (sessionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a session ID')),
      );
      return;
    }

    channel.sink.add('create:$sessionId, ${widget.path}');
    currentSessionId = sessionId;
    print('Creating session: $sessionId');
  }

  void joinSession() {
    String sessionId = _sessionController.text.trim();
    if (sessionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a session ID')),
      );
      return;
    }

    channel.sink.add('join:$sessionId');
    currentSessionId = sessionId;
    print('Joining session: $sessionId');
  }

  Future<void> executeFile() async {
    try {
      var dio = Dio();
      var response = await dio.get(
        "$kUrl/execute",
        queryParameters: {'path': widget.path},
      );

      Provider.of<TextController>(context, listen: false)
          .updateResponse(response.data);
      print('Execution response: ${response.data}');
    } catch (e) {
      handleDioError(e);
    }
  }

  Future<void> saveFile() async {
    try {
      var dio = Dio();
      var content = Provider.of<TextController>(context, listen: false).text;
      var request = {
        'fileName': widget.path,
        'content': content,
      };

      final response = await dio.put("$kUrl/files", queryParameters: request);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File saved successfully')),
        );
      }
    } catch (e) {
      handleDioError(e);
    }
  }

  Future<void> deleteFile() async {
    try {
      var dio = Dio();
      final response = await dio.delete(
        "$kUrl/files",
        queryParameters: {"fileName": widget.path},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File deleted successfully')),
        );
      }
    } catch (e) {
      handleDioError(e);
    }
  }

  void handleDioError(dynamic error) {
    if (error is DioException) {
      print('Dio error!');
      print('STATUS: ${error.response?.statusCode}');
      print('DATA: ${error.response?.data}');
      print('HEADERS: ${error.response?.headers}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error: ${error.response?.statusCode ?? 'Unknown error'}'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      print('Error occurred: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IDEX'),
        actions: [
          // Connection status indicator
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConnected ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Session controls
            TextField(
              controller: _sessionController,
              decoration: const InputDecoration(
                labelText: 'Session ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isConnected ? createSession : null,
                  child: const Text('Create Session'),
                ),
                ElevatedButton(
                  onPressed: isConnected ? joinSession : null,
                  child: const Text('Join Session'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Code editor
            Expanded(
              child: Consumer<TextController>(
                builder: (context, textController, child) {
                  return TextField(
                    maxLines: null,
                    expands: true,
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter your code...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      textController.updateText(value);
                      if (currentSessionId != null && isConnected) {
                        channel.sink.add('message:$currentSessionId:$value');
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Execution output
            Expanded(
              child: Consumer<TextController>(
                builder: (context, textController, child) {
                  return Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        textController.response,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: executeFile,
                    child: const Text('Execute'),
                  ),
                  ElevatedButton(
                    onPressed: saveFile,
                    child: const Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: deleteFile,
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    _controller.dispose();
    _sessionController.dispose();
    super.dispose();
  }
}

class TextController extends ChangeNotifier {
  String _text = '';
  String _responseText = '';

  String get text => _text;
  String get response => _responseText;

  void updateText(String value) {
    _text = value;
    notifyListeners();
  }

  void updateResponse(String value) {
    _responseText = value;
    notifyListeners();
  }
}
