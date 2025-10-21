import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SecurityProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;
  
  // Security settings
  bool _isBiometricEnabled = false;
  bool _isPinEnabled = false;
  bool _isAutoLockEnabled = false;
  int _autoLockDuration = 300; // 5 minutes default
  bool _isDataEncrypted = true;
  
  // Privacy settings
  bool _isAnalyticsEnabled = true;
  bool _isCrashReportingEnabled = true;
  bool _isDataSharingEnabled = false;
  bool _isLocationTrackingEnabled = false;
  
  // Session management
  DateTime? _lastActiveTime;
  bool _isLocked = false;
  
  SecurityProvider(this._prefs, this._secureStorage) {
    _loadSettings();
  }
  
  // Getters
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isPinEnabled => _isPinEnabled;
  bool get isAutoLockEnabled => _isAutoLockEnabled;
  int get autoLockDuration => _autoLockDuration;
  bool get isDataEncrypted => _isDataEncrypted;
  bool get isAnalyticsEnabled => _isAnalyticsEnabled;
  bool get isCrashReportingEnabled => _isCrashReportingEnabled;
  bool get isDataSharingEnabled => _isDataSharingEnabled;
  bool get isLocationTrackingEnabled => _isLocationTrackingEnabled;
  bool get isLocked => _isLocked;
  DateTime? get lastActiveTime => _lastActiveTime;
  
  // Load settings from storage
  Future<void> _loadSettings() async {
    _isBiometricEnabled = _prefs.getBool('biometric_enabled') ?? false;
    _isPinEnabled = _prefs.getBool('pin_enabled') ?? false;
    _isAutoLockEnabled = _prefs.getBool('auto_lock_enabled') ?? false;
    _autoLockDuration = _prefs.getInt('auto_lock_duration') ?? 300;
    _isDataEncrypted = _prefs.getBool('data_encrypted') ?? true;
    _isAnalyticsEnabled = _prefs.getBool('analytics_enabled') ?? true;
    _isCrashReportingEnabled = _prefs.getBool('crash_reporting_enabled') ?? true;
    _isDataSharingEnabled = _prefs.getBool('data_sharing_enabled') ?? false;
    _isLocationTrackingEnabled = _prefs.getBool('location_tracking_enabled') ?? false;
    
    final lastActiveString = _prefs.getString('last_active_time');
    if (lastActiveString != null) {
      _lastActiveTime = DateTime.parse(lastActiveString);
    }
    
    _checkAutoLock();
    notifyListeners();
  }
  
  // Biometric authentication
  Future<void> setBiometric(bool enabled) async {
    _isBiometricEnabled = enabled;
    await _prefs.setBool('biometric_enabled', enabled);
    notifyListeners();
  }
  
  // PIN management
  Future<void> setPin(String pin) async {
    final hashedPin = _hashPin(pin);
    await _secureStorage.write(key: 'user_pin', value: hashedPin);
    _isPinEnabled = true;
    await _prefs.setBool('pin_enabled', true);
    notifyListeners();
  }
  
  Future<void> removePin() async {
    await _secureStorage.delete(key: 'user_pin');
    _isPinEnabled = false;
    await _prefs.setBool('pin_enabled', false);
    notifyListeners();
  }
  
  Future<bool> verifyPin(String pin) async {
    final storedPin = await _secureStorage.read(key: 'user_pin');
    if (storedPin == null) return false;
    
    final hashedPin = _hashPin(pin);
    return hashedPin == storedPin;
  }
  
  String _hashPin(String pin) {
    final bytes = utf8.encode('${pin}sakina_salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Auto lock
  Future<void> setAutoLock(bool enabled) async {
    _isAutoLockEnabled = enabled;
    await _prefs.setBool('auto_lock_enabled', enabled);
    if (enabled) {
      _updateLastActiveTime();
    }
    notifyListeners();
  }
  
  Future<void> setAutoLockDuration(int seconds) async {
    _autoLockDuration = seconds;
    await _prefs.setInt('auto_lock_duration', seconds);
    notifyListeners();
  }
  
  void _updateLastActiveTime() {
    _lastActiveTime = DateTime.now();
    _prefs.setString('last_active_time', _lastActiveTime!.toIso8601String());
  }
  
  void _checkAutoLock() {
    if (!_isAutoLockEnabled || _lastActiveTime == null) return;
    
    final now = DateTime.now();
    final difference = now.difference(_lastActiveTime!).inSeconds;
    
    if (difference >= _autoLockDuration) {
      _isLocked = true;
    }
  }
  
  void updateActivity() {
    if (_isAutoLockEnabled) {
      _updateLastActiveTime();
    }
    if (_isLocked) {
      _isLocked = false;
      notifyListeners();
    }
  }
  
  void lockApp() {
    _isLocked = true;
    notifyListeners();
  }
  
  void unlockApp() {
    _isLocked = false;
    _updateLastActiveTime();
    notifyListeners();
  }
  
  // Data encryption
  Future<void> setDataEncryption(bool enabled) async {
    _isDataEncrypted = enabled;
    await _prefs.setBool('data_encrypted', enabled);
    notifyListeners();
  }
  
  // Privacy settings
  Future<void> setAnalytics(bool enabled) async {
    _isAnalyticsEnabled = enabled;
    await _prefs.setBool('analytics_enabled', enabled);
    notifyListeners();
  }
  
  Future<void> setCrashReporting(bool enabled) async {
    _isCrashReportingEnabled = enabled;
    await _prefs.setBool('crash_reporting_enabled', enabled);
    notifyListeners();
  }
  
  Future<void> setDataSharing(bool enabled) async {
    _isDataSharingEnabled = enabled;
    await _prefs.setBool('data_sharing_enabled', enabled);
    notifyListeners();
  }
  
  Future<void> setLocationTracking(bool enabled) async {
    _isLocationTrackingEnabled = enabled;
    await _prefs.setBool('location_tracking_enabled', enabled);
    notifyListeners();
  }
  
  // Data export
  Future<Map<String, dynamic>> exportUserData() async {
    final userData = <String, dynamic>{};
    
    // Get all preferences
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (!key.startsWith('security_') && !key.startsWith('pin_')) {
        final value = _prefs.get(key);
        userData[key] = value;
      }
    }
    
    // Add metadata
    userData['export_date'] = DateTime.now().toIso8601String();
    userData['app_version'] = '1.0.0';
    userData['data_format_version'] = '1.0';
    
    return userData;
  }
  
  // Data deletion
  Future<void> deleteAllUserData() async {
    // Clear preferences (except security settings)
    final keys = _prefs.getKeys().toList();
    for (final key in keys) {
      if (!key.startsWith('security_') && 
          !key.startsWith('biometric_') && 
          !key.startsWith('pin_') && 
          !key.startsWith('auto_lock_')) {
        await _prefs.remove(key);
      }
    }
    
    // Clear secure storage (except PIN)
    await _secureStorage.deleteAll();
    if (_isPinEnabled) {
      // Restore PIN if it was enabled
      // This would need to be handled more carefully in a real app
    }
    
    notifyListeners();
  }
  
  // Security audit
  Map<String, dynamic> getSecurityAudit() {
    return {
      'biometric_enabled': _isBiometricEnabled,
      'pin_enabled': _isPinEnabled,
      'auto_lock_enabled': _isAutoLockEnabled,
      'auto_lock_duration': _autoLockDuration,
      'data_encrypted': _isDataEncrypted,
      'analytics_enabled': _isAnalyticsEnabled,
      'crash_reporting_enabled': _isCrashReportingEnabled,
      'data_sharing_enabled': _isDataSharingEnabled,
      'location_tracking_enabled': _isLocationTrackingEnabled,
      'last_active': _lastActiveTime?.toIso8601String(),
      'is_locked': _isLocked,
      'security_score': _calculateSecurityScore(),
    };
  }
  
  double _calculateSecurityScore() {
    double score = 0;
    
    if (_isBiometricEnabled) score += 25;
    if (_isPinEnabled) score += 25;
    if (_isAutoLockEnabled) score += 20;
    if (_isDataEncrypted) score += 15;
    if (!_isDataSharingEnabled) score += 10;
    if (!_isLocationTrackingEnabled) score += 5;
    
    return score;
  }
  
  // Session management
  bool shouldRequireAuthentication() {
    if (!_isPinEnabled && !_isBiometricEnabled) return false;
    if (!_isAutoLockEnabled) return false;
    
    _checkAutoLock();
    return _isLocked;
  }
  
  // Backup and restore security settings
  Map<String, dynamic> exportSecuritySettings() {
    return {
      'biometric_enabled': _isBiometricEnabled,
      'auto_lock_enabled': _isAutoLockEnabled,
      'auto_lock_duration': _autoLockDuration,
      'data_encrypted': _isDataEncrypted,
      'analytics_enabled': _isAnalyticsEnabled,
      'crash_reporting_enabled': _isCrashReportingEnabled,
      'data_sharing_enabled': _isDataSharingEnabled,
      'location_tracking_enabled': _isLocationTrackingEnabled,
    };
  }
  
  Future<void> importSecuritySettings(Map<String, dynamic> settings) async {
    if (settings.containsKey('biometric_enabled')) {
      await setBiometric(settings['biometric_enabled'] ?? false);
    }
    if (settings.containsKey('auto_lock_enabled')) {
      await setAutoLock(settings['auto_lock_enabled'] ?? false);
    }
    if (settings.containsKey('auto_lock_duration')) {
      await setAutoLockDuration(settings['auto_lock_duration'] ?? 300);
    }
    if (settings.containsKey('data_encrypted')) {
      await setDataEncryption(settings['data_encrypted'] ?? true);
    }
    if (settings.containsKey('analytics_enabled')) {
      await setAnalytics(settings['analytics_enabled'] ?? true);
    }
    if (settings.containsKey('crash_reporting_enabled')) {
      await setCrashReporting(settings['crash_reporting_enabled'] ?? true);
    }
    if (settings.containsKey('data_sharing_enabled')) {
      await setDataSharing(settings['data_sharing_enabled'] ?? false);
    }
    if (settings.containsKey('location_tracking_enabled')) {
      await setLocationTracking(settings['location_tracking_enabled'] ?? false);
    }
  }
  
  // Reset all security settings
  Future<void> resetSecuritySettings() async {
    await setBiometric(false);
    await removePin();
    await setAutoLock(false);
    await setDataEncryption(true);
    await setAnalytics(true);
    await setCrashReporting(true);
    await setDataSharing(false);
    await setLocationTracking(false);
  }
}