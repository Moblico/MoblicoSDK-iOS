# Sending Metrics using the Moblico SDK for iOS

This article outlines how to start a project, and send Metrics using the Moblico SDK.

## Prerequisites

Before you can begin:

1. Login to the Dev Portal: [moblico.net/developer](https://moblico.net/developer)
2. Retrieve your API Key for future use.


## Begin

1. Create a new Xcode Project, or open an existing project.
2. Add MoblicoSDK and Security frameworks.

	_For more information see the [Getting Started Guide](http://developer.moblico.com/sdks/ios/docs/)_
3. Configure the MLCServiceManager during `-application:didFinishLaunchingWithOptions:`

    ```
    - (BOOL)application:(UIApplication *)application  
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        // Enter your Moblico API key here
        [MLCServiceManager setAPIKey:@"YOUR_API_KEY_HERE"];
        return YES;
    }
    ```

4. Set the current user.

    ```
    [[MLCServiceManager sharedServiceManager] setCurrentUser:<#(MLCUser *)#>
                                                    remember:YES];
    ```
    _For more information see the [Users Example](http://developer.moblico.com/sdks/ios/docs/)_
    	
## Send Metrics

```
[MLCMetricsService sendMetricWithType:<#(MLCMetricType)#>
                                 text:<#(NSString *)#>];
```

## Metric Types

<dl class="termdef">
	<dt>
		MLCMetricTypeApplicationStart
	</dt>
	<dd>
		Specifies that the application started.
	</dd>
	<dt>
		MLCMetricTypeApplicationStop
	</dt>
	<dd>
		Specifies that the application has exited.
	</dd>
	<dt>
		MLCMetricTypeInBackground
	</dt>
	<dd>
		Specifies that the application has been sent to the background.
	</dd>
	<dt>
		MLCMetricTypeOutBackground
	</dt>
	<dd>
		Specifies that the application has resumed from the background.
	</dd>
	<dt>
		MLCMetricTypeEnterPage
	</dt>
	<dd>
		Specifies that the application has presented a view.
	</dd>
	<dt>
		MLCMetricTypeExitPage
	</dt>
	<dd>
		Specifies that the application has dismissed a view.
	</dd>
	<dt>
		MLCMetricTypeAdClick
	</dt>
	<dd>
		Specifies that the user has interacted an ad.
	</dd>
	<dt>
		MLCMetricTypeTracking
	</dt>
	<dd>
		Specifies a generic tracking metric.
	</dd>
	<dt>
		MLCMetricTypeCustom
	</dt>
	<dd>
		Specifies a custom metric used for triggers.
	</dd>
	<dt>
		MLCMetricTypeViewDeal
	</dt>
	<dd>
		Specifies that the user has interacted with a deal.
	</dd>
	<dt>
		MLCMetricTypeViewReward
	</dt>
	<dd>
		Specifies that the user has interacted with a reward.
	</dd>
	<dt>
		MLCMetricTypeViewLocation
	</dt>
	<dd>
		Specifies that the user has interacted with a location.
	</dd>
	<dt>
		MLCMetricTypeViewEvent
	</dt>
	<dd>
		Specifies that the user has interacted with an event.
	</dd>
	<dt>
		MLCMetricTypeViewMedia
	</dt>
	<dd>
		Specifies that the user has interacted with a media.
	</dd>
	<dt>
		MLCMetricTypeShareApp
	</dt>
	<dd>
		Specifies that the user has shared the app.
	</dd>
	<dt>
		MLCMetricTypeShareDeal
	</dt>
	<dd>
		Specifies that the user has shared a deal.
	</dd>
	<dt>
		MLCMetricTypeShareReward
	</dt>
	<dd>
		Specifies that the user has shared a reward.
	</dd>
	<dt>
		MLCMetricTypeShareLocation
	</dt>
	<dd>
		Specifies that the user has shared a location.
	</dd>
</dl>
