--!strict
--!nolint LocalShadow
-- ty - Experiments with static type inference for runtime type validation
-- Licensed by Elttob under MIT

local Package = script.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local methods: Types.Methods = {
	Typeof = require(Package.ty.Functions.Typeof),
	Just = require(Package.ty.Functions.Just),
	Optional = require(Package.ty.Functions.Optional),
	Or = require(Package.ty.Functions.Or),
	And = require(Package.ty.Functions.And),
	MapOf = require(Package.ty.Functions.MapOf),
	Array = require(Package.ty.Functions.Array),
	Struct = require(Package.ty.Functions.Struct),
	IntoTagged = require(Package.ty.Functions.IntoTagged),
	IntoString = require(Package.ty.Functions.IntoString),
	IntoNumber = require(Package.ty.Functions.IntoNumber),
	Retype = require(Package.ty.Functions.Retype),
	Untyped = require(Package.ty.Functions.Untyped),
	Nicknamed = require(Package.ty.Functions.Nicknamed),
	CastOrError = require(Package.ty.Functions.CastOrError)
}
Def.methodMeta.__index = methods

local constants: Types.Constants = {
	Unknown = Def.new(
		"unknown",
		function(self, x) return true end,
		function(self, x) return Maybe.Some(x) end
	),
	Never = Def.new(
		"never",
		function(self, x) return false end,
		function(self, x) return Maybe.None(self.NotOfTypeError) end
	),

	Number = methods.Typeof("number"),
	Boolean = methods.Typeof("boolean"),
	String = methods.Typeof("string"),
	Thread = methods.Typeof("thread"),
	Table = methods.Typeof("table"),
	Function = methods.Typeof("function"),
	
	True = methods.Just(true) :: any,
	False = methods.Just(false) :: any,
	Nil = methods.Just(nil)
}

local ty: Types.Methods & Types.Constants = setmetatable(constants, Def.methodMeta) :: any
return ty