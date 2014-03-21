local json = config.json

return {
  handler = function(context)
    context.response.headers["content-type"] = "application/json"

    local output = context.output
    local meta = getmetatable(output)

    if meta and type(meta.__toView) == "function" then
      output = meta.__toView(output, context)
    end

    local raw
    if config.encodeEmptyTableAsArray and next(output) == nil then
      raw = "[]"
    else
      raw = json.encode(output)
    end

    context.response.send(raw)
  end,

  options = {
    predicate = function(context)

      if context.output == nil then
        return false
      end

      if config.default then
        return true
      end

      local accept = context.request.headers.accept
      local content = context.request.headers["content-type"]

      return (accept and (accept:find("application/json") or accept:find("*/*"))) or
             (content and content:find("application/json") and not accept)
    end
  }
}
