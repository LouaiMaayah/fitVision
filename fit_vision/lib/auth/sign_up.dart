import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fit_vision/widgets/auth_widgets.dart';

class register extends StatefulWidget {
  const register({Key? key}) : super(key: key);

  @override
  _registerState createState() => _registerState();
}

class _registerState extends State<register> {
  late String name;
  late String email;
  late String pass;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  bool password = false;
  bool valid = false;
  bool processing = false;

  CollectionReference macros = FirebaseFirestore.instance.collection('macros');

  Future<void> signUp(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          processing = true;
        });

        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: pass);
        await macros.doc(FirebaseAuth.instance.currentUser!.uid).set({
          'protein': 0,
          'carbs': 0,
          'calories': 0,
          'fat': 0,
          'date': DateTime.now().day
        });
        valid = true;

        processing = true;
        Navigator.pushReplacementNamed(context, '/login');
      } on FirebaseAuthException catch (e) {
        setState(() {
          processing = false;
        });
        if (e.code == 'weak-password') {
          setState(() {
            processing = false;
          });
          MyMessageHandler.showSnackBar(
              _scaffoldKey, 'The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          setState(() {
            processing = false;
          });
          MyMessageHandler.showSnackBar(
              _scaffoldKey, 'The email provided is already in use.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        key: _scaffoldKey,
        child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(children: [
                    const SizedBox(height: 90),
                    Center(child: Image.asset('lib/images/logo.png')),
                    const SizedBox(
                      height: 70,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "please enter full name";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                name = value;
                              },
                              decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  hintText: 'Enter your full name',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color:
                                              Color.fromARGB(255, 2, 55, 101),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(25)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: const BorderSide(
                                          color: Colors.deepPurpleAccent,
                                          width: 1))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "please enter your email";
                                } else if (value.isValidEmail() == false) {
                                  return "inavlid email";
                                } else if (value.isValidEmail() == true) {
                                  return null;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                email = value;
                              },
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  labelText: 'Email Adress',
                                  hintText: 'Enter your email',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color:
                                              Color.fromARGB(255, 2, 55, 101),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(25)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: const BorderSide(
                                          color:
                                              Color.fromARGB(255, 2, 55, 101),
                                          width: 1))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "please enter password";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                pass = value;
                              },
                              obscureText: !password,
                              decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        password = !password;
                                      });
                                    },
                                    icon: Icon(
                                      password
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: const Color.fromARGB(255, 2, 55, 101),
                                    ),
                                  ),
                                  labelText: 'Password',
                                  hintText: 'Enter your password',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color:
                                              Color.fromARGB(255, 2, 55, 101),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(25)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: const BorderSide(
                                          color:
                                              Color.fromARGB(255, 2, 55, 101),
                                          width: 1))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(
                              fontSize: 16, fontStyle: FontStyle.italic),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, "/login");
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 2, 55, 101),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    processing == true
                        ? const Center(
                            child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 2, 55, 101),
                          ))
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AuthMainButton(
                              mainButtonLabel: 'Sign Up',
                              onPressed: () {
                                signUp(context);
                              },
                            ),
                          ),
                  ])),
            )));
  }
}
