import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class home_page extends StatefulWidget {
  const home_page({Key? key}) : super(key: key);

  @override
  _home_pageState createState() => _home_pageState();
}

class _home_pageState extends State<home_page> {
  bool processing = false;
  late int protein;
  late int carbs;
  late int calories;
  late int fat;
  String proteinNew = '0';
  String carbsNew = '0';
  String caloriesNew = '0';
  String fatNew = '0';
  bool imageLoad = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userid = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference ref = FirebaseFirestore.instance.collection('macros');
  CollectionReference reff = FirebaseFirestore.instance.collection('food');
  File? img;
  String food_name = '';

  Future loadimage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      img = File(image!.path);
    });
  }

  Future processImage(File imageFile) async {
    final request = http.MultipartRequest(
        "POST", Uri.parse("http://192.168.100.209:5000/process_image"));

    request.headers['content-type'] = 'multipart/form-data';

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    request.fields['image'] = base64Image;

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);

      final prediction = json.decode(responseString)['prediction'];
      var snapshot = await FirebaseFirestore.instance
          .collection('food')
          .doc(prediction.toString())
          .get();

      setState(() {
        food_name = snapshot.get('name');
        proteinNew = snapshot.get('protein').toString();
        carbsNew = snapshot.get('carbs').toString();
        caloriesNew = snapshot.get('calories').toString();
        fatNew = snapshot.get('fat').toString();
        processing = true;
      });
      return prediction;
    } else {
      throw Exception('Failed to process image');
    }
  }

  Future imagedialoge(int i) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Center(
                child: processing == true
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 2, 55, 101),
                      ))
                    : Text(
                        '$food_name has',
                        style: const TextStyle(fontSize: 30),
                      )),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Protein',
                          style: TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Container(
                            decoration: const BoxDecoration(
                                color: Color.fromRGBO(2, 55, 101, 0.9),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                            width: 90,
                            height: 90,
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Text(
                                proteinNew,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white),
                              ),
                            ))
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Carbs',
                          style: TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Container(
                            decoration: const BoxDecoration(
                                color: Color.fromRGBO(2, 55, 101, 0.9),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                            width: 90,
                            height: 90,
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Text(
                                carbsNew,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white),
                              ),
                            ))
                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Calories',
                          style: TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Container(
                            decoration: const BoxDecoration(
                                color: Color.fromRGBO(2, 55, 101, 0.9),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                            width: 90,
                            height: 90,
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Text(
                                caloriesNew,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white),
                              ),
                            ))
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'fat',
                          style: TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Container(
                            decoration: const BoxDecoration(
                                color: Color.fromRGBO(2, 55, 101, 0.9),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                            width: 90,
                            height: 90,
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Text(
                                fatNew,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white),
                              ),
                            ))
                      ],
                    )
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel',
                      style:
                          TextStyle(color: Color.fromARGB(255, 2, 55, 101)))),
              TextButton(
                onPressed: () {
                  caloriesNew ??= '0';

                  FirebaseFirestore.instance
                      .collection('macros')
                      .doc(userid)
                      .update({
                    'calories': calories + int.parse(caloriesNew),
                    'carbs': carbs + int.parse(carbsNew),
                    'fat': fat + int.parse(fatNew),
                    'protein': protein + int.parse(proteinNew)
                  });

                  setState(() {
                    proteinNew = '0';
                    fatNew = '0';
                    caloriesNew = '0';
                    carbsNew = '0';
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Add',
                    style: TextStyle(color: Color.fromARGB(255, 2, 55, 101))),
              )
            ],
            actionsAlignment: MainAxisAlignment.spaceAround,
          ));

  Future opendialoge() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            key: _formKey,
            title: const Center(child: Text('Macros')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(hintText: 'Protein'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    if (value.isEmpty) {
                      proteinNew = '0';
                    } else {
                      proteinNew = value;
                    }
                  },
                ),
                TextField(
                  decoration: const InputDecoration(hintText: 'Carbs'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    if (value.isEmpty) {
                      carbsNew = '0';
                    } else {
                      carbsNew = value;
                    }
                  },
                ),
                TextField(
                  decoration: const InputDecoration(hintText: 'Calories'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    if (value.isEmpty) {
                      caloriesNew = '0';
                    } else {
                      caloriesNew = value;
                    }
                  },
                ),
                TextField(
                  decoration: const InputDecoration(hintText: 'Fat'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    if (value.isEmpty) {
                      fatNew = '0';
                    } else {
                      fatNew = value;
                    }
                  },
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel',
                      style:
                          TextStyle(color: Color.fromARGB(255, 2, 55, 101)))),
              TextButton(
                  onPressed: () {
                    caloriesNew ??= '0';

                    FirebaseFirestore.instance
                        .collection('macros')
                        .doc(userid)
                        .update({
                      'calories': calories + int.parse(caloriesNew),
                      'carbs': carbs + int.parse(carbsNew),
                      'fat': fat + int.parse(fatNew),
                      'protein': protein + int.parse(proteinNew)
                    });

                    setState(() {
                      proteinNew = '0';
                      fatNew = '0';
                      caloriesNew = '0';
                      carbsNew = '0';
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add',
                      style: TextStyle(color: Color.fromARGB(255, 2, 55, 101))))
            ],
            actionsAlignment: MainAxisAlignment.spaceAround,
          ));

  Future alertdialoge() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: const Text("Are you sure that you want to reset?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel',
                    style: TextStyle(color: Color.fromARGB(255, 2, 55, 101)))),
            TextButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('macros')
                      .doc(userid)
                      .update(
                          {'calories': 0, 'carbs': 0, 'fat': 0, 'protein': 0});
                  Navigator.of(context).pop();
                },
                child: const Text("Reset",
                    style: TextStyle(color: Color.fromARGB(255, 2, 55, 101))))
          ],
          actionsAlignment: MainAxisAlignment.spaceAround,
        ),
      );

  Widget buildPage(int protein, int carbs, int calories, int fat) => Center(
          child: SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text(
                    'Protein',
                    style: TextStyle(
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Container(
                      decoration: const BoxDecoration(
                          color: Color.fromRGBO(2, 55, 101, 0.9),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      width: 140,
                      height: 140,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          "$protein",
                          style: const TextStyle(
                              fontSize: 30,
                              fontStyle: FontStyle.italic,
                              color: Colors.white),
                        ),
                      ))
                ],
              ),
              Column(
                children: [
                  const Text(
                    'Carbs',
                    style: TextStyle(
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Container(
                      decoration: const BoxDecoration(
                          color: Color.fromRGBO(2, 55, 101, 0.9),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      width: 140,
                      height: 140,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          '$carbs',
                          style: const TextStyle(
                              fontSize: 30,
                              fontStyle: FontStyle.italic,
                              color: Colors.white),
                        ),
                      ))
                ],
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text(
                    'Calories',
                    style: TextStyle(
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Container(
                      decoration: const BoxDecoration(
                          color: Color.fromRGBO(2, 55, 101, 0.9),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      width: 140,
                      height: 140,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          '$calories',
                          style: const TextStyle(
                              fontSize: 30,
                              fontStyle: FontStyle.italic,
                              color: Colors.white),
                        ),
                      ))
                ],
              ),
              Column(
                children: [
                  const Text(
                    'fat',
                    style: TextStyle(
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Container(
                      decoration: const BoxDecoration(
                          color: Color.fromRGBO(2, 55, 101, 0.9),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      width: 140,
                      height: 140,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          '$fat',
                          style: const TextStyle(
                              fontSize: 30,
                              fontStyle: FontStyle.italic,
                              color: Colors.white),
                        ),
                      ))
                ],
              )
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {
                  opendialoge();
                },
                color: const Color.fromARGB(255, 2, 55, 101),
                textColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.add,
                ),
              ),
              MaterialButton(
                onPressed: () async {
                  await loadimage();
                  setState(() {
                    processing = true;
                  });
                  imagedialoge(await processImage(img!));
                  setState(() {
                    processing = false;
                  });
                },
                color: const Color.fromARGB(255, 2, 55, 101),
                textColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.camera_alt,
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {
                  alertdialoge();
                },
                color: const Color.fromARGB(255, 2, 55, 101),
                textColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.refresh,
                ),
              ),
            ],
          )
        ]),
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout))
        ],
        backgroundColor: const Color.fromARGB(255, 2, 55, 101),
        centerTitle: true,
        title: const Text('Fit Vision'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('macros')
            .doc(userid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Color.fromARGB(255, 2, 55, 101),
            ));
          }

          if (snapshot.data!['date'] != DateTime.now().day) {
            FirebaseFirestore.instance.collection('macros').doc(userid).update({
              'protein': 0,
              'carbs': 0,
              'fat': 0,
              'calories': 0,
              'date': DateTime.now().day
            });
          }

          protein = snapshot.data!['protein'];
          carbs = snapshot.data!['carbs'];
          calories = snapshot.data!['calories'];
          fat = snapshot.data!['fat'];

          return snapshot.hasData
              ? buildPage(snapshot.data!['protein'], snapshot.data!['carbs'],
                  snapshot.data!['calories'], snapshot.data!['fat'])
              : const Text('No data');
        },
      ),
    );
  }
}
