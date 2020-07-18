local core = require("apisix.core")
local ngx = ngx

local plugin_name = "response-body"
local schema = {
    type = "object",
    properties = {
        key = {type = "string"},
    }
}

local _M = {
    version = 0.1,
    priority = 1000,
    type = 'var',
    name = plugin_name,
    schema = schema,
}


function _M.check_schema(conf)
    return core.schema.check(schema, conf)
end

function _M.body_filter(conf, ctx)
    core.log.info("response-body plugin filter phase, conf: ", core.json.delay_encode(conf))
    -- arg[1] contains a chunk of response content
    local resp_body = string.sub(ngx.arg[1], 1, 1000)
    ngx.ctx.buffered = string.sub((ngx.ctx.buffered or "") .. resp_body, 1, 1000)
    -- arg[2] is true if this is the last chunk
    if ngx.arg[2] then
      ngx.var.response_body = ngx.ctx.buffered
    end
end

return _M
