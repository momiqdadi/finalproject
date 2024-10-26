import 'package:collaborative_ide/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Files extends StatelessWidget {
  final String folderName;
  final String? email;
  static const kUrl = 'http://localhost:9090';

  const Files({super.key, required this.folderName, required this.email});

  void create({String? fileName}) async {
    try {
      var dio = Dio();
      print(folderName);
      var response = await dio.post(
        "$kUrl/files",
        data: '$folderName/$fileName',
      );

      await dio.post(
        "$kUrl/user/add_file",
        queryParameters: {'email': email, 'fileName': '$folderName/$fileName'},
      );
      print('Response: ${response.data}');
    } catch (e) {
      if (e is DioException) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error occurred while executing file: $e');
      }
    }
  }

  Future<List<String>> get() async {
    try {
      var dio = Dio();

      var response = await dio.get('$kUrl/user/get_files',
          queryParameters: {'email': email, 'folder': folderName});

      List<String> folders = List<String>.from(response.data);
      return folders;
    } catch (e) {
      if (e is DioException) {
        print('Dio error!');
        print('STATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}');
        print('HEADERS: ${e.response?.headers}');
      } else {
        print('Error occurred while executing file: $e');
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<List<String>>(
                future: get(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No folders found.'));
                  } else {
                    List<String> projectList = snapshot.data!;
                    return ListView.builder(
                      itemCount: projectList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(projectList[index]),
                          onTap: () {
                            print('$folderName/${projectList[index]}');
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WebSocketExample(
                                    path: '$folderName/${projectList[index]}',
                                  ),
                                ));
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final TextEditingController folderNameController =
                  TextEditingController();

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Insert folder name:'),
                  content: TextField(
                    controller: folderNameController,
                    decoration: const InputDecoration(hintText: "Folder name"),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        final folderName = folderNameController.text;
                        if (folderName.isNotEmpty) {
                          create(fileName: folderName);
                        }
                        Navigator.of(context).pop();
                      },
                      child: const Text('Create'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Create File'),
          ),
        ],
      ),
    );
  }
}
