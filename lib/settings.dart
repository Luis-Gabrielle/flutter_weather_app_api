import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsProvider with ChangeNotifier {
  String _location = "San Fernando";
  Color _iconColor = CupertinoColors.systemRed;
  bool _metricSystem = true;
  bool _lightMode = false;

  String get location => _location;
  Color get iconColor => _iconColor;
  bool get metricSystem => _metricSystem;
  bool get lightMode => _lightMode;

  void changeLocation(String newLocation) {
    _location = newLocation;
    notifyListeners();
  }

  void changeIconColor(Color newColor) {
    _iconColor = newColor;
    notifyListeners();
  }

  void toggleMetricSystem(bool value) {
    _metricSystem = value;
    notifyListeners();
  }

  void toggleLightMode(bool value) {
    _lightMode = value;
    notifyListeners();
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final textColor = settings.lightMode ? CupertinoColors.black : CupertinoColors.white;
    final secondaryTextColor = settings.lightMode ? CupertinoColors.darkBackgroundGray : CupertinoColors.systemGrey;
    final backgroundColor = settings.lightMode ? CupertinoColors.extraLightBackgroundGray : CupertinoColors.darkBackgroundGray;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Settings", style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
      ),

      child: Container(
         // Set background color for ListView
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: settings.lightMode ? CupertinoColors.extraLightBackgroundGray : CupertinoColors.darkBackgroundGray,// Set background color for Container
          borderRadius: BorderRadius.circular(15), // Set border radius for Container
        ),
        child: ListView(
          children: [
            Column(
              children: [
                _buildSettingsTile(
                  icon: Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.orange, // Background color for Location icon
                      borderRadius: BorderRadius.circular(5), // Border radius
                    ),
                    child: Icon(CupertinoIcons.location_fill, color: Colors.white),
                  ),
                  title: "Location",
                  trailing: Text(settings.location,
                      style: TextStyle(color: secondaryTextColor)),
                  onTap: () => _showLocationDialog(context, settings),
                ),
                Container(
                  height: 1,
                  color: CupertinoColors.tertiaryLabel,
                ),
              ],
            ),
            Column(
              children: [
                _buildSettingsTile(
                  icon: Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red, // Background color for Icon Color icon
                      borderRadius: BorderRadius.circular(5), // Border radius
                    ),
                    child: Icon(CupertinoIcons.color_filter, color: Colors.white),
                  ),
                  title: "Icon Color",
                  trailing: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: settings.iconColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onTap: () => _showColorPicker(context, settings),
                ),
                Container(
                  height: 1,
                  color: CupertinoColors.tertiaryLabel,
                ),
              ],
            ),
            Column(
              children: [
                _buildToggleTile(
                  icon: Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.green, // Background color for Metric System icon
                      borderRadius: BorderRadius.circular(5), // Border radius
                    ),
                    child: Icon(CupertinoIcons.gauge, color: Colors.white),
                  ),
                  title: "Metric System",
                  value: settings.metricSystem,
                  onChanged: (value) => settings.toggleMetricSystem(value),
                ),
                Container(
                  height: 1,
                  color: CupertinoColors.tertiaryLabel,
                ),
              ],
            ),
            Column(
              children: [
                _buildToggleTile(
                  icon: Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.yellow, // Background color for Light Mode icon
                      borderRadius: BorderRadius.circular(5), // Border radius
                    ),
                    child: Icon(CupertinoIcons.light_max, color: Colors.white),
                  ),
                  title: "Light Mode",
                  value: settings.lightMode,
                  onChanged: (value) => settings.toggleLightMode(value),
                ),
                Container(
                  height: 1,
                  color: CupertinoColors.tertiaryLabel,
                ),
              ],
            ),
            Column(
              children: [
                _buildSettingsTile(
                  icon: Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.blue, // Background color for About icon
                      borderRadius: BorderRadius.circular(5), // Border radius
                    ),
                    child: Icon(CupertinoIcons.info_circle, color: Colors.white),
                  ),
                  title: "About",
                  trailing: Text("Version: 1.0",
                      style: TextStyle(color: secondaryTextColor)),
                  onTap: () => _showAboutDialog(context, settings),
                ),
                Container(
                  height: 1,
                  color: CupertinoColors.tertiaryLabel,
                ),
              ],
            ),
          ],
        ),
      ),


    );
  }

  Widget _buildSettingsTile({
    required Widget icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    final settings = Provider.of<SettingsProvider>(context);
    final textColor = settings.lightMode ? CupertinoColors.black : CupertinoColors.white;

    return CupertinoListTile(
      leading: icon, // Pass the icon directly here
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildToggleTile({
    required Widget icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final settings = Provider.of<SettingsProvider>(context);
    final textColor = settings.lightMode ? CupertinoColors.black : CupertinoColors.white;

    return CupertinoListTile(
      leading: icon,
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
      ),

    );
  }

  void _showLocationDialog(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(text: settings.location);
    final textColor = settings.lightMode ? CupertinoColors.black : CupertinoColors.white;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Change Location", style: TextStyle(color: textColor)),
        content: CupertinoTextField(
          controller: controller,
          placeholder: "Enter city name",
        ),
        actions: [
          CupertinoDialogAction(
            child: Text("Cancel", style: TextStyle(color: textColor)),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: Text("Change", style: TextStyle(color: textColor)),
            onPressed: () {
              settings.changeLocation(controller.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, SettingsProvider settings) {
    final textColor = settings.lightMode ? CupertinoColors.black : CupertinoColors.white;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text("Select Icon Color", style: TextStyle(color: textColor)),
        actions: [
          CupertinoActionSheetAction(
            child: Text("Red", style: TextStyle(color: textColor)),
            onPressed: () {
              settings.changeIconColor(CupertinoColors.systemRed);
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text("Blue", style: TextStyle(color: textColor)),
            onPressed: () {
              settings.changeIconColor(CupertinoColors.systemBlue);
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text("Green", style: TextStyle(color: textColor)),
            onPressed: () {
              settings.changeIconColor(CupertinoColors.systemGreen);
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text("Yellow", style: TextStyle(color: textColor)),
            onPressed: () {
              settings.changeIconColor(CupertinoColors.systemYellow);
              Navigator.pop(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text("Cancel", style: TextStyle(color: textColor)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, SettingsProvider settings) {
    final textColor = settings.lightMode ? CupertinoColors.black : CupertinoColors.white;
    final secondaryTextColor = settings.lightMode ? CupertinoColors.darkBackgroundGray : CupertinoColors.systemGrey;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("About iWeather", style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text("Version: 1.0", style: TextStyle(
              color: textColor,
              fontSize: 16,
            )),
            const SizedBox(height: 15),
            Text("Developed by:", style: TextStyle(
              color: secondaryTextColor,
              fontSize: 14,
            )),
            const SizedBox(height: 5),
            Text("Adrian Mhaki Macabali", style: TextStyle(
              color: textColor,
              fontSize: 16,
            )),
            Text("Luis Gabrielle Estacio", style: TextStyle(
              color: textColor,
              fontSize: 16,
            )),
            Text("Megan Esguerra", style: TextStyle(
              color: textColor,
              fontSize: 16,
            )),
            Text("Kristel Culala", style: TextStyle(
              color: textColor,
              fontSize: 16,
            )),
            Text("John Ivan Baligod", style: TextStyle(
              color: textColor,
              fontSize: 16,
            )),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: Text("OK", style: TextStyle(color: settings.iconColor)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}