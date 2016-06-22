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
 -- print(wrk.path)

 -- TODO: write a proper add_query_parm function instead of appending at the end 

end
