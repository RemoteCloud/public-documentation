title: Event Sync Service SDK

# Maranics.EventSyncService.SDK

Maranics.EventSyncService.SDK is a general purpose Event Sync Service client for .NET. 

SDK has `netstandard 2.1` target.

The client is developed by (and used-by) Maranics.

This SDK offers methods to send and receive events from edge/cloud to cloud/edge instances.

[**Demo**](https://github.com/RemoteCloud/EventSync.SDK.Demo) | [**Documentation**](https://developer.maranics.com/dev/examples/event-sync-sdk/) | [**Nuget Feed**](https://www.nuget.org/packages/Maranics.EventSyncService.SDK/) | [**Git Repository**](https://github.com/RemoteCloud/EventSyncApp)

---
## Installation

```
PM> Install-Package Maranics.EventSyncService.SDK
```

## Prerequisites 
To be able to send and receive events, following conditions have to be in place:

* If an application is deployed on the Cloud/HQ location, then it needs to know location destination id(s);
* An application has to be registered in the AppStore and client credentials need to be configured;
* The following permissions has to be granted for an application in the AppStore:
   * _"event-sync/events/receive"_ - Allow receive new events and confirm delivery;
   * _"event-sync/events/send"_ - Allow send new event to destination;
   * _"event-sync/events/subscribe"_ - Allow subscribe to events.


## Initialization

In order to create client(subscriber), SDK offers builder:

- Use `EventSyncConnectionBuilder` to configure subscriber.
- Specify Event Sync Service base URL, register AccessTokenProvider delegate.
- Register event handler, if you would like to receive new events from another location.
- Register status handler, if you would like to receive updates on sent events.
- It is also possible to connect your logger provider, use extensions method `ConfigureLogging`.

```csharp
var subscriber = new EventSyncConnectionBuilder()
        .WithCredentials(opt =>
        {
            opt.AccessTokenProvider = async () => await tokenProvider.GetTokenAsync();
            opt.EventSyncUrl = "https://eventSyncService";
        })
        .WithEventHandler(ProcessNewEvent)
        .WithEventStatusHandler(ProcessStatus)
        .ConfigureLogging(logging =>
        {
            logging.AddConsole();
            logging.SetMinimumLevel(LogLevel.Debug);
        })
        .Build();
```

## Connecting to service
In order to send or receive events, subscriber should connect to the service. 
Simply call `Connect()` method.

```csharp
SubscriptionResult result = await subscriber.Connect();
```
`Connect()` will retrieve name of a connected application and list of connected tenants, if subscription was successful.
Otherwise it will throw an `ConnectionException` exception.

## Sending an event to the destination
In order to start working with the Event Sync, to send and listen to events, you need to create a subscription first.
Afterwards you can send a new event so it will be synced to the Cloud/Edge instance, SDK will utilize HTTP protocol to send events. 
Response will contain id of the posted event.

Use the `subscriber` instance to send events to destination.
If you would like to send event from edge to cloud, you should provide:
- event object;
- event name;
- target tenant's name.

If you would like to send an event from cloud to edge, you should provide:

- event object - the event itself you are trying to send to the destination;
- event name - name of your event, any arbitrary string. It is best to use it to map events during consumption;
- target tenant's name - to which tenant event will be sent;
- **destination id** - specify location id to which you would like to send an event.

```csharp
Guid eventId = await subscriber.SendEvent(new { EventName = "EventName" }, "nameOfTheEvent", "TenantName", new Guid("06e853d2-4dbe-442e-b17b-2e4e525acea9"));
```

As soon as event was sent, it will have `Acknowledged` status.

It is possible to register delegate using:
```csharp
public static IEventSyncConnectionBuilder WithEventStatusHandler(this IEventSyncConnectionBuilder? eventSyncConnectionBuilder, Func<EventStatusMessage, Task> statusHandler)
```
This delegate will be triggered, when event has reached destination and was consumed by subscriber.

**Possible statuses**:

- `Acknowledged` - message received by sync engine.
- `In transit` - message was sent to the destination but not yet delivered.
- `Delivered` - destination accepted an event.
- `Finished` - message delivery confirmed by the client. All related processes to the event are finished.
- `Subscriber is missing` - message was delivered to the destination but no active subscription was present to process the event.
- `Unknown` - Unknown message id / no status information.


## Receiving events

SDK utilizes [SignalR](https://docs.microsoft.com/en-us/aspnet/core/signalr/introduction?WT.mc_id=dotnet-35129-website&view=aspnetcore-6.0#what-is-signalr) for the consumption of events.

It is possible to register a delegate to handle incoming new events:
```csharp
public static IEventSyncConnectionBuilder WithEventHandler(this IEventSyncConnectionBuilder? eventSyncConnectionBuilder, Func<EventMessage, Task> newEventHandler, bool autoComplete = true)
```

`EventMessage` class represents an incoming event, it has following properties:

* EventId - Unique Event Id;
* EventContent - Serialized event body;
* EventName - Event name;
* CreatedOn - Date of when an event was created on a destination location;
* RegisteredOn - Date of when an event was registed on a source location;
* IsEventFromEdge - Represents whether event is from edge. If `false` then from Cloud/HQ;
* SourceLocationId - Source location id. If `null` then source is Cloud/HQ;
* TenantName - Tenant name to which belongs event.


## Demo
It is possible to post events from both Edge and Cloud instances and to receive from both Edge and Cloud instances.
Source code of the [demo app contains publishing event from Edge to Cloud](https://github.com/RemoteCloud/EventSync.SDK.Demo).
Demo uses [AppStore SDK](https://developer.maranics.com/dev/examples/app-store-sdk/) to pass an access token provider.


