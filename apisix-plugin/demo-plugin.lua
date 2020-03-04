local core = require("apisix.core")

local plugin_name = "demo-plugin"

local schema = {
    type = "object",
    -- 这里是插件的属性, 详细参数可以参考其他其他插件
    properties = {
        a_fixed_string = { 
            type = "string"
        }, 
    },
}

local _M = {
    version = 0.1,
    priority = 10086,
    name = plugin_name,
    schema = schema,
}

-- 检查插件的定义是否有效
function _M.check_schema(conf)
    local ok, err = core.schema.check(schema, conf)

    if not ok then
        return false, err
    end

    return true
end

-- 插件的rewrite步骤, 步骤的顺序可以参考文档中的链接
function _M.rewrite(conf, ctx)
    -- 通过conf读取预设的参数
    core.log.warn("get a requert, fixed string: " .. conf.a_fixed_string)
    -- 解开下行的注释可以直接返回指定的请求
    -- return 500, { message = "we got a error" }
end

return _M
