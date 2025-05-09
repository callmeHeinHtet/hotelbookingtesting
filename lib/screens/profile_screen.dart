import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = "Guest";

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString("username") ?? "Guest";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          // TOP BLACK HEADER
          Container(
            color: Colors.black,
            padding: EdgeInsets.fromLTRB(10, 50, 20, 20),
            child: Row(
              children: [
                // Back Button
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 10),

                // Avatar + Info
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30, color: Colors.black),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _username,
                      style: TextStyle(
                          color: Color(0xFFB2D732),
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    Text("Gold Member", style: TextStyle(color: Colors.white70)),
                  ],
                ),
                Spacer(),

                // Edit Profile Link
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditProfileScreen()),
                    );
                    _loadUsername();
                  },
                  child: Text(
                    "Edit Profile",
                    style: TextStyle(
                      color: Color(0xFFB2D732),
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // SETTINGS + CONTACT
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                _sectionTitle("Setting"),
                _settingItem(Icons.language, "Language"),
                _settingItem(Icons.lock_outline, "Change Password"),
                _settingSwitchItem("Allow Notification", true),
                _settingItem(Icons.credit_card, "Credit/ Debit Card"),
                _settingItem(Icons.location_on_outlined, "My Addresses"),
                _settingItem(Icons.delete_forever, "Delete My Account"),
                SizedBox(height: 20),

                _sectionTitle("Customer Support"),
                _settingItem(Icons.description_outlined, "Terms and Conditions"),
                SizedBox(height: 20),

                _sectionTitle("Contact Us"),
                ListTile(
                  leading: Icon(Icons.email_outlined),
                  title: Text("Email"),
                  trailing: Text("cimso@gmail.com", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  leading: Icon(Icons.call),
                  title: Text("Call Center"),
                  trailing: Text("02 123 4567", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 20),

                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: handle logout
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFB2D732),
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text("Log Out", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ✅ Using your BottomNavBar widget
      bottomNavigationBar: BottomNavBar(selectedIndex: 3),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _settingItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  Widget _settingSwitchItem(String label, bool value) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      activeColor: Color(0xFFB2D732),
      onChanged: (val) {
        // Optionally handle toggle
      },
    );
  }
}
