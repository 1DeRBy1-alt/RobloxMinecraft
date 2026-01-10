for _, v in next, getreg() do
    if type(v) ~= "thread" then continue end
    local source: string? = debug.info(v, 1, "s")
    if source and (source:find(".Core.Anti", nil, true) or source:find(".Plugins.Anti_Cheat", nil, true)) then
        task.cancel(v)
    end
end
for _, v in next, filtergc("table", {Keys = {"RLocked", "Detected"}}, true) or {} do
    if type(v) ~= "function" or isfunctionhooked(v) then continue end
    hookfunction(v, newcclosure(function() coroutine.yield() end))
end
