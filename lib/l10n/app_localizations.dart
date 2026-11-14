class AppStrings {
  final String languageCode;

  AppStrings(this.languageCode);

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'LoveRing',
      'settings': 'Settings',
      'sound': 'Ring Sound',
      'sound_desc': 'Play loud ring sound on receiving pings',
      'volume': 'Volume Level',
      'vibration': 'Vibration',
      'vibration_desc': 'Vibrate device when partner sends a ping',
      'quiet_hours': 'Quiet Hours',
      'quiet_hours_desc': 'Mute pings during selected hours',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'english': 'English',
      'arabic': 'العربية (Arabic)',
      'send_ping': 'Send Love Ping 💗',
      'sending': 'Sending Ping...',
      'connected': 'Connected 💕',
      'unpair': 'Unpair',
      'create_link': 'Create Link',
      'enter_link': 'Enter Link',
      'dismiss': 'Dismiss',
      'send_one_back': 'Send one back 💗',
      'ping_sent': 'Ping sent to partner! 💖',
    },
    'ar': {
      'app_name': 'لوف رينج',
      'settings': 'الإعدادات',
      'sound': 'صوت الرنين',
      'sound_desc': 'تشغيل صوت نغمة مرتفع عند تلقي إشارة حب',
      'volume': 'مستوى الصوت',
      'vibration': 'الاهتزاز',
      'vibration_desc': 'اهتزاز الهاتف عند إرسال الشريك لإشارة',
      'quiet_hours': 'ساعات الهدوء',
      'quiet_hours_desc': 'كتم الإشارات خلال الساعات المحددة',
      'dark_mode': 'الوضع الداكن',
      'language': 'اللغة',
      'english': 'English',
      'arabic': 'العربية',
      'send_ping': 'إرسال إشارة حب 💗',
      'sending': 'جاري الإرسال...',
      'connected': 'متصل 💕',
      'unpair': 'إلغاء الاقتران',
      'create_link': 'إنشاء رابط',
      'enter_link': 'إدخال رابط',
      'dismiss': 'إغلاق',
      'send_one_back': 'رد بإشارة 💗',
      'ping_sent': 'تم إرسال الإشارة لشريكك! 💖',
    },
  };

  String get(String key) {
    return _localizedValues[languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}
