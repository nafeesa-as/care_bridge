/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carebridge/components/my_button.dart';
import 'package:carebridge/components/my_textfield.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final childnameController = TextEditingController();
  final ageController = TextEditingController();
  // sign user in method
  void signUserUp() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // try creating the user
    try {
      if (passwordController.text == confirmpasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        showErrorMessage("Passwords don't match");
      }
      // pop the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      Navigator.pop(context);
      // show error message
      showErrorMessage(e.code);
    }
    addUserDetails(
      usernameController.text.trim(),
      childnameController.text.trim(),
      emailController.text.trim(),
      int.parse(ageController.text.trim()),
    );
  }

  // error message to user
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Center(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }

  Future addUserDetails(
    String username,
    String childname,
    String email,
    int age,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
          'username': username,
          'childname': childname,
          'age': age,
          'email': email,
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 5),

                // logo
                Image.asset('lib/images/carebridge.jpg', height: 70),
                SizedBox(width: 10),

                // Create an Account
                Text(
                  'Create an Account',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),

                const SizedBox(height: 15),

                // username textfield
                MyTextField(
                  controller: usernameController,
                  hintText: 'username',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // childname textfield
                MyTextField(
                  controller: childnameController,
                  hintText: 'Child\'s name',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // childage textfield
                MyTextField(
                  controller: ageController,
                  hintText: 'Child\'s age',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // email textfield
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // Confirm password textfield
                MyTextField(
                  controller: confirmpasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // sign in button
                MyButton(text: "Sign Up", onTap: signUserUp),

                const SizedBox(height: 20),

                // already have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.black, fontSize: 17),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carebridge/components/my_button.dart';
import 'package:carebridge/components/my_textfield.dart';
import 'package:intl/intl.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final childnameController = TextEditingController();
  String? selectedGender;
  DateTime? selectedDate;
  final TextEditingController dobController =
      TextEditingController(); // New controller for DOB

  // Method to show date picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000), // Earliest date
      lastDate: DateTime.now(), // Latest date (current date)
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        dobController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(pickedDate); // Format date
      });
    }
  }

  // sign user in method
  void signUserUp() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // try creating the user
    try {
      if (passwordController.text != confirmpasswordController.text) {
        Navigator.pop(context); // Close loading dialog
        showErrorMessage("Passwords don't match");
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // pop the loading circle
      Navigator.pop(context);

      // Convert DOB to Timestamp (Milliseconds Since Epoch)
      int dobTimestamp = selectedDate!.millisecondsSinceEpoch;

      // Store user details in Firestore
      await addUserDetails(
        usernameController.text.trim(),
        emailController.text.trim(),
        childnameController.text.trim(),
        dobTimestamp,
        selectedGender ?? 'Not specified', // Store DOB as an int timestamp
      );
    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      Navigator.pop(context);
      // show error message
      showErrorMessage(e.code);
    }
  }

  // error message to user
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Center(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }

  Future<void> addUserDetails(
    String username,
    String email,
    String childname,
    int dobTimestamp,
    String gender,
  ) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);

      await docRef.set({
        'username': username,
        'email': email,
        'childname': childname,
        'dob': dobTimestamp,
        'gender': gender,
      });

      // Verify data was stored by retrieving it
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw Exception("Data was not stored in Firestore");
      }

      print("User registered successfully in Firestore!");
    } catch (e) {
      print("Error adding user details to Firestore: $e");
      showErrorMessage("Error saving user data: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // logo
                Image.asset('lib/images/carebridge.jpg', height: 70),
                SizedBox(width: 10),

                // Create an Account
                Text(
                  'Create an Account',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),

                const SizedBox(height: 10),

                // username textfield
                MyTextField(
                  controller: usernameController,
                  hintText: 'username',
                  obscureText: false,
                ),
                const SizedBox(height: 5),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 5),

                // childname textfield
                MyTextField(
                  controller: childnameController,
                  hintText: 'Child\'s name',
                  obscureText: false,
                ),

                const SizedBox(height: 5),
                // childage textfield
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 5,
                  ),
                  child: TextField(
                    controller: dobController,
                    readOnly: true, // Prevents keyboard input
                    decoration: InputDecoration(
                      hintText: "Child's DOB",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: Colors.grey[500],
                      ), // Calendar icon
                    ),
                    onTap:
                        () => _selectDate(context), // Show date picker on tap
                  ),
                ),
                const SizedBox(height: 5),

                // Gender dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 5,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.grey.shade200,
                        isExpanded: true,
                        hint: Text(
                          "Child's Gender",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),

                        value: selectedGender,
                        icon: const Icon(Icons.arrow_drop_down),
                        elevation: 16,
                        borderRadius: BorderRadius.circular(4),
                        style: const TextStyle(color: Colors.black),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedGender = newValue;
                          });
                        },
                        items:
                            <String>[
                              'Male',
                              'Female',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 5),

                // Confirm password textfield
                MyTextField(
                  controller: confirmpasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(height: 5),

                // sign up button
                MyButton(text: "Sign Up", onTap: signUserUp),

                const SizedBox(height: 20),

                // already have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.black, fontSize: 17),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
