import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_live_chat_app/common_widgets/platform_alert_dialog.dart';
import 'package:flutter_live_chat_app/common_widgets/sign_in_text_form_field.dart';
import 'package:flutter_live_chat_app/common_widgets/social_log_in_button.dart';
import 'package:flutter_live_chat_app/view_models/user_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController _controllerUserName;
  File _profilePhoto;

  @override
  void initState() {
    super.initState();
    _controllerUserName = TextEditingController();
  }

  @override
  void dispose() {
    _controllerUserName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserViewModel _userViewModel =
        Provider.of<UserViewModel>(context, listen: false);
    _controllerUserName.text = _userViewModel.userModel.userName;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profil"),
        actions: [
          FlatButton(
            child: Text(
              "Çıkış yap",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => _buildSignOutAlertDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 75,
                      backgroundImage: _profilePhoto == null
                          ? NetworkImage(
                              _userViewModel.userModel.profilePhotoUrl)
                          : FileImage(_profilePhoto),
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        useRootNavigator: true,
                        context: context,
                        builder: (context) {
                          return Container(
                            height:
                                (MediaQuery.of(context).size.height / 5) + 8,
                            child: Column(children: [
                              ListTile(
                                leading: CircleAvatar(
                                  child: Icon(Icons.camera),
                                ),
                                title: Text("Kamera"),
                                subtitle: Text(
                                    "Kamera ile yeni profil fotoğrafı edinin."),
                                onTap: () {
                                  _newProfilePhotoFromCamera();
                                  // After closing bottom sheet
                                  Navigator.of(context).pop();
                                },
                              ),
                              ListTile(
                                leading: CircleAvatar(
                                  child: Icon(Icons.photo),
                                ),
                                title: Text("Galeri"),
                                subtitle: Text(
                                    "Galeriden yeni bir profil fotoğrafı seçin."),
                                onTap: () {
                                  _newProfilePhotoFromGallery();
                                  // After closing bottom sheet
                                  Navigator.of(context).pop();
                                },
                              ),
                            ]),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    "E-Posta",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                SignInTextFormField(
                  prefixIcon: Icon(Icons.mail),
                  initialValue: _userViewModel.userModel.mail,
                  readOnly: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    "Kullanıcı Adı",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                SignInTextFormField(
                  controller: _controllerUserName,
                  prefixIcon: Icon(Icons.person),
                ),
                SocialLogInButton(
                  buttonText: "Değişiklikleri kaydet",
                  buttonBgColor: Theme.of(context).primaryColor,
                  onPressed: () => _savedUserName(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _signOut(BuildContext context) async {
    final _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    bool result = await _userViewModel.signOut();
    return result;
  }

  Future _buildSignOutAlertDialog(BuildContext context) async {
    final result = await PlatformAlertDialog(
      title: "Emin misiniz?",
      message: "Çıkmak istediğinizden emin misiniz?",
      mainActionText: "Çıkış yap",
      secondActionText: "Vazgeç",
    ).show(context);

    if (result) {
      _signOut(context);
    }
  }

  void _savedUserName(BuildContext context) async {
    final _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    if (_userViewModel.userModel.userName != _controllerUserName.text) {
      var result = await _userViewModel.updateUserName(
          _userViewModel.userModel.userID, _controllerUserName.text);

      if (result == true) {
        _userViewModel.userModel.userName = _controllerUserName.text;
        PlatformAlertDialog(
          title: "Başarılı!",
          message: "Kullanıcı adı değiştirildi.",
          mainActionText: "Tamam",
        ).show(context);
      } else {
        _userViewModel.userModel.userName = _controllerUserName.text;
        PlatformAlertDialog(
          title: "Hata!",
          message:
              "Kullanıcı adı kullanılıyor. Farklı bir kullanıcı adı deneyin.",
          mainActionText: "Tamam",
        ).show(context);
      }
    } else {
      PlatformAlertDialog(
        title: "Hata!",
        message: "Kullanıcı adınız üzerinde herhangi bir değişiklik yapılmadı.",
        mainActionText: "Tamam",
      ).show(context);
    }
  }

  void _newProfilePhotoFromCamera() async {
    final image = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      _profilePhoto = File(image.path);
    });
  }

  void _newProfilePhotoFromGallery() async {
    final image = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _profilePhoto = File(image.path);
    });
  }
}
