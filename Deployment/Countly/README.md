# Countly Demo Application
Countly is an open source web & mobile analytics and marketing platform. It provides insights about user actions.

## Configuration Files
Two configuration files used to dictate the behavior of this demo application are [api.js] (configMaps/countly/api.js) and [frontend.js] (configMaps/countly/frontend.js). Each configuration file contains only one change from the default configurationonly line changed from the default config:

  `Host: "mongos:default"`

By setting `Host` to "mongos.default", the Countly application looks for its MongoDB servers at the address "mongos.default". The "mongos.default" reference resolves to a Kubernetes service called mongos. The .default namespace is the default top-level domain for pods and services deployed in Kubernetes.
