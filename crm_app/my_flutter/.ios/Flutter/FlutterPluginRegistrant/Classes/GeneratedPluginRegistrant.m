//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"
#import <aj_flutter_plugin/AjFlutterPlugin.h>
#import <amap_base_location/AMapBaseLocationPlugin.h>
#import <connectivity/ConnectivityPlugin.h>
#import <flutter_aj_qrscan/FlutterAjQrscanPlugin.h>
#import <keyboard_visibility/KeyboardVisibilityPlugin.h>
#import <path_provider/PathProviderPlugin.h>
#import <shared_preferences/SharedPreferencesPlugin.h>

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [AjFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"AjFlutterPlugin"]];
  [AMapBaseLocationPlugin registerWithRegistrar:[registry registrarForPlugin:@"AMapBaseLocationPlugin"]];
  [FLTConnectivityPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTConnectivityPlugin"]];
  [FlutterAjQrscanPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterAjQrscanPlugin"]];
  [FLTKeyboardVisibilityPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTKeyboardVisibilityPlugin"]];
  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
  [FLTSharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTSharedPreferencesPlugin"]];
}

@end
