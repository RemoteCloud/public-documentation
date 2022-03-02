title: App Store SDK

# Maranics.AppStrore.SDK


This SDK offers methods to communicate with the app store and validate API requests.

[**Git Repository**](https://github.com/RemoteCloud/AppStoreService) | [**Nuget Feed**](https://www.nuget.org/packages/Maranics.AppStore.SDK/)

---

## Usage

### Initialize app store in `Startup.cs`:

#### 1) Add AppStore required services to DI services container
```csharp
using Maranics.AppStore.SDK;
....
public IConfiguration Configuration { get; }
....
public Startup(IConfiguration configuration)
{
    Configuration = configuration;
    ....
}
....
public void ConfigureServices(IServiceCollection services)
{
    ....
    services.ConfigureAppStore(Configuration);
    ....
}
```
Configuration file should contain section:
```json
"AppStoreSettings": {
   "ClientId": "key",
   "ClientSecret": "secretKey",
   "AppStoreUrl": "url"
}
```
Otherwise you should use ConfigureAppStore method overloads to pass data in different way

#### 2) Run AppStore initialization tasks in case when need authorize app on startup

```csharp
public void Configure(IApplicationBuilder app)
{
    ....
    app.UseAppStore();
    ....
}
```
Authorization result will be stored in DI container in AccessTokenData object. After you can use it in any service via Dependency Injection
### Validate incoming API calls against the app store:
The presented example uses a custom Environment attribute inherited from TypeFilterAttribute and implements the OnAuthorization method
```csharp
using Maranics.AppStore.SDK.Models;
using Maranics.AppStore.SDK.Services;
....

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

ValidationResponse:

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
### Get allowed tenants list
As an example we use a service that is added to the DI container at startup. 
```csharp
using Maranics.AppStore.SDK.Models;
using Maranics.AppStore.SDK.Services;
....
public class MyCustomService : IMyCustomService
{
    private IConnectivityService _service;
    private AccessTokenData _tokenData;
    
    public MyCustomService(IConnectivityService service, AccessTokenData tokenData)
    {
        _service = service;
	_tokenData = tokenData;
	....
    }
    
    public async Task<List<TenantAccess>> GetAllowedTenantList()
    {
        var response = await _service.GetAllowedTenants(_tokenData.Token);
	if (response != null && response.HasError == false)
            return response.Data;
        return new List<TenantAccess>();
    }
   
    ....
}
```