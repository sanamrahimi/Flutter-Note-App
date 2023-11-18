import 'package:flutter/material.dart';
import 'package:note_app/Models/notes.dart';
import 'package:note_app/screens/database/db_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DBHelper? dbHelper;
  late Future<List<NotesModel>> notesList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbHelper = DBHelper();
    loadData();
  }

  loadData() async {
    notesList = dbHelper!.getNotesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes SQL App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
              child: FutureBuilder(
                  future: notesList,
                  builder: (context, AsyncSnapshot<List<NotesModel>> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          itemCount: snapshot.data?.length,
                          reverse: false,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                dbHelper!.update(NotesModel(
                                    id: snapshot.data![index].id!,
                                    title: 'first note',
                                    age: 12,
                                    description: 'first note app updated',
                                    email: 'dddddd'));
                                setState(() {
                                  notesList = dbHelper!.getNotesList();
                                });
                              },
                              child: Dismissible(
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  child: const Icon(Icons.delete_forever),
                                ),
                                onDismissed: (DismissDirection direction) {
                                  setState(() {
                                    dbHelper!.delete(snapshot.data![index].id!);
                                    notesList = dbHelper!.getNotesList();
                                    snapshot.data!
                                        .remove(snapshot.data![index]);
                                  });
                                },
                                key: ValueKey<int>(snapshot.data![index].id!),
                                child: Card(
                                  child: ListTile(
                                    title: Text(
                                        snapshot.data![index].title.toString()),
                                    subtitle: Text(snapshot
                                        .data![index].description
                                        .toString()),
                                    trailing: Text(
                                        snapshot.data![index].age.toString()),
                                  ),
                                ),
                              ),
                            );
                          });
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          dbHelper!
              .insert(NotesModel(
            title: 'Lorem ipsum',
            age: 12,
            description:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat',
            email: 'example@gmail.com',
          ))
              .then((value) {
            print('data added');
            setState(() {
              notesList = dbHelper!.getNotesList();
            });
          }).onError((error, stackTrace) {
            print('error');
            print(error.toString());
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
