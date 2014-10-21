Getting Started
---------------

The MoblicoSDK has been designed to be easy to use with a simple block based
interface ([see example below](#example)). Setting up the SDK can be done in a 
few steps:

1.	Download the SDK: [MoblicoSDK.zip](http://developer.moblico.com/sdks/ios/MoblicoSDK.zip "Download MoblicoSDK.zip")

2.	Create a new Xcode project or open an existing project.

3.	Unzip MoblicoSDK.zip and drag MoblicoSDK.framework into the Frameworks 
	folder in your Xcode project. Be sure to enable *Copy items into destination
	group's folder*
	
	![Drag MoblicoSDK.framework to Frameworks][1]
	
	![Enable Copy items into destination group's folder][2]
	
4.	Add Security.framework to the project using the *Link Binary With Libraries*
	target build phase.

	![Add Items to Link Binary With Libraries build phase][3]

	![Add Security.framework][4]

5.	Configure `MLCServiceManager` with your Moblico API Key.

	```
	[MLCServiceManager setAPIKey:@"YOUR_API_KEY"];
	```

	*Please see the `MLCServiceManager` class reference for more information and
	configuration options.*

### <a id="example"></a>Example ###

Once you have configured `MLCServiceManager` you can begin making service calls.
For example, if you have set any Custom Application Settings they can be
retrieved in your app asynchronously by using `+[MLCSettingsService
readSettings:]`

```
// Create an instance and define the callback handler
MLCSettingsService *settingsService = 
	[MLCSettingsService readSettings:^(NSDictionary *settings,
                                       NSError *error,
                                       NNSHTTPURLResponse *response) {
	if (error) {
		NSLog(@"An error occurred: %@", [error localizedDescription]);
	}
	else {
		NSLog(@"Settings: %@", settings);
	}
}];

// Start the service asynchronously
[settingsService start];
```


[1]: http://developer.moblico.com/sdks/ios/docs/docs/images/DragSDK2.png "Drag MoblicoSDK.framework"

[2]: http://developer.moblico.com/sdks/ios/docs/docs/images/Copy2.png "Enable Copy"

[3]: http://developer.moblico.com/sdks/ios/docs/docs/images/AddItems2.png "Add Items"

[4]: http://developer.moblico.com/sdks/ios/docs/docs/images/OK2.png "Add Security.framework"
