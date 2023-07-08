import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fit_vision/widgets/auth_widgets.dart';

class login extends StatefulWidget {
  const login({Key? key}) : super(key: key);

  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {
  late String email;
  late String pass;
  bool processing_row = false;
  bool processing = false;
  bool password = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  bool passwordVisible = false;

  void logIn() async {
    setState(() {
      processing = true;
    });
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: pass);

        int day = DateTime.now().day;

        _formKey.currentState!.reset();

        Navigator.pushReplacementNamed(context, '/home_page');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          setState(() {
            processing = false;
          });
          MyMessageHandler.showSnackBar(
              _scaffoldKey, 'No user found for that email.');
        } else if (e.code == 'wrong-password') {
          setState(() {
            processing = false;
          });
          MyMessageHandler.showSnackBar(
              _scaffoldKey, 'Wrong password provided for that user.');
        }
      }
    } else {
      setState(() {
        processing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
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
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 100),
                      child: Image.asset(
                        'lib/images/logo.png',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'please enter your email ';
                                  } else if (value.isValidEmail() == false) {
                                    return 'invalid email';
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
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color:
                                                Color.fromARGB(255, 2, 55, 101),
                                            width: 1),
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: const BorderSide(
                                            color:
                                                Color.fromARGB(255, 2, 55, 101),
                                            width: 1)))),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
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
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  processing == true
                      ? const Center(
                          child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 2, 55, 101),
                        ))
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AuthMainButton(
                            mainButtonLabel: 'Log In',
                            onPressed: () {
                              logIn();
                            },
                          ),
                        ),
                  processing_row == true
                      ? const Center(
                          child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 2, 55, 101),
                        ))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? "),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    processing_row = true;
                                  });
                                  Navigator.pushReplacementNamed(
                                      context, '/sign_up');
                                },
                                child: const Text(
                                  'Sign up',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 2, 55, 101),
                                      fontStyle: FontStyle.italic),
                                ))
                          ],
                        )
                ],
              ),
            ),
          ),
        ));
  }
}
