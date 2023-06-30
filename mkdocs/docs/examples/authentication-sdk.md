title: Maranics Authentication SDK

# Maranics.AspNetCore.Authentication

This SDK offers methods to implement Maranics authentication.

[**Nuget Feed**](https://www.nuget.org/packages/Maranics.AspNetCore.Authentication/) | [**Git Repository**](https://github.com/RemoteCloud/Maranics.AspNetCore.Authentication)

---
### Preparation
Application must be registred in Maranics AppStore service to get app `ClientID`. This ClientID will be used diring auth process. 


### Configuration
Add this configuration section to your application settings. `ClientAppUrls` must contain all possible application urls that will be in use - they will be used for callbacks. `CookieDomain` setup domain for which session cookies will be issued.

```json
  "OpenIdConnect": {
    "ClientAppUrls": [ "https://localhost:port" ],
    "CookieDomain": "localhost"
  }
```

Application settings must contain AppStore and Redis connection section as well.

```json
  "AppStoreSettings": {
    "ClientId": "",
    "ClientSecret": "",
    "AppStoreUrl": "http://localhost:port/",
    "Issuer": "http://localhost:port/"
  }
```

```json
  "ConnectionStrings": {
    "Redis": ""
  }
```

### Implementation
Add following code to your startup class

```csharp
using Maranics.AspNetCore.Authentication.OpenIdConnect;
using Maranics.AspNetCore.Authentication.Extensions;
using Maranics.AspNetCore.Authentication.Services;
using Maranics.AspNetCore.Authentication;
using StackExchange.Redis;

public void ConfigureServices(IServiceCollection services)
{
...
  AppStoreSettings appStoreSettings = Configuration.GetSection(nameof(AppStoreSettings)).Get<AppStoreSettings>();
  OpenIdConnectSettings openIdConnectSettings = Configuration.GetSection(OpenIdConnectSettings.OpenIdConnectSettingsSectionName).Get<OpenIdConnectSettings>();
  services.AddSingleton(openIdConnectSettings);
  
  services.AddMaranicsAuthentication(typeof(TenantResolver), appStoreSettings, openIdConnectSettings);
  services.AddScoped<AuthenticatedSchemeResolver>();
  
  string redisConnectionString = Configuration.GetConnectionString(RedisConnectionStringName);
  var redis = ConnectionMultiplexer.Connect(redisConnectionString);  
  services.AddDataProtection()
    .PersistKeysToStackExchangeRedis(redis, "DataProtection-Keys").SetApplicationName("SSO");

  services.Configure<ForwardedHeadersOptions>(options =>
  {
    options.ForwardedHeaders =
    ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedHost | ForwardedHeaders.XForwardedProto;
    options.KnownNetworks.Clear();
    options.KnownProxies.Clear();
  });
...
}

public void Configure(IApplicationBuilder app, IWebHostEnvironment env, IConfigurationService configurationService
{
  app.UseForwardedHeaders();
  ...
  app.UseAuthentication();
  app.UseAuthorization();
  app.UseMiddleware<SessionContextProvisioningMiddleware>();
  ...
}
```

#### TenantResolver
` services.AddMaranicsAuthentication(typeof(TenantResolver), appStoreSettings, openIdConnectSettings);` require ITenantResolver.
Tenant resolver class is used to get current execution tenant for using in authentication / authorization process. With the help of a tenant, the correct UserManagement and the correct IdentityProvider are called.

`TenantResolver` must be implemented with your own tenant resolving logic but it must inherit `ITenantResolver` interface from 
```csharp
Maranics.AspNetCore.Authentication.Services;
```

and must return 
```csharp
namespace Maranics.AspNetCore.Authentication.Services
{
    public class Tenant
    {
        public string Name { get; set; }

        public string UserManagementUrl { get; set; }
    }
}
```

#### SessionContextProvisioningMiddleware

This middleware is used to set session context based on authentication result. 
Implementation of this middleware must be completed on your own based on the way how session is stored / used in your application.
Example will provide the way how to handle different authentication schemas that are used in Maranics apps via `AuthenticatedSchemeResolver`.

You can ignore `SessionContextProvisioningMiddleware` and use default HttpContext.ClaimPrincipal.User in case if you do not need to convert default session to custom.

```csharp
public class SessionContextProvisioningMiddleware
{
  private readonly RequestDelegate _next;
  private readonly AppStoreSettings _appStoreSettings;
  private string _tenantUnsensitivePath = "/api/service";

  public SessionContextProvisioningMiddleware(RequestDelegate next, AppStoreSettings appStoreSettings)
  {
      _next = next;
      _appStoreSettings = appStoreSettings;
  }

  public async Task InvokeAsync(HttpContext context)
  {
      AuthenticatedSchemeResolver authenticatedSchemeResolver = context.RequestServices.GetRequiredService<AuthenticatedSchemeResolver>();
      string authenticatedScheme = authenticatedSchemeResolver.ResolveScheme();
      if (!string.IsNullOrEmpty(authenticatedScheme))
      {
          context.Resolve(out IDependenciesProvider dependenciesProvider);
          context.Resolve(out IConfigurationService configurationService);
          TenantConfiguration tenant = null;

          if (!context.Request.Path.Value.ToLower().Contains(_tenantUnsensitivePath))
          {
              tenant = configurationService.GetCurrentTenant<TenantConfiguration>();
          }

          //ExecutingContext is session data provider used in all maranics applications.
          ExecutingContext executingContext = dependenciesProvider.GetCurentExecutingContext();
          executingContext.UserManagementUri = tenant?.UserManagementUri;

          switch (authenticatedScheme)
          {
              case AuthenticationSchemeConstants.AppStoreScheme:
                  SetAppStoreAuthorizedSessionContext(context, tenant, executingContext);
                  break;
              case AuthenticationSchemeConstants.UserManagementScheme:
                  SetUserManagementAuthorizedSessionContext(context, executingContext);
                  break;
              case AuthenticationSchemeConstants.UserManagementUserApiTokenScheme:
                  SetUserManagementApiTokenAuthorizedSessionContext(context, executingContext);
                  break;
              default:
                  break;
          }
      }

      await _next(context);
  }
}
```

#### Authorization policies
You can provide your own authorization policies as well. To add policy modify your startup class by adding following code.

```csharp
...
services.AddMaranicsAuthentication(typeof(TenantResolver), appStoreSettings, openIdConnectSettings);
services.AddSingleton<IAuthorizationHandler, UserHasRoleRequirementHandler>();
services.AddScoped<AuthenticatedSchemeResolver>();

AuthorizationPolicy defaultPolicy = new AuthorizationPolicyBuilder()
  .AddRequirements(new UserHasRoleRequirement())
  .RequireAuthenticatedUser()
  .Build();

services.AddAuthorization(options =>
{
    options.DefaultPolicy = defaultPolicy;
});
```

Implement following classes for your policy (use Microsoft docs to get more information about authorization policies)
You able to use Maranics.Authentication SDK tools as well. Example provide the way how to use AuthenticatedSchemeResolver to build your policy based on it

```csharp
using Maranics.AspNetCore.Authentication;
using Maranics.AspNetCore.Authentication.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;

public class UserHasRoleRequirement : IAuthorizationRequirement
{
}

public class UserHasRoleRequirementHandler : AuthorizationHandler<UserHasRoleRequirement>
{
  private readonly IHttpContextAccessor _httpContextAccessor;

  public UserHasRoleRequirementHandler(IHttpContextAccessor httpContextAccessor)
  {
    _httpContextAccessor = httpContextAccessor;
  }

  protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, UserHasRoleRequirement requirement)
  {
    AuthenticatedSchemeResolver authenticatedSchemeResolver = _httpContextAccessor.HttpContext.RequestServices.GetRequiredService<AuthenticatedSchemeResolver>();
    string authenticatedScheme = authenticatedSchemeResolver.ResolveScheme();

    // add your logic here

    return Task.CompletedTask;
  }
}
```

### Using
To use Authentication / Authorization add following attributes to your controllers. 

```csharp
using Maranics.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;

...

[Authorize(AuthenticationSchemes = AuthenticationSchemeConstants.AppStoreScheme)]
[Authorize(AuthenticationSchemes = AuthenticationSchemeConstants.AllUsermanagementSchemes, Policy = AuthorizationPolicyConstants.RequireSpecificRolePolicy)]
```

First attribute allow to use AppStore token to access controller method. Second attribute allow to use all UserManagement schemas - UserManagement session, UserManagement API token as well. Also second attribute require authorization policy validation

### SignIn
Using of this SDK help to setup single sign in logic with Maranics UserManagement. When your controller endpoint with `[Authorize...]` attribute get 401 - you will be redirected to UserManagement signIn page.
