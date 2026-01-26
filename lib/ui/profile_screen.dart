import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSyncEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile"), elevation: 4,),
      body: Column(
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
          Divider(),

          SwitchListTile(
            title: Text("Cloud Synchronization"),
            subtitle: Text(_isSyncEnabled ? "Online Mode (Firebase)" : "Offline Mode (Local Only)"),
            secondary: Icon(_isSyncEnabled ? Icons.cloud_done : Icons.cloud_off),
            value: _isSyncEnabled,
            onChanged: (bool value) {
              setState(() {
                _isSyncEnabled = value;
              });
              // Trigger Cloud Synchronize here
            },
          ),

          Divider(),

          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("Version"),
            trailing: Text("1.0.0"),
          ),
        ],
      ),
    );
  }
}