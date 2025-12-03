// lib/core/config/app_secrets.dart
import 'dart:math' as math; // Changed from 'Math' to 'math'

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSecrets {
  // Try compile-time environment first (from --dart-define in CI/CD)
  // Fall back to .env file for local development
  
  static String get mapKey {
    const fromDefine = String.fromEnvironment('MAP_KEY');
    if (fromDefine.isNotEmpty) {
      debugPrint('Using MAP_KEY from build arguments');
      return fromDefine;
    }
    
    // Try .env file (local development)
    try {
      final fromEnv = dotenv.env['MAP_KEY'];
      if (fromEnv != null && fromEnv.isNotEmpty) {
        debugPrint('Using MAP_KEY from .env file');
        return fromEnv;
      }
    } catch (e) {
      // dotenv not initialized
    }
    
    // In production, we should have a value
    if (kReleaseMode) {
      throw Exception('MAP_KEY not configured for production');
    }
    
    // In development, return empty but log warning
    debugPrint('⚠️ MAP_KEY not configured');
    return '';
  }
  
  static String get webFire {
    const fromDefine = String.fromEnvironment('WEB_FIRE');
    if (fromDefine.isNotEmpty) {
      debugPrint('Using WEB_FIRE from build arguments');
      return fromDefine;
    }
    
    try {
      final fromEnv = dotenv.env['WEB_FIRE'];
      if (fromEnv != null && fromEnv.isNotEmpty) {
        debugPrint('Using WEB_FIRE from .env file');
        return fromEnv;
      }
    } catch (e) {
      // dotenv not initialized
    }
    
    if (kReleaseMode) {
      throw Exception('WEB_FIRE not configured for production');
    }
    
    debugPrint('⚠️ WEB_FIRE not configured');
    return '';
  }
  
  static String get andFire {
    const fromDefine = String.fromEnvironment('AND_FIRE');
    if (fromDefine.isNotEmpty) {
      debugPrint('Using AND_FIRE from build arguments');
      return fromDefine;
    }
    
    try {
      final fromEnv = dotenv.env['AND_FIRE'];
      if (fromEnv != null && fromEnv.isNotEmpty) {
        debugPrint('Using AND_FIRE from .env file');
        return fromEnv;
      }
    } catch (e) {
      // dotenv not initialized
    }
    
    if (kReleaseMode) {
      throw Exception('AND_FIRE not configured for production');
    }
    
    debugPrint('⚠️ AND_FIRE not configured');
    return '';
  }
  
  static String get iosFire {
    const fromDefine = String.fromEnvironment('IOS_FIRE');
    if (fromDefine.isNotEmpty) {
      debugPrint('Using IOS_FIRE from build arguments');
      return fromDefine;
    }
    
    try {
      final fromEnv = dotenv.env['IOS_FIRE'];
      if (fromEnv != null && fromEnv.isNotEmpty) {
        debugPrint('Using IOS_FIRE from .env file');
        return fromEnv;
      }
    } catch (e) {
      // dotenv not initialized
    }
    
    if (kReleaseMode) {
      throw Exception('IOS_FIRE not configured for production');
    }
    
    debugPrint('⚠️ IOS_FIRE not configured');
    return '';
  }
  
  static String get macFire {
    const fromDefine = String.fromEnvironment('MAC_FIRE');
    if (fromDefine.isNotEmpty) {
      debugPrint('Using MAC_FIRE from build arguments');
      return fromDefine;
    }
    
    try {
      final fromEnv = dotenv.env['MAC_FIRE'];
      if (fromEnv != null && fromEnv.isNotEmpty) {
        debugPrint('Using MAC_FIRE from .env file');
        return fromEnv;
      }
    } catch (e) {
      // dotenv not initialized
    }
    
    if (kReleaseMode) {
      throw Exception('MAC_FIRE not configured for production');
    }
    
    debugPrint('⚠️ MAC_FIRE not configured');
    return '';
  }
  
  static String get windFire {
    const fromDefine = String.fromEnvironment('WIND_FIRE');
    if (fromDefine.isNotEmpty) {
      debugPrint('Using WIND_FIRE from build arguments');
      return fromDefine;
    }
    
    try {
      final fromEnv = dotenv.env['WIND_FIRE'];
      if (fromEnv != null && fromEnv.isNotEmpty) {
        debugPrint('Using WIND_FIRE from .env file');
        return fromEnv;
      }
    } catch (e) {
      // dotenv not initialized
    }
    
    if (kReleaseMode) {
      throw Exception('WIND_FIRE not configured for production');
    }
    
    debugPrint('⚠️ WIND_FIRE not configured');
    return '';
  }
  
  // Helper to check if we have all required secrets
  static bool get areSecretsAvailable {
    final required = [mapKey, webFire, andFire, iosFire];
    return required.every((secret) => secret.isNotEmpty);
  }
  
  // Get all secrets as a map (useful for debugging)
  static Map<String, String> get allSecrets {
    return {
      'MAP_KEY': mapKey,
      'WEB_FIRE': webFire,
      'AND_FIRE': andFire,
      'IOS_FIRE': iosFire,
      'MAC_FIRE': macFire,
      'WIND_FIRE': windFire,
    };
  }
  
  // Log all secrets (truncated for security)
  static void logSecrets() {
    if (!kDebugMode) return; // Only log in debug mode
    
    debugPrint('🔐 App Secrets Configuration:');
    allSecrets.forEach((key, value) {
      if (value.isNotEmpty) {
        debugPrint('  $key: ${value.substring(0, math.min(8, value.length))}...'); // Fixed: Math → math
      } else {
        debugPrint('  $key: ❌ NOT SET');
      }
    });
  }
}