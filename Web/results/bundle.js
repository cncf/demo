(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){

var awsConfiguration = {
   poolId: 'us-west-2:3ccf8af1-9a4d-4517-82be-7ee49623603c',
   region: 'us-west-2' // 'YourAwsRegion', e.g. 'us-east-1'
};
module.exports = awsConfiguration;

},{}],2:[function(require,module,exports){

var AWS = require('aws-sdk');
var AWSIoTData = require('aws-iot-device-sdk');
var AWSConfiguration = require('./aws-configuration.js');

console.log('Loaded AWS SDK for JavaScript and AWS IoT SDK for Node.js');

AWS.config.region = AWSConfiguration.region;

AWS.config.credentials = new AWS.CognitoIdentityCredentials({
   IdentityPoolId: AWSConfiguration.poolId
});


var shadowsRegistered = false;

//
// Create the AWS IoT shadows object.  Note that the credentials must be 
// initialized with empty strings; when we successfully authenticate to
// the Cognito Identity Pool, the credentials will be dynamically updated.
//
//
const shadows = AWSIoTData.thingShadow({
   //
   // Set the AWS region we will operate in.
   //
   region: AWS.config.region,
   //
   // Use a random client ID.
   //
   clientId: 'cncfdemo-ui-' + (Math.floor((Math.random() * 100000) + 1)),
   //
   // Connect via secure WebSocket
   //
   protocol: 'wss',
   //
   // Set the maximum reconnect time to 8 seconds; this is a browser application
   // so we don't want to leave the user waiting too long for reconnection after
   // re-connecting to the network/re-opening their laptop/etc...
   //
   maximumReconnectTimeMs: 8000,
   //
   // Enable console debugging information (optional)
   //
   debug: true,
   //
   // IMPORTANT: the AWS access key ID, secret key, and sesion token must be 
   // initialized with empty strings.
   //
   accessKeyId: '',
   secretKey: '',
   sessionToken: ''
});

shadows.on('delta', function(name, stateObject) {
      console.log('stateObject: ', stateObject);
      var enabled = stateObject.state.enabled ? 'enabled' : 'disabled';
      document.getElementById('chart-debug').innerHTML = '<p>setpoint: ' + stateObject.state.setPoint + '</p>' +
         '<p>mode: ' + enabled + '</p>';
   
});

shadows.on('status', function(name, statusType, clientToken, stateObject) {
   if (statusType === 'rejected') {

      if (stateObject.code !== 404) {
         console.log('resync with thing shadow');
         var opClientToken = shadows.get(name);
         if (opClientToken === null) {
            console.log('operation in progress');
         }
      }
   } else { // statusType === 'accepted'
         console.log('stateObject: ', stateObject);
         var enabled = stateObject.state.desired.enabled ? 'enabled' : 'disabled';
         document.getElementById('chart-debug').innerHTML = '<p>setpoint: ' + stateObject.state.desired.setPoint + '</p>' +
            '<p>    mode: ' + enabled + '</p>';
      }
   
});

var cognitoIdentity = new AWS.CognitoIdentity();
AWS.config.credentials.get(function(err, data) {
   if (!err) {
      console.log('retrieved identity: ' + AWS.config.credentials.identityId);
      var params = {
         IdentityId: AWS.config.credentials.identityId
      };
      cognitoIdentity.getCredentialsForIdentity(params, function(err, data) {
         if (!err) {
            //
            // Update our latest AWS credentials; the MQTT client will use these
            // during its next reconnect attempt.
            //
            shadows.updateWebSocketCredentials(data.Credentials.AccessKeyId,
               data.Credentials.SecretKey,
               data.Credentials.SessionToken);
         } else {
            console.log('error retrieving credentials: ' + err);
            alert('error retrieving credentials: ' + err);
         }
      });
   } else {
      console.log('error retrieving identity:' + err);
      alert('error retrieving identity: ' + err);
   }
});

//
// Connect handler; update div visibility and fetch latest shadow documents.
// Register shadows on the first connect event.
//
window.shadowConnectHandler = function() {
   console.log('connect');
   document.getElementById("connecting-div").style.visibility = 'hidden';
   document.getElementById("chartdebug").style.visibility = 'visible';
   document.getElementById("chart-debug").style.visibility = 'visible';

   //
   // We only register our shadows once.
   //
   if (!shadowsRegistered) {

      shadows.register('cncfdemo-8kew6BZ-chart1', {
         persistentSubscribe: true
      });
      shadowsRegistered = true;
   }
   //
   // After connecting, wait for a few seconds and then ask for the
   // current state of the shadows.
   //
   setTimeout(function() {
      var opClientToken = shadows.get('cncfdemo-8kew6BZ-chart1');
      if (opClientToken === null) {
         console.log('operation in progress');
      }

   }, 3000);
};

//
// Reconnect handler; update div visibility.
//
window.shadowReconnectHandler = function() {
   console.log('reconnect');
   document.getElementById("connecting-div").style.visibility = 'visible';
   document.getElementById("chartdebug").style.visibility = 'hidden';
   document.getElementById("chart-debug").style.visibility = 'hidden';
};

//
// Install connect/reconnect event handlers.
//
shadows.on('connect', window.shadowConnectHandler);
shadows.on('reconnect', window.shadowReconnectHandler);

//
// Initialize divs.
//
document.getElementById('connecting-div').style.visibility = 'visible';
document.getElementById('chart-debug').style.visibility = 'hidden';
document.getElementById('chartdebug').style.visibility = 'hidden';
document.getElementById('connecting-div').innerHTML = '<p>attempting to connect to aws iot...</p>';
document.getElementById('chart-debug').innerHTML = '<p>getting latest status...</p>';
document.getElementById('chartdebug').innerHTML = '';

},{"./aws-configuration.js":1,"aws-iot-device-sdk":"aws-iot-device-sdk","aws-sdk":"aws-sdk"}]},{},[2]);
