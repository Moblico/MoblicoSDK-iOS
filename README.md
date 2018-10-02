Getting Started
---------------

The MoblicoSDK has been designed to be easy to use with a simple block based interface ([see example below](#example)). Setting up the SDK can be done in a  few steps:

1. Download the SDK: [MoblicoSDK.zip](http://developer.moblico.com/sdks/ios/MoblicoSDK.zip "Download MoblicoSDK.zip")
2. Create a new Xcode project or open an existing project.
3. Unzip MoblicoSDK.zip and drag MoblicoSDK.framework into your Xcode project. Be sure to enable *Copy items if needed*

    <img src="http://developer.moblico.com/sdks/ios/docs/docs/images/DragSDK.png" srcset="http://developer.moblico.com/sdks/ios/docs/docs/images/DragSDK.png 1x, http://developer.moblico.com/sdks/ios/docs/docs/images/DragSDK@2x.png 2x" alt="Drag MoblicoSDK.framework to Frameworks" title="Drag MoblicoSDK.framework">

    <img src="http://developer.moblico.com/sdks/ios/docs/docs/images/Copy.png" srcset="http://developer.moblico.com/sdks/ios/docs/docs/images/Copy.png 1x, http://developer.moblico.com/sdks/ios/docs/docs/images/Copy@2x.png 2x" alt="Enable Copy items into destination group's folder" title="Enable Copy">

4. Configure `MLCServiceManager` with your Moblico API Key.

    ```objc
    [MLCServiceManager setAPIKey:@"<#YOUR_API_KEY#>"];
    ```

    ```swift
    ServiceManager.apiKey = "<#YOUR_API_KEY#>"
    ```

    *Please see the `MLCServiceManager` class reference for more information and configuration options.*

<h3 id="example">Example</h3>

Once you have configured `MLCServiceManager` you can begin making service calls. For example, if you have set any Custom Application Settings they can be retrieved in your app asynchronously by using `+[MLCSettingsService readSettings:]`

```objc
// Create an instance and define the callback handler
MLCSettingsService *settingsService = 
    [MLCSettingsService readSettings:^(NSDictionary *settings,
                                       NSError *error) {
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

```swift
// Create an instance and define the callback handler
let settingsService = SettingsService.readSettings { (settings, error) in
    if let settings = settings {
        print("Settings: \(settings)")
    } else if let error = error {
        print("An error occurred: \(error)")
    }
}

// Start the service asynchronously
settingsService.start()
```

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
