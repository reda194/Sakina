import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AppLocalizations {
  final Locale locale;
  static Map<String, dynamic>? _localizedStrings;

  AppLocalizations(this.locale);

  // Helper method to keep the code DRY
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    // Load the language JSON file from the "assets/lang" folder
    String jsonString =
        await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  // This method will be called from every widget which needs a localized text
  String translate(String key) {
    return _localizedStrings?[key] ?? key;
  }

  // Common translations used across the app
  String get appName => translate('app_name');
  String get welcome => translate('welcome');
  String get login => translate('login');
  String get signup => translate('signup');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirm_password');
  String get forgotPassword => translate('forgot_password');
  String get rememberMe => translate('remember_me');
  String get or => translate('or');
  String get continueAsGuest => translate('continue_as_guest');
  String get profile => translate('profile');
  String get home => translate('home');
  String get consultations => translate('consultations');
  String get therapy => translate('therapy');
  String get community => translate('community');
  String get tools => translate('tools');
  String get settings => translate('settings');
  String get logout => translate('logout');
  String get aboutUs => translate('about_us');
  String get privacyPolicy => translate('privacy_policy');
  String get termsOfService => translate('terms_of_service');
  String get contactUs => translate('contact_us');
  String get language => translate('language');
  String get notifications => translate('notifications');
  String get darkMode => translate('dark_mode');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get edit => translate('edit');
  String get delete => translate('delete');
  String get search => translate('search');
  String get filter => translate('filter');
  String get sort => translate('sort');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get warning => translate('warning');
  String get info => translate('info');
  String get noData => translate('no_data');
  String get tryAgain => translate('try_again');
  String get refresh => translate('refresh');
  String get submit => translate('submit');
  String get back => translate('back');
  String get next => translate('next');
  String get previous => translate('previous');
  String get finish => translate('finish');
  String get skip => translate('skip');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
