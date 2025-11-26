//Packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

//Providers
import '../providers/authentication_provider.dart';
import '../providers/users_page_provider.dart';

//widgets
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';
import '../widgets/rounded_button.dart';
import '../widgets/custom_input_fields.dart';

//Models
import '../models/chat_user.dart';

class UserPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserPageState();
  }
}

class _UserPageState extends State<UserPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;

  final TextEditingController _searchFieldEditingController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    return _buildUI();
  }

  Widget _buildUI() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _deviceWidth * 0.03,
        vertical: _deviceHeight * 0.02,
      ),
      height: _deviceHeight * 0.98,
      width: _deviceWidth * 0.97,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TopBar(
            "Users",
            primaryAction: IconButton(
              icon: Icon(Icons.logout, color: Color.fromRGBO(0, 82, 218, 1.0)),
              onPressed: () {},
            ),
          ),
          CustomTextField(
            onEditingComplete: (_value) {},
            hintText: 'Search...',
            obscureText: false,
            controller: _searchFieldEditingController,
            //Icon: Icons.search,
          ),
          _usersList(),
        ],
      ),
    );
  }

  Widget _usersList() {
    return Expanded(
      child: () {
        return ListView.builder(
          itemCount: 10,
          itemBuilder: (BuildContext _context, int _index) {
            return CustomListViewTile(
              height: _deviceHeight * 0.10,
              title: "User $_index",
              subtitle: "Last Active",
              imagePath: "https://i.pravatar.cc/300",
              isActive: true,
              isSelected: false,
              onTap: () {},
            );
          },
        );
      }(),
    );
  }
}
