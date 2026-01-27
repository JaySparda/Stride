import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stride/data/repo/todo_repo_firebase.dart';
import 'package:stride/data/repo/todo_repo_sqlite.dart';

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
  
  @override
  void initState() {
    super.initState();
    _loadSyncSetting();
  }

  void _loadSyncSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSyncEnabled = prefs.getBool('cloud_sync') ?? false;
    });
  }

  void _toggleSync(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cloud_sync', value);
    setState(() {
      _isSyncEnabled = value;
    });
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
      final localTasks = await repo.getAllTodo();
      for(var task in localTasks) {
        await cloudRepo.syncTodo(task);
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
          SnackBar(content: Text("Sync failed: $e"), backgroundColor: Colors.red,)
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

            Text("Stride User", style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
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