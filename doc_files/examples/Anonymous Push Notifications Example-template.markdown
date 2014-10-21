# Anonymous Push Notifications Example

Moblico uses a user based authentication scheme. In order to send push notifications to a device, you must first assign the device to a user. The SDK includes a convenience method for automatically registering anonymous devices.

This article outlines how to develop an iOS app to receive push notifications with the Moblico SDK for iOS. Review step 1 of the [Moblico Push Notifications Guide][PushGuide] for information or setting up your account with Push Notifications.

## Beginning with the Moblico SDK

1. Create a new Xcode Project, or open an existing project _(This example uses the Single View Application template)_.
2. Add MoblicoSDK and Security frameworks.

	_For more information see the [Getting Started Guide](http://developer.moblico.com/sdks/ios/docs/)_
3. Configure the MLCServiceManager during `-application:didFinishLaunchingWithOptions:`

		- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
			// Enter your Moblico API key here
			[MLCServiceManager setAPIKey:@"YOUR_API_KEY_HERE"];
			…
			return YES;
		}

## Register Device

This example uses the `-[MLCUserService createAnonymousDeviceWithDeviceToken:handler:]` method to automatically generate an anonymous user and assign the Apple Push Notification device token to that user.

Follow these steps to register your device with Moblico:

1. Register with Apple to receive push notifications

		// Register with Apple for notifications
		UIRemoteNotificationType types = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];

2. Handle receiving the device token from Apple.

		// Got deviceToken from Apple's Push Notification service.
		- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
		
			// Send the device token to Moblico
			MLCUsersService *createAnonymousDeviceService = [MLCUsersService createAnonymousDeviceWithDeviceToken:deviceToken handler:^(MLCStatus *status, NSError *error, NSHTTPURLResponse *response) {
				if (response.statusCode == 200) {
					NSLog(@"Registered Device Token: %@", deviceToken);
				}
				else {
					NSLog(@"Unable to register Device.\nstatus: %@ error: %@ response: %@", status, error, response);
				}
			}];
			[createAnonymousDeviceService start];
		}

3. You should now see your user in the Moblico Admin portal.

	*See step 2 of the [Moblico Push Notifications Guide][PushGuide] for more information.*


## Receive Push Notifications

Push notifications can enter your app in one of two ways.

1. Your app is launched by the push notification. ``- application:didFinishLaunchingWithOptions:`` will be called with the push notification in the launchOptions dictionary. 

		- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
			NSDictionary *pushNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
			…
			return YES;
		}

2. Your app is already running when the push notification is running. ``- application:didReceiveRemoteNotification:`` will be called with the push notification as the userInfo dictionary. 

		- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
			NSDictionary *pushNotification = userInfo;
			…
		}

*For more information on sending Push Notifications see step 3 of the [Moblico Push Notifications Guide][PushGuide].*

## Download

Download the Anonymous Push Notifications example source code: [AnonymousPushNotifications.zip](http://developer.moblico.com/sdks/ios/samplecode/AnonymousPushNotifications.zip)

[PushGuide]: http://developer.moblico.com/guides/Push_Notifications