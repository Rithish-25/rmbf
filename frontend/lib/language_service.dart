import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LanguageNotifier extends ChangeNotifier {
  String _lang = 'English';
  String get lang => _lang;
  set lang(String val) {
    if (_lang != val) {
      _lang = val;
      notifyListeners();
    }
  }
  
  void triggerRebuild() {
    notifyListeners();
  }
}

class LanguageService {
  static final LanguageNotifier currentLanguage = LanguageNotifier();
  
  // Cache of dynamically translated strings
  static final Map<String, String> _dynamicTamilCache = {};

  // Comprehensive pre-seeded offline dictionary for instant and offline translation of key UI strings
  static final Map<String, String> _tamilDictionary = {
    'RMBF Dashboard': 'RMBF டாஷ்போர்டு',
    'Quick Services': 'விரைவான சேவைகள்',
    'Calendar': 'நாட்காட்டி',
    'News & Events': 'செய்திகள் & நிகழ்வுகள்',
    'THANKS SCORE SUMMARY': 'நன்றி மதிப்பெண் சுருக்கம்',
    'TOTAL GIVEN': 'மொத்தம் வழங்கப்பட்டது',
    'TOTAL TAKEN': 'மொத்தம் பெறப்பட்டது',
    'THIS TERM': 'இந்த முறை',
    'R TO R': 'ஆர் டு ஆர்',
    'TOTAL COUNT': 'மொத்த எண்ணிக்கை',
    'POINTS': 'புள்ளிகள்',
    'TOTAL POINTS': 'மொத்த புள்ளிகள்',
    'CURRENT MONTH': 'நடப்பு மாதம்',
    'Know your point system': 'உங்கள் புள்ளி முறையை அறிந்துகொள்ளுங்கள்',
    'Updated in real-time': 'உடனுக்குடன் புதுப்பிக்கப்படும்',
    'Member Directory': 'உறுப்பினர் அடைவு',
    'Meetings': 'கூட்டங்கள்',
    'My Profile': 'எனது சுயவிவரம்',
    'Mobile Number': 'கைபேசி எண்',
    'Date of Birth': 'பிறந்த தேதி',
    'Wedding Day': 'திருமண நாள்',
    'Company Open Day': 'நிறுவனம் தொடங்கப்பட்ட நாள்',
    'Office Address': 'அலுவலக முகவரி',
    'Logout': 'வெளியேறு',
    'Home': 'முகப்பு',
    'Directory': 'அடைவு',
    'Thanks Note': 'நன்றி குறிப்பு',
    'Meeting': 'கூட்டம்',
    'Profile': 'சுயவிவரம்',
    'Apply Leave': 'விடுப்புக்கு விண்ணப்பி',
    'Attendance By-Law': 'வருகை விதிமுறை',
    'Thanks Note Activity': 'நன்றி குறிப்பு செயல்பாடு',
    'Meetings & Events': 'கூட்டங்கள் & நிகழ்வுகள்',
    'My Member Profile': 'எனது உறுப்பினர் சுயவிவரம்',
    'Thanksnote History': 'நன்றிக்குறிப்பு வரலாறு',
    'R to R History': 'ஆர் டு ஆர் வரலாறு',
    'R to R Form': 'ஆர் டு ஆர் படிவம்',
    'Referrals': 'பரிந்துரைகள்',
    'Point System': 'புள்ளி முறை',
    'Calendar Booking': 'நாட்காட்டி முன்பதிவு',
    'Exit App': 'செயலியை மூடு',
    'Are you sure you want to exit?': 'நிச்சயமாக வெளியேற வேண்டுமா?',
    'No': 'இல்லை',
    'Yes': 'ஆம்',
    
    // Meeting Screen specific
    'Regular Meeting': 'சாதாரண கூட்டம்',
    'Power Team Meeting': 'பவர் டீம் கூட்டம்',
    'Total Meetings': 'மொத்த கூட்டங்கள்',
    'Compulsary': 'கட்டாயம்',
    'Attended': 'வருகை புரிந்தது',
    'Scan QR Code to Check-In': 'வருகையை பதிவு செய்ய கியூஆர் குறியீட்டை ஸ்கேன் செய்யவும்',

    // Directory Screen specific
    'Personal': 'தனிப்பட்ட விவரங்கள்',
    'Business': 'வணிக விவரங்கள்',
    'Search by Name, Business, Phone...': 'பெயர், வணிகம், கைபேசி மூலம் தேடவும்...',
    'No members found': 'உறுப்பினர்கள் யாரும் இல்லை',
    'Try adjusting your search filters': 'வேறு வார்த்தைகளை பயன்படுத்தி தேடவும்',
    'Kootam': 'கூட்டம்',
    'Email': 'மின்னஞ்சல்',
    'Phone': 'கைபேசி எண்',
    'Blood Group': 'இரத்த பிரிவு',
    'Father Name': 'தந்தை பெயர்',
    'Spouse Name': 'துணைவர் பெயர்',
    'Education': 'கல்வி தகுதி',
    'Points Balance': 'புள்ளிகள் இருப்பு',
    'Business Name': 'வணிக பெயர்',
    'Industry': 'தொழில் துறை',
    'Location': 'இடம்',
    'Designation': 'பதவி',
    'Website': 'இணையதளம்',

    // Thanks Note Screen specific
    'Total Given': 'மொத்தம் வழங்கப்பட்டது',
    'Total Taken': 'மொத்தம் பெறப்பட்டது',
    'Add Thanksnote': 'நன்றிக்குறிப்பை சேர்க்க',
    'Referal': 'பரிந்துரை',
    'Thank You note': 'நன்றிக் குறிப்பு',
    'Referral Type': 'பரிந்துரை வகை',
    'Self': 'சுய',
    'Connect': 'இணைப்பு',
    'Member': 'உறுப்பினர்',
    'Direct': 'நேரடி',
    'Thank You Type': 'நன்றி வகை',
    'Connection Name / Details': 'இணைப்பு பெயர் / விவரங்கள்',
    'Select Member': 'உறுப்பினரைத் தேர்ந்தெடுக்கவும்',
    'Business Amount (₹)': 'வணிகத் தொகை (₹)',
    'Submit Referal': 'பரிந்துரையை சமர்ப்பிக்கவும்',
    'Submit Thanksnote': 'நன்றிக்குறிப்பை சமர்ப்பிக்கவும்',
    'View Thanksnote History': 'நன்றிக்குறிப்பு வரலாற்றைக் காண்க',
    
    // R to R Form & Point System Screen specific
    'Your Name': 'உங்கள் பெயர்',
    'Whom are you doing R to R with?': 'யாருடன் ஆர் டு ஆர் செய்கிறீர்கள்?',
    'Select member': 'உறுப்பினரைத் தேர்ந்தெடுக்கவும்',
    'Your R to R Date': 'உங்கள் ஆர் டு ஆர் தேதி',
    'Select date': 'தேதியைத் தேர்ந்தெடுக்கவும்',
    'Submit R to R': 'ஆர் டு ஆர் சமர்ப்பிக்கவும்',
    'View History': 'வரலாற்றைக் காண்க',
    'Points & Attendance Rules': 'புள்ளிகள் & வருகை விதிமுறைகள்',
    'Description': 'விளக்கம்',
    'Per count': 'ஒரு முறைக்கு',
  };

  static String translate(String key) {
    if (currentLanguage.lang == 'English') {
      return key;
    }
    
    // Check pre-seeded dictionary
    if (_tamilDictionary.containsKey(key)) {
      return _tamilDictionary[key]!;
    }
    
    // Check dynamic translation cache
    if (_dynamicTamilCache.containsKey(key)) {
      return _dynamicTamilCache[key]!;
    }
    
    // If not cached, trigger background Google Translate API call
    _fetchTranslationFromGoogle(key);
    
    return key; // Return English key initially while fetching
  }

  static Future<void> _fetchTranslationFromGoogle(String text) async {
    if (text.isEmpty || RegExp(r'^\s*$').hasMatch(text)) return;
    
    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=ta&dt=t&q=${Uri.encodeComponent(text)}'
      );
      
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded != null && decoded[0] != null && decoded[0][0] != null) {
          final translatedText = decoded[0][0][0] as String;
          _dynamicTamilCache[text] = translatedText;
          // Notify listeners to rebuild UI with newly fetched translation
          currentLanguage.triggerRebuild();
        }
      }
    } catch (e) {
      debugPrint('Google Translate API Error: $e');
    }
  }
}

String t(String key) => LanguageService.translate(key);
