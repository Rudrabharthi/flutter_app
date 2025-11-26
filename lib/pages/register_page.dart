//Packages
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

//Services
import '../services/media_service.dart';
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/navigation_service.dart';

//Widgets
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';
import '../widgets/rounded_image.dart';

//Providers
import '../providers/authentication_provider.dart';

import 'dart:io';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegusterPageState();
  }
}

class _RegusterPageState extends State<RegisterPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late DatabaseService _db;
  late CloudStorageService _cloudStorage;
  late NavigationService _navigation;

  String? _email;
  String? _password;
  String? _name;

  PlatformFile? _profileImage;

  final _registerFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _db = GetIt.instance.get<DatabaseService>();
    _cloudStorage = GetIt.instance.get<CloudStorageService>();
    _navigation = GetIt.instance.get<NavigationService>();
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: _deviceWidth * 0.06,
              vertical: _deviceHeight * 0.02,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _profileImageField(),
                SizedBox(height: _deviceHeight * 0.04),
                _registerForm(),
                SizedBox(height: _deviceHeight * 0.04),
                _registerButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileImageField() {
    final double imageSize = _deviceHeight * 0.15;

    return SizedBox(
      height: imageSize,
      width: imageSize,
      child: GestureDetector(
        onTap: () async {
          final file = await GetIt.instance
              .get<MediaService>()
              .pickImageFromLibrary();
          if (file != null) {
            setState(() {
              _profileImage = file;
            });
          }
        },
        child: _profileImage != null
            ? RoundedImageFile(
                key: const ValueKey("local_profile_image"),
                image: _profileImage!,
                size: imageSize,
              )
            : RoundedImageNetwork(
                key: const ValueKey("network_profile_image"),
                imagePath: "https://i.pravatar.cc/150?img=65",
                size: imageSize,
              ),
      ),
    );
  }

  Widget _registerForm() {
    return Container(
      height: _deviceHeight * 0.35,
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomeTextFormField(
              onSaved: (_value) {
                setState(() {
                  _name = _value;
                });
              },
              regEx: r'.{8,}',
              hintText: "Name",
              obscureText: false,
            ),
            CustomeTextFormField(
              onSaved: (_value) {
                setState(() {
                  _email = _value;
                });
              },
              regEx:
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
              hintText: "Email",
              obscureText: false,
            ),
            CustomeTextFormField(
              onSaved: (_value) {
                setState(() {
                  _password = _value;
                });
              },
              regEx: r".{8,}",
              hintText: "Password",
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerButton() {
    return RoundedButton(
      name: "Register",
      height: _deviceHeight * 0.065,
      width: _deviceWidth * 0.65,
      onPressed: () async {
        if (_registerFormKey.currentState!.validate() &&
            _profileImage != null) {
          _registerFormKey.currentState!.save();
          
          try {
            debugPrint('🔐 Starting registration...');
            
            // Register user with Firebase Auth
            String? _uid = await _auth.registerUserUsingEmailAndPassword(
              _email!,
              _password!,
            );
            
            if (_uid == null) {
              debugPrint('❌ Registration failed - no UID returned');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Registration failed. Please try again.')),
              );
              return;
            }
            
            debugPrint('✅ User registered with UID: $_uid');
            
            // Upload profile image
            debugPrint('📤 Uploading profile image...');
            String? _imageURL = await _cloudStorage.saveUserImageToStorage(
              _uid,
              _profileImage!,
            );
            
            if (_imageURL == null) {
              debugPrint('⚠️ Image upload failed, using empty string');
              _imageURL = ''; // Use empty string if upload fails
            } else {
              debugPrint('✅ Image uploaded: $_imageURL');
            }
            
            // Create user document in Firestore
            debugPrint('💾 Creating user document...');
            await _db.createUser(_uid, _email!, _name!, _imageURL);
            debugPrint('✅ User document created');
            
            // Logout and login to trigger auth state change
            debugPrint('🔄 Logging out and back in...');
            await _auth.logout();
            await _auth.loginUsingEmailAndPassword(_email!, _password!);
            debugPrint('✅ Registration complete!');
            
          } catch (e) {
            debugPrint('❌ Registration error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please fill all fields and select a profile image')),
          );
        }
      },
    );
  }
}
