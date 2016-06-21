Getting Started
---------------

The MoblicoSDK has been designed to be easy to use with a simple block based
interface ([see example below](#example)). Setting up the SDK can be done in a 
few steps:

1. Download the SDK: [MoblicoSDK.zip](http://developer.moblico.com/sdks/ios/MoblicoSDK.zip "Download MoblicoSDK.zip")
1. Create a new Xcode project or open an existing project.
3. Unzip MoblicoSDK.zip and drag MoblicoSDK.framework into your Xcode project. Be sure to enable *Copy items if needed*

   ![Drag MoblicoSDK.framework to Frameworks][1]

   ![Enable Copy items into destination group's folder][2]

4. Configure `MLCServiceManager` with your Moblico API Key.

   ```
   [MLCServiceManager setAPIKey:@"YOUR_API_KEY"];
   ```

   *Please see the `MLCServiceManager` class reference for more information and
	configuration options.*

<h3 id="example">Example</h3>

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

[1]: http://developer.moblico.com/sdks/ios/docs/docs/images/DragSDK.png "Drag MoblicoSDK.framework"

[2]: http://developer.moblico.com/sdks/ios/docs/docs/images/Copy.png "Enable Copy"
