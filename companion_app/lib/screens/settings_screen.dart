import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// Màn hình cài đặt tùy chọn của ứng dụng
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _vibrationEnabled = true;
  bool _keepScreenOn = true;
  double _alertDistance = AppConfig.maneuverAlertDistanceMeters;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'DẪN ĐƯỜNG & ĐỒNG HỒ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Rung cảnh báo trên đồng hồ'),
            subtitle: const Text('Rung khi cách điểm rẽ một khoảng cách nhất định'),
            value: _vibrationEnabled,
            onChanged: (val) {
              setState(() => _vibrationEnabled = val);
            },
          ),
          ListTile(
            title: const Text('Khoảng cách cảnh báo trước khi rẽ'),
            subtitle: Text('${_alertDistance.round()} mét trước điểm rẽ'),
            trailing: SizedBox(
              width: 150,
              child: Slider(
                min: 30,
                max: 150,
                divisions: 12,
                value: _alertDistance,
                label: '${_alertDistance.round()}m',
                onChanged: (val) {
                  setState(() => _alertDistance = val);
                },
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Giữ màn hình điện thoại luôn sáng'),
            subtitle: const Text('Không khóa màn hình khi đang trong lộ trình'),
            value: _keepScreenOn,
            onChanged: (val) {
              setState(() => _keepScreenOn = val);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'BẢN ĐỒ & ĐỊA ĐIỂM',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.map),
            title: Text('Dịch vụ bản đồ'),
            subtitle: Text('OpenStreetMap & OSRM Engine (Miễn phí)'),
          ),
          const ListTile(
            leading: Icon(Icons.search),
            title: Text('Dịch vụ tìm kiếm'),
            subtitle: Text('Nominatim OpenStreetMap Geocoding'),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'THÔNG TIN ỨNG DỤNG',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Phiên bản'),
            subtitle: Text('1.0.0 (Build 1)'),
          ),
          const ListTile(
            leading: Icon(Icons.watch),
            title: Text('Thiết bị tương thích'),
            subtitle: Text('Huawei Watch GT 3 SE (HarmonyOS Lite JS)'),
          ),
        ],
      ),
    );
  }
}
