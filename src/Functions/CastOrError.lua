--!strict
-- ty - Experiments with static type inference for runtime type validation
-- By Elttob, MIT license

local Package = script.Parent.Parent.Parent
local Types = require(Package.ty.Types)

local CastOrError: Types.FnCastOrError = function(def, x)
	local result = def:Cast(x)
	if result.some then
		return result.value
	else
		error(`Could not cast {typeof(x)}: {result.reason}`)
	end
end

return CastOrError