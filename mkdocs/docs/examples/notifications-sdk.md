title: Notifications SDK

# Maranics.Notifications.SDK

This SDK offers methods to send and receive notifications to/from any application which is registered in App store.

[**Demo**](https://github.com/RemoteCloud/Notifications.SDK.Demo) | [**Documentation**](https://developer.maranics.com/dev/examples/notifications-sdk/) | [**Nuget Feed**](https://www.nuget.org/packages/Maranics.Notifications.SDK/) | [**Git Repository**](https://github.com/RemoteCloud/NotificationService)

---

### Prerequisites 
To be able to send and receive notifications following conditions should be implemented:

* Application has to be registered in AppStore and client credentials configured
* Following permissions has to be granted for application in AppStore:
   * "Subscribe to receive new notifications and confirm delivery." (notification-service/notifications/subscribe) - to be able to subscribe and receive regular notifications
   * "Send new notifications to destination." (notification-service/notifications/send)  - to be able to send notifications
   * "View (retrieve) notifications." (notification-service/notifications/view) - to be able to retrieve notifications
   * "Change notification status as read." (notification-service/notifications/mark-as-read) - to be able to mark notification as read
   *  "Manage push notification subscriptions (e.g. register, delete)." (notification-service/push-notification-subscriptions/manage) - to be able to register push notification subscriptions

### Initialization
You can add notifications functionality in any service via dependency injection.

```csharp
using Maranics.AppStore.SDK;

public IConfiguration Configuration { get; }

public Startup(IConfiguration configuration)
{
    Configuration = configuration;
}

public void ConfigureServices(IServiceCollection services)
{
    services.ConfigureAppStore(Configuration);
    services.AddNotifications(configuration, serviceProvider =>
    {
        var tokenProvider = serviceProvider.GetService<IAccessTokenProvider>();
        return tokenProvider!.GetTokenAsync();
    });
}

public void Configure(IApplicationBuilder app)
{
    app.UseAppStore();
}
```

**Note:** `AppSettings.json` requires the following section for the auto configuration.

```json
"AppStoreSettings": {
   "ClientId": "key",
   "ClientSecret": "secretKey",
   "AppStoreUrl": "url"
},
"NotificationServiceEndpoint": {
    "BaseUrl": "notification_service_base_url",
    "ApiBasePath": "/api",
    "NotificationsHubPath": "/hub/notifications"
}
```

### Notification sending
The example uses a background service to send notification (regular and push notifications) to single recipient each 5 seconds. Injected INotificationsManager instance is used to send, retrieve and mark as read.

```csharp
using Maranics.Notifications.SDK;

namespace Notifications.SDK.Demo
{
    public class NotificationSenderService : BackgroundService
    {
        private readonly INotificationsManager _notificationsManager;
        private readonly ILogger<NotificationSenderService> _logger;

        public NotificationSenderService(INotificationsManager notificationsManager, ILogger<NotificationSenderService> logger)
        {
            _notificationsManager = notificationsManager;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken cancellationToken)
        {
            const string tenant = "Development";
            Notification notification;
            int currentMessageIndex = 1;
            var request = new DispatchNotificationRequest()
            {
                Source = new NotificationSource()
                {
                    SenderId = Guid.NewGuid().ToString(),
                    SenderName = Constants.AppName
                },
                Content = new NotificationContent()
                {
                    Type = NotificationType.Information,
                },
                RecipientFilters = new List<NotificationRecipientFilter>()
                {
                     new NotificationRecipientFilter(){ Scope = Constants.AppName, LocationId = Guid.NewGuid(), Users = new List<Guid>(){ Guid.NewGuid() } }
                }
            };

            while (cancellationToken.IsCancellationRequested == false)
            {
                request.Content.Body = $"Message #{currentMessageIndex}";
                DispatchNotificationResponse response = await _notificationsManager.DispatchNotificationAsync(tenant, body: request);
                foreach (var notificationId in response.NotificationIds)
                {
                    notification = _notificationsManager.GetNotification(notificationId, tenant);
                    _logger.LogInformation($"Notification (id: {notification.NotificationId}) sent to user {notification.UserId}.");
                }
                currentMessageIndex++;
                await Task.Delay(TimeSpan.FromSeconds(5));
            }
        }
    }
}
```

### Subscribe and receive notifications
The example uses a background service to subscribe and receive notifications in real time. ProcessSubscription and ProcessNewNotification are passed as delegates to NotificationsListener.Subscribe method. Subscriber application name should be provided as well.

```csharp
using Maranics.Notifications.SDK;
using Maranics.Notifications.SDK.Models;
using Notifications.SDK.Demo;

public class NotificationListenerService : IHostedService
{
    private readonly NotificationsListener _notificationListener;
    private readonly ILogger<NotificationListenerService> _logger;

    public NotificationListenerService(NotificationsListener notificationListener, ILogger<NotificationListenerService> logger)
    {
        _notificationListener = notificationListener;
        _logger = logger;
    }

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Notification Listener Service is starting.");

        await _notificationListener.Subscribe(new SubscribeToNotificationsRequest
        {
            ApplicationName = Constants.AppName
        },
        ProcessNewNotification, ProcessSubscription, cancellationToken);

        _logger.LogInformation("Notification Listener Service is running.");
    }

    public Task StopAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Notification Listener Service is stopping.");

        return Task.CompletedTask;
    }

    private Task ProcessNewNotification(ReceiveNotificationMessage notificationMessage)
    {
        _logger.LogInformation(@$"New notification received from notification service:
            Notification Id: {notificationMessage.NotificationId}
            Notification created on: {notificationMessage.CreatedOn}
            Notification content: {notificationMessage.Content}");

        return Task.CompletedTask;
    }


    private Task ProcessSubscription(SubscribeToNotificationsResponse subscription)
    {
        if (!string.IsNullOrEmpty(subscription.Result?.ApplicationName))
        {
            foreach (var tenant in subscription.Result.TenantNames ?? Enumerable.Empty<string>())
            {
                _logger.LogInformation($"Application '{Constants.AppName}':  Tenant {tenant} is connected to listen notifications.");
            }
        }
        else
        {
            _logger.LogWarning($"Application '{Constants.AppName}': Failed to subscribe - {subscription.Error?.Message}");
        }

        return Task.CompletedTask;
    }
}
```
### VAPID (Voluntary Application Server Identity) key retrieval
The example shows how to retrieve VAPID key needed for push notification subscription creation in browser.

```csharp
app.MapGet("/subscriptions/vapid", ([FromServices] IPushNotificationSubscriptionsManager pushNotificationSubscriptionsManager) => { return pushNotificationSubscriptionsManager.GetVapidPublicKey(tenant); });
```

### Push notification subscription registration and removal
Once push notification subscription is made, it should be registered in Notification service using SDK to be able to send push notification to corresponding users. 
Push notification subscription registration using IPushNotificationSubscriptionsManager.RegisterPushNotificationSubscription example:

```csharp
app.MapPost("/subscriptions", (Subscription subscription, [FromServices] IPushNotificationSubscriptionsManager pushNotificationSubscriptionsManager) =>
{
    var pushNotificationSubscription = new PushNotificationSubscription()
    {
        Endpoint = subscription.Endpoint,
        PublicKey = subscription.PublicKey,
        AuthKey = subscription.AuthKey,
        ApplicationServerKey = subscription.Vapid,
        Scope = subscription.AppName,
        UserId = subscription.UserId
    };
    return pushNotificationSubscriptionsManager.RegisterPushNotificationSubscription(tenant, body: pushNotificationSubscription);
});
```

Push notification subscription removal (should be called once unsubscribe) using IPushNotificationSubscriptionsManager.RemovePushNotificationSubscription example:
```csharp
app.MapDelete("subscriptions", ([FromQuery(Name = "endpoint")] string endpoint, [FromServices] IPushNotificationSubscriptionsManager pushNotificationSubscriptionsManager) =>
{
    pushNotificationSubscriptionsManager.RemovePushNotificationSubscription(endpoint, tenant);
});
```