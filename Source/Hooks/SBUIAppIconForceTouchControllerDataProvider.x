//
//  Source/Hooks/SBApplicationShortcutStoreManager.x
//  LaunchInSafeMode
//
//  Created by inoahdev on 5/20/17.
//  Copyright © 2017 inoahdev. All rights reserved.
//

#import "../Classes/LaunchInSafeModeTweak.h"

#import "../Headers/SpringBoardServices/SBSApplicationShortcutItem.h"
#import "../Headers/SpringBoardUI/SBUIAppIconForceTouchControllerDataProvider.h"

static NSString *const kLaunchInSafeModeTweakShortcutItemIdentifier = @"com.inoahdev.launchinsafemode.safemode";

%hook SBUIAppIconForceTouchControllerDataProvider
- (NSArray *)applicationShortcutItems {
    LaunchInSafeModeTweak *launchInSafeModeTweak = [LaunchInSafeModeTweak sharedInstance];
    NSArray *originalApplicationShortcutItems = %orig();

    BOOL launchInSafeModeTweakIsEnabled = [launchInSafeModeTweak isEnabled];
    if (!launchInSafeModeTweakIsEnabled) {
        return originalApplicationShortcutItems;
    }

    NSMutableDictionary *launchInSafeModeTweakCachedShortcutItems = [launchInSafeModeTweak cachedShortcutItems];
    NSString *bundleIdentifier = [[self applicationBundleIdentifier] retain];

    NSArray<SBSApplicationShortcutItem *> *applicationShortcutItems = [launchInSafeModeTweakCachedShortcutItems objectForKey:bundleIdentifier];
    if (applicationShortcutItems) {
        return applicationShortcutItems;
    }

    SBSApplicationShortcutItem *applicationShortcutItem = [[%c(SBSApplicationShortcutItem) alloc] init];

    [applicationShortcutItem setLocalizedTitle:@"Safe Mode"];
    [applicationShortcutItem setBundleIdentifierToLaunch:bundleIdentifier];
    [applicationShortcutItem setType:kLaunchInSafeModeTweakShortcutItemIdentifier];

    NSMutableArray *newApplicationShortcutItems = [originalApplicationShortcutItems mutableCopy];

    [newApplicationShortcutItems addObject:applicationShortcutItem];
    [launchInSafeModeTweakCachedShortcutItems setObject:newApplicationShortcutItems forKey:bundleIdentifier];

    [newApplicationShortcutItems release];
    [applicationShortcutItem release];
    [bundleIdentifier release];

    return newApplicationShortcutItems;
}

- (void)_installedAppsDidChange:(NSNotification *)installedAppsChangedNotification {
    NSDictionary *installedAppsChangedNotificationUserInfo = [installedAppsChangedNotification userInfo];
    NSSet *removedApplicationBundleIdentifiers = [installedAppsChangedNotificationUserInfo objectForKey:@"SBInstalledApplicationsRemovedBundleIDs"];

    if (removedApplicationBundleIdentifiers) {
        LaunchInSafeModeTweak *launchInSafeModeTweak = [LaunchInSafeModeTweak sharedInstance];
        NSMutableDictionary *launchInSafeModeTweakCachedShortcutItems = [launchInSafeModeTweak cachedShortcutItems];

        for (NSString *removedApplicationBundleIdentifier in removedApplicationBundleIdentifiers) {
            [launchInSafeModeTweakCachedShortcutItems removeObjectForKey:removedApplicationBundleIdentifier];
        }
    }

    %orig();
}
%end
