#import "NativeSettings.h"

@implementation NativeSettings

- (void)openURL:(NSString *)urlString withCallback:(CDVInvokedUrlCommand *)command {
    NSURL *url = [NSURL URLWithString:urlString];

    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:url
                                           options:@{}
                                 completionHandler:^(BOOL success) {
            CDVPluginResult *pluginResult;
            if (success) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Opened"];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot open"];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    } else {
        BOOL result = [[UIApplication sharedApplication] openURL:url];
        CDVPluginResult *pluginResult = result
            ? [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Opened"]
            : [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot open"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)open:(CDVInvokedUrlCommand*)command {
    NSString* key = [command.arguments objectAtIndex:0];
    NSString* prefix = SYSTEM_VERSION_LESS_THAN(@"11.3") ? @"app-settings:" : @"App-Prefs:";

    NSDictionary *pathMap = @{
        @"settings": @"",
        @"about": @"General&path=About",
        @"accessibility": @"General&path=ACCESSIBILITY",
        @"account": @"ACCOUNT_SETTINGS",
        @"autolock": @"DISPLAY&path=AUTOLOCK",
        @"display": @"Brightness",
        @"bluetooth": @"Bluetooth",
        @"castle": @"CASTLE",
        @"cellular_usage": @"General&path=USAGE/CELLULAR_USAGE",
        @"configuration_list": @"General&path=ManagedConfigurationList",
        @"date": @"General&path=DATE_AND_TIME",
        @"facetime": @"FACETIME",
        @"tethering": @"INTERNET_TETHERING",
        @"music": @"MUSIC",
        @"music_equalizer": @"MUSIC&path=EQ",
        @"music_volume": @"MUSIC&path=VolumeLimit",
        @"keyboard": @"General&path=Keyboard",
        @"locale": @"General&path=INTERNATIONAL",
        @"location": @"LOCATION_SERVICES",
        @"locations": @"Privacy&path=LOCATION",
        @"tracking": @"Privacy&path=USER_TRACKING",
        @"network": @"General&path=Network",
        @"nike_ipod": @"NIKE_PLUS_IPOD",
        @"notes": @"NOTES",
        @"notification_id": @"NOTIFICATIONS_ID",
        @"passbook": @"PASSBOOK",
        @"phone": @"Phone",
        @"photos": @"Photos",
        @"reset": @"General&path=Reset",
        @"ringtone": @"Sounds&path=Ringtone",
        @"browser": @"Safari",
        @"search": @"SIRI",
        @"sound": @"Sounds",
        @"software_update": @"General&path=SOFTWARE_UPDATE_LINK",
        @"storage": @"CASTLE&path=STORAGE_AND_BACKUP",
        @"store": @"STORE",
        @"usage": @"General&path=USAGE",
        @"video": @"VIDEO",
        @"vpn": @"General&path=Network/VPN",
        @"wallpaper": @"Wallpaper",
        @"wifi": @"WIFI",
        @"touch": @"TOUCHID_PASSCODE",
        @"battery": @"BATTERY_USAGE",
        @"privacy": @"Privacy",
        @"do_not_disturb": @"General&path=DO_NOT_DISTURB",
        @"keyboards": @"General&path=Keyboard/KEYBOARDS",
        @"mobile_data": @"MOBILE_DATA_SETTINGS_ID"
    };

    if ([key isEqualToString:@"application_details"]) {
        [self openURL:UIApplicationOpenSettingsURLString withCallback:command];
        return;
    }
    
    if ([key isEqualToString:@"notification_id"] || [key isEqualToString:@"notifications"]) {
        NSLog(@"[NativeSettings] Attempting to open notification settings for key: %@", key);
        
        if (@available(iOS 18.0, *)) {
            NSLog(@"[NativeSettings] Using iOS 18+ approach - app settings fallback");
            [self openURL:UIApplicationOpenSettingsURLString withCallback:command];
        } else if (@available(iOS 15.4, *)) {
            NSLog(@"[NativeSettings] Using iOS 15.4-17.x notification settings URL");
            NSString *notificationSettingsURL = @"App-prefs:NOTIFICATIONS_ID";
            NSLog(@"[NativeSettings] URL: %@", notificationSettingsURL);
            [self openURL:notificationSettingsURL withCallback:command];
        } else {
            NSLog(@"[NativeSettings] Using fallback UIApplicationOpenSettingsURLString for iOS < 15.4");
            NSLog(@"[NativeSettings] URL: %@", UIApplicationOpenSettingsURLString);
            [self openURL:UIApplicationOpenSettingsURLString withCallback:command];
        }
        return;
    }

    NSString *path = pathMap[key];
    if (path) {
        NSString *fullURL = [prefix stringByAppendingString:path];
        [self openURL:fullURL withCallback:command];
    } else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid Action"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}
@end
