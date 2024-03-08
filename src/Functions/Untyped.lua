--!strict
--!nolint LocalShadow
-- ty - Experiments with static type inference for runtime type validation
-- By Elttob, MIT license

local Package = script.Parent.Parent.Parent
local Types = require(Package.ty.Types)

local Untyped: Types.FnUntyped = function(def)
	return def
end

return Untyped