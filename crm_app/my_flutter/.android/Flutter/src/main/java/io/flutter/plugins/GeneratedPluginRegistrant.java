package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import com.plus.anji.ajflutterplugin.AjFlutterPlugin;
import me.yohom.amapbaselocation.AMapBaseLocationPlugin;
import io.flutter.plugins.connectivity.ConnectivityPlugin;
import com.anji.plus.flutter_aj_qrscan.FlutterAjQrscanPlugin;
import com.github.adee42.keyboardvisibility.KeyboardVisibilityPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    AjFlutterPlugin.registerWith(registry.registrarFor("com.plus.anji.ajflutterplugin.AjFlutterPlugin"));
    AMapBaseLocationPlugin.registerWith(registry.registrarFor("me.yohom.amapbaselocation.AMapBaseLocationPlugin"));
    ConnectivityPlugin.registerWith(registry.registrarFor("io.flutter.plugins.connectivity.ConnectivityPlugin"));
    FlutterAjQrscanPlugin.registerWith(registry.registrarFor("com.anji.plus.flutter_aj_qrscan.FlutterAjQrscanPlugin"));
    KeyboardVisibilityPlugin.registerWith(registry.registrarFor("com.github.adee42.keyboardvisibility.KeyboardVisibilityPlugin"));
    PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
