#!/usr/bin/env bash

cp /etc/config/frontend.js /opt/countly/frontend/express/config.js
chown -R countly:countly /opt/countly/frontend/express/config.js

exec /sbin/setuser countly /usr/bin/nodejs /opt/countly/frontend/express/app.js
