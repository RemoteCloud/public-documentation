title: Deployment Bundles

Deployment bundles represent a collection of all applications with a specific version. The specific app versions in a bundle are validated to play nice together. A bundle does not represent a complete list of applications that are deployed. Depending on the customer and use case only a subset of applications might be deployed. However when adding additional applications to a deployment they will use the version specified in the deployed bundle version.


## V1.0.0.0

Application     | Type     | Version
:-------------- | :------- | ------------:
User Management | App      | [v2.1.6.3][user-mgm-v2.1.6.3]
Launcher        | App      | [v1.1.0.5][launcher-v1.1.0.5]
Flow            | App      | [v2.6.1][flow-v2.6.1]
Template        | App      | [v2.6.1][template-v2.6.1]
Documentation   | App      | [v3.0.4.1][doc-v3.0.4.1]
Portal          | App      | [v2.1.0.8][portal-v2.1.0.8]
Barrier Model   | App      | [v2.1.1.7][barrier-model-v2.1.1.7]
Automation      | App      | [nightly][automation-nightly]
Data Register   | Service  | [v2.0.0.2][data-register-v2.0.0.2]
Monitoring      | Service  | [v1.0.0.2][monitor-v1.0.0.2]
Notifications   | Service  | [v1.0.1][notifications-v1.0.1]
PDF Generator   | Service  | [v2.1.0.6][pdf-generator-v2.1.0.6]
RemoteExecution | Service  | [v2.1.2.1][remote-exec-v2.1.2.1]
Sync            | Service  | [v1.2.1.0][sync-v1.2.1.0]

[user-mgm-v2.1.6.3]: ./apps/user-management.md#v2163
[launcher-v1.1.0.5]: ./apps/launcher.md#v1105
[flow-v2.6.1]: ./apps/flow.md#v261
[template-v2.6.1]: ./apps/template.md#v261
[doc-v3.0.4.1]: ./apps/documentation.md#v3041
[portal-v2.1.0.8]: ./apps/portal.md#v2108
[barrier-model-v2.1.1.7]: ./apps/barrier-model.md#v2117
[automation-nightly]: ./apps/automation.md#nightly

[data-register-v2.0.0.2]: ./services/data-register.md#v2002
[monitor-v1.0.0.2]: ./services/monitoring.md#v1002
[notifications-v1.0.1]: ./services/notifications.md#v101
[pdf-generator-v2.1.0.6]: ./services/pdf-generator.md#v2106
[remote-exec-v2.1.2.1]: ./services/remote-execution.md#v2121
[sync-v1.2.1.0]: ./services/sync.md#v1210