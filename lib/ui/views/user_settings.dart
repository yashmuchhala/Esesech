import 'package:esesech/core/models/server_user.dart';
import 'package:esesech/core/services/ssh.dart';
import 'package:flutter/material.dart';
import 'package:ssh/ssh.dart';

class UserSettings extends StatefulWidget {
  final ServerUser serverUser;
  UserSettings({this.serverUser});
  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  String userStatus;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "User—" + widget.serverUser.username,
          style: TextStyle(fontFamily: "Ubuntu Mono", color: Colors.black54),
        ),
        leading: GestureDetector(
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4), BlendMode.dstATop),
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Name: ${widget.serverUser.name}",
              style: TextStyle(fontSize: 24),
            ),
            Text(
              "Username: ${widget.serverUser.username}",
              style: TextStyle(fontSize: 24),
            ),
            Text(
              "User ID: ${widget.serverUser.uid}",
              style: TextStyle(fontSize: 24),
            ),
            Text(
              "Group ID: ${widget.serverUser.gid}",
              style: TextStyle(fontSize: 24),
            ),
            Text(
              "Home Directory: ${widget.serverUser.homeDirectory}",
              style: TextStyle(fontSize: 22),
            ),
            FutureBuilder<String>(
                future: getServerUserInfo(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    userStatus = snapshot.data;

                    if (snapshot.data == "P") {
                      return Text(
                        "Status: Enabled user",
                        style: TextStyle(fontSize: 24),
                      );
                    } else {
                      return Text("Status: User disabled/locked");
                    }
                  } else {
                    return Text("");
                  }
                }),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(10.0),
                childAspectRatio: 3.0,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(5.0),
                    child: RaisedButton(
                      child: Text("Disable User"),
                      onPressed: () => lockServerUser(),
                      color: Colors.yellow,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5.0),
                    child: RaisedButton(
                      child: Text("Unlock User"),
                      onPressed: () => unlockServerUser(),
                      color: Colors.green,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5.0),
                    child: RaisedButton(
                      child: Text("Revoke Password", style: TextStyle(fontSize: 12),),
                      onPressed: () => expireServerUserPassword(),
                      color: Colors.blue,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5.0),
                    child: RaisedButton(
                      child: Text("Delete User"),
                      onPressed: () => deleteServerUser(),
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> getServerUserInfo() async {
    try {
      const String USER_STATUS = 'sudo passwd -S';
      String result = await SSHService.execute(
          USER_STATUS + " " + widget.serverUser.username);
      String _userStatus = result.split(" ").elementAt(1);
      print(result);
      print(_userStatus);
      return _userStatus;
    } catch (e) {
      print("Error: $e");
      return "";
    }
  }

  Future<void> deleteServerUser() async {
    try {
      const String REMOVE_USER = 'sudo userdel';
      String _ = await SSHService.execute(
          REMOVE_USER + " " + widget.serverUser.username);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> expireServerUserPassword() async {
    try {
      const String EXPIRE_USER_PASSWORD = 'sudo passwd -e';
      String _ = await SSHService.execute(
          EXPIRE_USER_PASSWORD + " " + widget.serverUser.username);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> lockServerUser() async {
    try {
      const String LOCK_USER = 'sudo passwd -l';
      String _ = await SSHService.execute(
          LOCK_USER + " " + widget.serverUser.username);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> unlockServerUser() async {
    try {
      const String UNLOCK_USER = 'sudo passwd -u';
      String _ = await SSHService.execute(
          UNLOCK_USER + " " + widget.serverUser.username);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> changeServerUserName(String newName) async {
    try {
      const String CHANGE_USER_NAME = 'sudo usermod -c';
      String _ = await SSHService.execute(CHANGE_USER_NAME +
          " " +
          "'$newName'" +
          " " +
          widget.serverUser.username);
    } catch (e) {
      print("Error: $e");
    }
  }
}
