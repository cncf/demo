#!/bin/bash

# inspired by: https://github.com/BOINC/boinc/blob/master/lib/gui_rpc_client.cpp

NONCE=$(printf "<boinc_gui_rpc_request>\n<auth1/>\n</boinc_gui_rpc_request>\n\003" | nc localhost 31416)
AUTH=$(cat gui_rpc_auth.cfg)
HASH=$(echo "$NONCE$AUTH" | md5sum | awk '{print $1}')

printf "<boinc_gui_rpc_request>\n<auth2>\n<nonce_hash>$HASH</nonce_hash>\n</auth2>\n</boinc_gui_rpc_request>\n\003" | nc localhost 31416

: '
 Oh my word, so sometimes it responds a bit and if one insert a long enough delay here then it is possible to send to the rpc port:

<boinc_gui_rpc_request>
<get_results>
<active_only>0</active_only>
</get_results>
</boinc_gui_rpc_request>

IF and only IF all of this was part of the same tcp session. Ouch.
'
