import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/settings_store.dart';
import '../widgets/quick_assistant_fab.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _chooseSound(String channelId) async {
    await NotificationService.openChannelSettings(channelId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر النغمة من إعدادات قناة أندرويد ثم عد إلى التطبيق.')),
      );
    }
  }

  Widget _soundTile({required IconData icon, required String title, required String subtitle, required String channelId}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E7D32)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_left),
      onTap: () => _chooseSound(channelId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      floatingActionButton: const QuickAssistantFab(),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('المظهر', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('الوضع الليلي'),
            subtitle: const Text('تفعيل المظهر الداكن للتطبيق'),
            value: SettingsStore.isDark,
            onChanged: (value) async {
              await SettingsStore.setDarkMode(value);
              if (mounted) setState(() {});
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('نغمات الإشعارات', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('اضغط على النوع المطلوب واختر أي نغمة من نغمات هاتفك. قد لا يسمح أندرويد بتغيير النغمة إلا بعد إنشاء القناة أول مرة.'),
          ),
          _soundTile(icon: Icons.play_arrow, title: 'بداية المهمة', subtitle: 'نغمة بدء كل مهمة', channelId: kStartChannelId),
          _soundTile(icon: Icons.flag_outlined, title: 'نهاية المهمة', subtitle: 'نغمة انتهاء الوقت', channelId: kEndChannelId),
          _soundTile(icon: Icons.snooze_outlined, title: 'المهمة المؤجلة', subtitle: 'نغمة الموعد بعد التأجيل', channelId: kSnoozeChannelId),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('ميزات قوة الآن', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const ListTile(leading: Icon(Icons.mic_none), title: Text('إملاء صوتي مستمر'), subtitle: Text('يستمر الاستماع حتى تضغط زر المربع، ثم يمكنك مراجعة النص قبل الإرسال.')),
          const ListTile(leading: Icon(Icons.insights_outlined), title: Text('تخطيط واضح'), subtitle: Text('المهام المتكررة، المهام الفرعية، والتأجيل من الإشعار مباشرة.')),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.bolt),
            title: Text('قوة الآن'),
            subtitle: Text('الإصدار V12 — تحسين الصوت والإشعارات'),
          ),
          const ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('المطوّر'),
            subtitle: Text('شرف علي شرف القارة'),
          ),
        ],
      ),
    );
  }
}
