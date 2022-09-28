import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String contactsBoxName = "contacts";

@HiveType(typeId: 1)
enum Relationship {
  @HiveField(0)
  Family,
  @HiveField(1)
  Friend,
}

const relationshipString = <Relationship, String>{
  Relationship.Family: "Family",
  Relationship.Friend: "Friend",
};

@HiveType(typeId: 0)
class Contact {
  @HiveField(0)
  String name;
  @HiveField(1)
  int age;
  @HiveField(2)
  Relationship relationship;
  @HiveField(3)
  String phoneNumber;

  Contact(this.name, this.age, this.phoneNumber, this.relationship);
}

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter<Contact>(ContactAdapter());
  Hive.registerAdapter<Relationship>(RelationshipAdapter());
  await Hive.openBox<Contact>(contactsBoxName);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contacts App',
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          backgroundColor: Colors.green,
          centerTitle: true,
          title: Text('Contacts App with Hive'),
        ),
        body: ValueListenableBuilder(
          valueListenable: Hive.box<Contact>(contactsBoxName).listenable(),
          builder: (context, Box<Contact> box, _) {
            if (box.values.isEmpty)
              return Center(
                child: Text("No contacts"),
              );
            return ListView.builder(
              itemCount: box.values.length,
              itemBuilder: (context, index) {
                Contact? currentContact = box.getAt(index);
                String? relationship =
                    relationshipString[currentContact?.relationship];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (ctxt) => AlertDialog(
                          content: Text(
                            "Do you want to delete ${currentContact?.name}?",
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text("No"),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: Text("Yes"),
                              onPressed: () async {
                                await box.deleteAt(index);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 5),
                          Text(currentContact?.name ?? ""),
                          SizedBox(height: 5),
                          Text(currentContact?.phoneNumber ?? ""),
                          SizedBox(height: 5),
                          Text("Age: ${currentContact?.age ?? ""}"),
                          SizedBox(height: 5),
                          Text("Relationship: $relationship"),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              backgroundColor: Colors.green,
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AddContact()));
              },
            );
          },
        ),
      ),
    );
  }
}

class AddContact extends StatefulWidget {
  final formKey = GlobalKey<FormState>();

  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  String? name;
  int? age;
  String? phoneNumber;
  Relationship? relationship;

  void onFormSubmit() {
    if (widget.formKey.currentState?.validate() ?? true) {
      Box<Contact> contactsBox = Hive.box<Contact>(contactsBoxName);
      contactsBox.add(Contact(name!, age!, phoneNumber!, relationship!));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: widget.formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    autofocus: true,
                    initialValue: "",
                    decoration: const InputDecoration(
                      fillColor: Colors.green,
                      labelText: "Name",
                    ),
                    onChanged: (value) {
                      setState(() {
                        name = value;
                      });
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    initialValue: "",
                    maxLength: 3,
                    decoration: const InputDecoration(
                      labelText: "Age",
                    ),
                    onChanged: (value) {
                      setState(() {
                        age = int.parse(value);
                      });
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    initialValue: "",
                    decoration: const InputDecoration(
                      labelText: "Phone",
                    ),
                    onChanged: (value) {
                      setState(() {
                        phoneNumber = value;
                      });
                    },
                  ),
                  DropdownButton<Relationship>(
                    items: relationshipString.keys.map((Relationship value) {
                      return DropdownMenuItem<Relationship>(
                        value: value,
                        child: Text(relationshipString[value] ?? ""),
                      );
                    }).toList(),
                    value: relationship,
                    hint: Text("Relationship"),
                    onChanged: (value) {
                      setState(() {
                        relationship = value;
                      });
                    },
                  ),
                  TextButton(
                    child: Text("Submit"),
                    onPressed: onFormSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RelationshipAdapter extends TypeAdapter<Relationship> {
  @override
  final typeId = 1;

  @override
  Relationship read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Relationship.Family;
      case 1:
        return Relationship.Friend;
      default:
        return Relationship.Family;
    }
  }

  @override
  void write(BinaryWriter writer, Relationship obj) {
    switch (obj) {
      case Relationship.Family:
        writer.writeByte(0);
        break;
      case Relationship.Friend:
        writer.writeByte(1);
        break;
    }
  }
}

class ContactAdapter extends TypeAdapter<Contact> {
  @override
  final typeId = 0;

  @override
  Contact read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Contact(
      fields[0] as String,
      fields[1] as int,
      fields[3] as String,
      fields[2] as Relationship,
    );
  }

  @override
  void write(BinaryWriter writer, Contact obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.relationship)
      ..writeByte(3)
      ..write(obj.phoneNumber);
  }
}
