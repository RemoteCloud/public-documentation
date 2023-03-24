title: App Store SDK

# Maranics.AppStore.SDK

This SDK offers methods to communicate with the app store and validate API requests.

[**Demo**](https://github.com/RemoteCloud/AppStore.SDK.Demo) | [**Documentation**](https://developer.maranics.com/dev/examples/app-store-sdk/) | [**Nuget Feed**](https://www.nuget.org/packages/Maranics.AppStore.SDK/) | [**Git Repository**](https://github.com/RemoteCloud/AppStoreService)

---

### Initialization
Authorization result will be stored in DI container in `AccessTokenData` object. You can use it in any service via dependency injection.

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
}

public void Configure(IApplicationBuilder app)
{
    app.UseAppStore();
}
```

**Note:** `AppSettings.json` requires the following section for the auto configuration. Alternatively you can use `ConfigureAppStore(..)` overloads.

```json
"AppStoreSettings": {
   "ClientId": "key",
   "ClientSecret": "secretKey",
   "AppStoreUrl": "url"
}
```

### Validate incoming API calls
The example uses a custom Environment attribute inherited from `TypeFilterAttribute` and implements the `OnAuthorization` method.

```csharp
using Maranics.AppStore.SDK.Models;
using Maranics.AppStore.SDK.Services;

public void OnAuthorization(AuthorizationFilterContext context)
{
    HttpRequest request = context.HttpContext.Request;
    var service = context.HttpContext.RequestServices.GetService(typeof(IAccessValidationService)) as IAccessValidationService;
    
    string token = request.Headers["Authorization"];
    string tenant = request.Headers["Tenant"];
    string ipAddress = request.HttpContext.Connection.RemoteIpAddress?.MapToIPv4().ToString()
    
    ValidationResponse response = service.ValidateAccess(token, tenant, ipAddress);
    if (validationResult.HasAccess)
    {
        ...
    }
    else 
    {
        context.Result = new ObjectResult(validationResult.Error) { StatusCode = 401 };
    }
}
```

Validation response:

```json
{
  "HasAccess": "false",
  "Error": "error description",
  "ApplicationData": {
	"CompanyName": "",
	"Name": ""
  },
  "Permissions": [ "GUID", "GUID" ],
}
```

Tenant validation also can be included here. To include tenant validation add this lines to code above

```csharp
using Maranics.AppStore.SDK.Interfaces;
```
```csharp
var tenantProvider = context.HttpContext.RequestServices.GetService(typeof(ITenantProvider)) as ITenantProvider
```
```csharp
bool isTenantEnabled = AsyncHelper.RunSync(() => tenantProvider.IsTenantEnabledAsync(tenant));
if (!isTenantEnabled)
{
    ... 
}
```

### Tenant provider
As an example we use a service that is added to the DI container at startup. 

#### Tenant provider interface
Tenant provider is singleton class that stored in DI container by calling ConfigureAppStore() method.

`GetAvailableTenantsAsync()` - If tenants have not been loaded before, it loads the tenants into the provider, then returns the loaded list. If the tenants were loaded earlier, it returns the list contained in the provider.

`ReloadAvailableTenantsAsync()` - Updates the list of tenants stored in the provider.

`IsTenantEnabledAsync(string tenant)` - Checks the availability of the tenant. If the list of tenants has not been loaded before, it loads the list.

```csharp
using Maranics.AppStore.SDK.Models;
using Maranics.AppStore.SDK.Interfaces;

public class MyCustomService : IMyCustomService
{
    private ITenantProvider _provider;
    
    public MyCustomService(ITenantProvider provider)
    {
        _provider = provider;
    }
    
    public async Task<List<TenantAccess>> GetTenantsAsync()
    {
        List<AvailableTenant> tenants = await _provider.GetAvailableTenantsAsync();
        return tenants;
    }
    
    public async Task<bool> IsTenantEnabledAsync(string tenant)
    {
        return await _provider.IsTenantEnabledAsync(tenant);
    }
    
    public async Task UpdateTenantsListAsync()
    {
        await _provider.ReloadAvailableTenantsAsync();
    }
}
```

### Notifications
AppStore has the ability to send notifications to applications registered in it. 
The notification system includes retries logic in case of failure, as well as calling the methods of the SDK corresponding to the received notification - contains built-in acknowledgement logic (e.g If application get "tenants" notification and then process it by calling TenantProvider.ReloadAvailableTenantsAsync() notification will be acknowledged. If notification not acknowledged - AppStore will retry sending every hour).

To receive notifications your application url (e.g exampleApplicationDomain.com/) must be stored in AppStore

As an example we use a controller which fully complies with the requirements for receiving notifications.

```csharp
using Maranics.AppStore.SDK.Enums;
using Maranics.AppStore.SDK.Interfaces;

namespace Example
{
    [Route("appStore/notifications")]
    public class AppStoreNotificationController
    {
        private readonly ITenantProvider _tenantsProvider;

        public AppStoreNotificationController(ITenantProvider tenantsProvider)
        {
            _tenantsProvider = tenantsProvider;
        }

        [HttpGet()]
        [ProducesResponseType((int)HttpStatusCode.NoContent)]
        [ProducesResponseType((int)HttpStatusCode.BadRequest)]
        public async Task<IActionResult> NotificationTrigger([FromQuery][Required] NotificationType type)
        {
            switch (type)
            {
                case NotificationType.Cors:
                    break;
                case NotificationType.Tenants:
                    await _tenantsProvider.ReloadAvailableTenantsAsync();
                    break;
                case NotificationType.Restart:
                    await _tenantsProvider.ReloadAvailableTenantsAsync();
                    break;
                case NotificationType.NewApplication:
                    break;
                default:
                    return BadRequest("Unknown notification type");
            }
	    
            return NoContent();
        }
    }
}
```
