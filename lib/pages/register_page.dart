//Packages
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

//Services
import '../services/media_service.dart';
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/navigation_service.dart';

//Widgets
import '../widgets/custome_input_fields.dart';
import '../widgets/rounded_button.dart';

//Providers
import '../providers/authentication_provider.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegusterPageState();
  }
}

class _RegusterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold();
  }
}