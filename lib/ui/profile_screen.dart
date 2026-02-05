import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stride/data/repo/todo_repo_firebase.dart';
import 'package:stride/data/repo/todo_repo_sqlite.dart';
import 'package:stride/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.total, required this.completed});

  final int total;
  final int completed;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSyncEnabled = false;
  final repo = TodoRepoSqlite();
  final cloudRepo = TodoRepoFirebase();
  bool _isDarkMode = false;
  String _uid = "Loading...";

@override
void initState() {
  super.initState();
  _loadSettingsAndUID();
}

void _loadSettingsAndUID() async {
  final prefs = await SharedPreferences.getInstance();
  
  final currentUID = await cloudRepo.getUserId();

  setState(() {
    _isSyncEnabled = prefs.getBool('cloud_sync') ?? false;
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    _uid = currentUID;
  });
}

void _showRestoreDialog() {
  final TextEditingController _uidController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Restore Account"),
      content: TextField(
        controller: _uidController,
        keyboardType: TextInputType.number,
        maxLength: 9,
        decoration: const InputDecoration(
          labelText: "Enter 9-digit UID",
          hintText: "Check your old app settings",
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
        ElevatedButton(
          onPressed: () async {
            if (_uidController.text.length == 9) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_unique_id', _uidController.text);

              cloudRepo.refreshUser(); 
              
              setState(() {
                _uid = _uidController.text;
              });

              Navigator.pop(context);

              _syncAllTasks(); 
            }
          },
          child: const Text("RESTORE"),
        ),
      ],
    ),
  );
}

  void _toggleSync(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cloud_sync', value);
    setState(() {
      _isSyncEnabled = value;
    });
  }

  void _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    setState(() {
      _isDarkMode = value;
    });

    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  void _syncAllTasks() async {
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator()
          ),
        ),
      )
    );

    try {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Syncing with Cloud..."), duration: Duration(seconds: 1)),
      );
      final localTasks = await repo.getAllTodo();
      for(var task in localTasks) {
        await cloudRepo.syncTodo(task).timeout(Duration(seconds: 3));
      }

      if(mounted) Navigator.of(context).pop(true);

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("All tasks successfully backed up to cloud"),
            backgroundColor: Colors.green,
          )
        );
      }
    } catch (e) {
      if(mounted) Navigator.of(context).pop(true);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cloud Sync Timed Out - Saved to Local Only."), backgroundColor: Colors.red,)
        );
      }
    }
  }

  Widget _buildStatisticsCard(int total, int completed) {
    double percentage = total == 0 ? 0 : (completed / total) * 100;

    return Card(
      margin: EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Your Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem("Total", total.toString(), Colors.blue),
                _statItem("Completed", completed.toString(), Colors.green),
                _statItem("Rate", "${percentage.toStringAsFixed(0)}%", Colors.orange)
              ],
            ),
            SizedBox(height: 20),
            LinearProgressIndicator(
              value: total == 0 ? 0 : completed / total,
              backgroundColor: Colors.grey[200],
              color: Colors.green,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            )
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile"), elevation: 4,),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30.0),
            Center(
              child: CircleAvatar(
                radius: 50.0,
                child: Icon(Icons.person, size: 50.0,),
              ),
            ),

            SizedBox(height: 16.0),

            Text(_uid, style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 32.0),


            _buildStatisticsCard(widget.total, widget.completed),

            Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Setting", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),

            SwitchListTile(
              title: Text("Cloud Synchronization"),
              subtitle: Text("Backup your tasks to the cloud"),
              secondary: Icon(Icons.cloud_upload),
              value: _isSyncEnabled,
              onChanged: _toggleSync,
            ),

            if (_isSyncEnabled)
              ListTile(
                leading: Icon(Icons.sync, color: Colors.blue,),
                title: Text("Force Cloud Backup"),
                subtitle: Text("Manually push all local data to Firebase"),
                trailing: const Icon(Icons.chevron_left),
                onTap: _syncAllTasks,
              ),

            Divider(),

            SwitchListTile(
              title: Text("Dark Mode"),
              subtitle: Text("Switch between light and dark themes"),
              secondary: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
              value: _isDarkMode, 
              onChanged: _toggleTheme
            ),

            Divider(),

            ListTile(
              leading:  Icon(Icons.fingerprint, color: Colors.purple),
              title:  Text("Account UID"),
              subtitle: Text(_uid),
              trailing: IconButton(
                icon:  Icon(Icons.copy, size: 20),
                onPressed: () { 

                  Clipboard.setData(ClipboardData(text: _uid));

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("UID Copied!")),
                  );
                },
              ),
            ),
            ListTile(
              leading:  Icon(Icons.history_edu, color: Colors.orange),
              title:  Text("Recover Account"),
              subtitle:  Text("Enter an old UID to restore data"),
              onTap: _showRestoreDialog,
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("Version"),
              trailing: Text("1.0.0"),
            ),
          ],
        ),
      )
    );
  }
}