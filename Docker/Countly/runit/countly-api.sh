#!/usr/bin/env bash

cp /etc/config/api.js /opt/countly/api/config.js
chown countly:countly /opt/countly/api/config.js

exec /sbin/setuser countly /usr/bin/nodejs /opt/countly/api/api.js
