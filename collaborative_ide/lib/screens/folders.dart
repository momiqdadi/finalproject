import 'package:collaborative_ide/screens/files.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Folders extends StatelessWidget {
  final String? email;
  const Folders({super.key, this.email});
  static const kUrl = 'http://localhost:9090';

  void create({String? folderName}) async {
    try {
      var dio = Dio();
      var response = await dio.post(
        "$kUrl/folder",
        data: '$folderName',
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
      var response = await dio
          .get('$kUrl/user/get_folders', queryParameters: {'email': email});
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Files(
                                    folderName: projectList[index],
                                    email: email,
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
                          create(folderName: folderName);
                          Navigator.of(context).pop();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Files(
                                  folderName: folderName,
                                  email: email,
                                ),
                              ));
                        }
                      },
                      child: const Text('Create'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Create Folder'),
          ),
        ],
      ),
    );
  }
}
