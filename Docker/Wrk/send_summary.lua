local random = math.random

local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function init(args)

 -- print(args[0])

 wrk.path = wrk.path .. '&device_id=' .. uuid()
 -- TODO: write a proper add_query_parm function instead of appending at the end 

end

-- function response(status, headers, body)
   -- print(status)
   -- todo: keep seperate counts per status code
-- end

function done(summary, latency, requests)

      local msg = "echo 'metric_name %d' | curl -s -m3 --data-binary @- http://$PUSHGATEWAY:$PUSHGATEWAY_SERVICE_PORT/metrics/job/wrk/name/$podID/instance/$hostIP"
      local t = os.execute(msg:format(summary.requests))

end
