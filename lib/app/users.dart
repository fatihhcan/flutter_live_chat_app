import 'package:flutter/material.dart';
import 'package:flutter_live_chat_app/app/chat_page.dart';
import 'package:flutter_live_chat_app/view_models/all_users_view_model.dart';
import 'package:flutter_live_chat_app/view_models/chat_view_model.dart';
import 'package:flutter_live_chat_app/view_models/user_view_model.dart';
import 'package:provider/provider.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  bool _isLoading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_listControlListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0x91adc7),
      appBar: AppBar(
        title: Text(
          "Kullanıcılar",
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFFF2F6FA),
          ),
        ),
      ),
      body: Consumer<AllUsersViewModel>(
        builder: (context, model, child) {
          if (model.state == AllUsersViewState.Busy) {
            return _buildNewUsersCircularProgressIndicator();
          } else if (model.state == AllUsersViewState.Loaded) {
            return RefreshIndicator(
              onRefresh: model.listRefresh,
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                itemBuilder: (context, index) {
                  if (model.allUsers.length == 1) {
                    return buildUsersListIsEmpty();
                  } else if (model.hasMore == true &&
                      index == model.allUsers.length) {
                    return _buildNewUsersCircularProgressIndicator();
                  } else {
                    return buildListTile(index);
                  }
                },
                itemCount: model.hasMore == true
                    ? model.allUsers.length + 1
                    : model.allUsers.length,
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget buildUsersListIsEmpty() {
    final _allUsersViewModel = Provider.of<AllUsersViewModel>(context);
    return RefreshIndicator(
      onRefresh: _allUsersViewModel.listRefresh,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 92,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: ((MediaQuery.of(context).size.height) * 2 / 6),
                  child: Image.asset(
                    "assets/images/userNotFound.png",
                    fit: BoxFit.contain,
                  ),
                ),
                Text(
                  "Sistemde kayıtlı kullanıcı bulunamadı.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildListTile(int index) {
    final _allUsersViewModel = Provider.of<AllUsersViewModel>(context);
    final _userViewModel = Provider.of<UserViewModel>(context);
    var _currentUser = _allUsersViewModel.allUsers[index];

    // Tüm kullanıcı listesi içerisinde mevcut kullanıcıyı dışladım:
    if (_currentUser.userID == _userViewModel.userModel.userID) {
      return Container();
    }

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: FadeInImage.assetNetwork(
          placeholder: "assets/images/defaultUserPhoto.jpg",
          image: _currentUser.profilePhotoUrl,
          fit: BoxFit.cover,
          height: 48,
          width: 48,
          repeat: ImageRepeat.noRepeat,
        ),
      ),
      title: Text(
        "@" + _currentUser.userName,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        _currentUser.mail,
        style: TextStyle(fontSize: 13),
      ),
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider<ChatViewModel>(
              create: (context) => ChatViewModel(
                  currentUser: _userViewModel.userModel,
                  chatUser: _currentUser),
              child: ChatPage(),
            ),
          ),
        );
      },
    );
  }

  getMoreUsers() async {
    final _allUsersViewModel = Provider.of<AllUsersViewModel>(context);
    if (_isLoading == false) {
      _isLoading = true;
      await _allUsersViewModel.getMoreUsers();
      _isLoading = false;
    }
  }

  Widget _buildNewUsersCircularProgressIndicator() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(
            height: 10,
          ),
          Text("Kullanıcılar getiriliyor."),
        ],
      ),
    );
  }

  void _listControlListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      getMoreUsers();
    }
  }
}
