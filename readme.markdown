## Getting Started

The MoblicoSDK has been designed to be easy to use with a simple block based interface ([see example below](#example)). Setting up the SDK can be done in a few steps:

1. Download the SDK: [MoblicoSDK.zip](http://developer.moblico.com/sdks/ios/MoblicoSDK.zip)
2. Create a new Xcode project or open an existing project.
3. Unzip MoblicoSDK.zip and drag MoblicoSDK.framework into the Frameworks folder in your Xcode project. Be sure to enable _Copy items into destination group's folder_
	
	![Drag MoblicoSDK.framework to Frameworks](http://developer.moblico.com/sdks/ios/docs/docs/images/DragSDK2.png "Drag MoblicoSDK.framework")
	
	![Enable Copy items into destination group's folder](http://developer.moblico.com/sdks/ios/docs/docs/images/Copy2.png "Enable Copy")
4. Add Security.framework to the project using the _Link Binary With Libraries_ target build phase.
	
	![Add Items to Link Binary With Libraries build phase](http://developer.moblico.com/sdks/ios/docs/docs/images/AddItems2.png "Add Items")
	
	![Add Security.framework](http://developer.moblico.com/sdks/ios/docs/docs/images/OK2.png "Add Security.framework")
5. Configure MLCServiceManager with your Moblico API Key.

	    [MLCServiceManager setAPIKey:@"YOUR_API_KEY"];

_Please see the MLCServiceManager class reference for more information and configuration options._

### <a id="example"></a>Example


Once you have configured MLCServiceManager you can begin making service calls. For example, if you have set any Custom Application Settings they can be retrieved in your app asyncronously by using  -[MLCSettingsService readSettings:]

	// Create an instance and define the callback handler
	MLCSettingsService *settingsService = [MLCSettingsService readSettings:^(NSDictionary *settings,
                                                                             NSError *error,
                                                                             NSHTTPURLResponse *response) {
		if (error && self.view.window) {
			NSLog(@"An error occured: %@", [error localizedDescription]);
		}
		else {
			NSLog(@"Settings: %@", settings);
		}
	}];
	
	// Start the service asyncronously
	[settingsService start];