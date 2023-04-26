import 'package:flutter/material.dart';
import 'package:img_syncer/storageform/smbform.dart';
import 'package:img_syncer/storageform/webdavform.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingStorageRoute extends StatefulWidget {
  const SettingStorageRoute({Key? key}) : super(key: key);

  @override
  SettingStorageRouteState createState() => SettingStorageRouteState();
}

enum Drive { smb, webDav }

Map<Drive, String> driveName = {
  Drive.smb: 'SMB',
  Drive.webDav: 'WebDAV',
};

Drive getDrive(String drive) {
  return driveName.entries.firstWhere((element) => element.value == drive).key;
}

class SettingStorageRouteState extends State<SettingStorageRoute> {
  final GlobalKey _formKey = GlobalKey<FormState>();

  @protected
  Drive currentDrive = Drive.smb;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      final drive = prefs.getString("drive");
      if (drive != null) {
        currentDrive = getDrive(drive);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    late Widget form;
    switch (currentDrive) {
      case Drive.smb:
        form = const SMBForm();
        break;
      case Drive.webDav:
        form = const WebDavForm();
        break;
      default:
        form = const Text('Not implemented');
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          iconTheme: Theme.of(context).iconTheme,
          elevation: 0,
          title: Text('Storage setting',
              style: Theme.of(context).textTheme.titleLarge),
        ),
        body: Center(
            child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: TextField(
                readOnly: true,
                controller:
                    TextEditingController(text: driveName[currentDrive]),
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Remote storage type',
                    suffixIcon: PopupMenuButton<String>(
                      icon: Icon(Icons.arrow_drop_down),
                      itemBuilder: (BuildContext context) {
                        return driveName.values
                            .map((String value) => PopupMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList();
                      },
                      onSelected: (String value) => setState(() {
                        currentDrive = getDrive(value);
                        SharedPreferences.getInstance().then((prefs) {
                          prefs.setString("drive", value);
                        });
                      }),
                    )),
              ),
            ),
            form,
          ],
        )));
  }
}