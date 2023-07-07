import 'dart:io';
import 'package:chatapp/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  File? _selectedImage;
  var _isAuthenticating = false;
  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid && !_isLogin && _selectedImage == null) {
      return;
    }
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please pick an image'),
      ));
      return;
    }
    _formKey.currentState!.save();
    print(_enteredEmail);
    print(_enteredPassword);

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(userCredentials.user!.uid + '.jpg');
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': "tobeadded",
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      var message = 'An error occured, please check your credentials!';

      if (error.message != null) {
        message = error.message!;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
      ));
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin:
                      EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
                  width: 200,
                  child: Image.asset('assets/images/chat.png'),
                ),
                Card(
                    margin: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!_isLogin)
                                    UserImagePickerState(
                                      onPickImage: (File pickedImage) {
                                        _selectedImage = pickedImage;
                                      },
                                    ),
                                  TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                        labelText: 'Email address'),
                                    autocorrect: false,
                                    textCapitalization: TextCapitalization.none,
                                    validator: (value) => value!
                                                .contains('@') &&
                                            value.contains('.com')
                                        ? null
                                        : 'Please enter a valid email address',
                                    onSaved: (value) {
                                      _enteredEmail = value!;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    obscureText: true,
                                    validator: (value) => value!.length < 6
                                        ? 'Password must be at least 6 characters long'
                                        : null,
                                    onSaved: (value) {
                                      _enteredPassword = value!;
                                    },
                                    decoration: const InputDecoration(
                                        labelText: 'Password'),
                                  ),
                                  const SizedBox(height: 12),
                                  if (_isAuthenticating)
                                    const CircularProgressIndicator(),
                                  if (!_isAuthenticating)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                      ),
                                      onPressed: _submit,
                                      child:
                                          Text(_isLogin ? 'Login' : 'Signup'),
                                    ),
                                  if (!_isAuthenticating)
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isLogin = !_isLogin;
                                        });
                                      },
                                      child: Text(_isLogin
                                          ? 'Create new account'
                                          : 'I already have an account	'),
                                    ),
                                ],
                              ),
                            )))),
              ],
            ),
          ),
        ));
  }
}
