local function loadFeature(mod, relative)
local source = assert(mod:read(relative))
local chunk = assert(loadstring(source, "@" .. relative))
local install = assert(chunk())
install(mod)
end

return function(mod)
loadFeature(mod, "features/bindings.lua")
loadFeature(mod, "features/options.lua")
loadFeature(mod, "features/autofire.lua")

mod.log:info("Turbo initialized")
end
