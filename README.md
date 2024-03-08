
<img src="gh-assets/logo.svg" alt="ty logo" align="left">
<img src="gh-assets/clearfloat.svg" alt="">
<h3>ty</h3>
<p>An experiment in static type inference for runtime type checking.</p>
<img src="gh-assets/clearfloat.svg" alt="">

-----

## Introduction

The aim of this library is to figure out whether it's possible to create a `t`-like typechecking library entirely within
strictly typed Luau, in a way which usefully cuts away redundant static types for values that are checked at runtime.

The prime use case for a library like this is network communications, where it's impossible to statically verify the
type of data coming in from the network. This data will always need to be checked at runtime. Historically, developers
would need to separately check all invariants hold, and then forcefully change the value to be of a useful static type.
Yet ideally, these steps would be unified, so the invariants being checked and the static types being returned always
stay in sync.

As far as I can tell, this is not possible today. *`ty` does not work.* This is largely because the Luau checker sucks
at dealing with generic type definitions, which `ty` would need to rely upon in order to get end-to-end type inference
working. While this is a blow, it's also a positive - because I have faith that Luau will eventually be powerful enough
to make `ty` work.

Just keep in mind that most of what you read here isn't functional, and probably won't be for the foreseeable future.
This is an aspirational library representing a vision of how something like `ty` should work.

## A note on dependencies

`ty` requires my own `Maybe` library to work. It's not that hard to implement; it's in the code block below.

<details>
<summary>Maybe.lua</summary>

```Lua
--!strict
--!nolint LocalShadow
-- Maybe - Non-throwing error values
-- By Elttob, MIT license

export type Some<Value> = {some: true, value: Value}
export type None = {some: false, reason: string?}
export type Maybe<Value> = Some<Value> | None

local Maybe = {}

function Maybe.Some<Value>(
	value: Value
): Some<Value>
	return {some = true, value = value}
end

function Maybe.None(
	reason: string?
): None
	return {some = false, reason = reason}
end

return Maybe
```

</details>

## Basic Usage

Similar to `t`, you construct type defintions by calling into `ty` functions. You can save this type definition to a
variable, so you can test against it later. Type definitions can also be nested in other type definitions, providing a
natural way to define custom named types.

```Lua
local NetworkPrimitive = ty.Or(
	ty.Or(
		ty.Or(
			ty.Number,
			ty.Boolean
		),
		ty.String
	),
	ty.Nil
)

local NetworkObject = ty.Or(
	ty.Or(
		NetworkPrimitive,
		ty.Array(NetworkPrimitive)
	),
	ty.MapOf(ty.String, NetworkPrimitive)
)
```

`ty` functions are also exposed as methods on type defition objects, so you can easily chain them for greater clarity.

```Lua
local NetworkPrimitive =
	ty.Number
	:Or(ty.Boolean)
	:Or(ty.String)
	:Or(ty.Nil)

local NetworkObject = 
	NetworkPrimitive
	:Or(NetworkPrimitive:Array())
	:Or(ty.String:MapOf(NetworkPrimitive))
```

To test whether a value fits a type definition, call the `:Matches()` method on the type definition.

```Lua
local valid = {
	number = 2,
	string = "foo",
	array = {1, 2, 3, 4, 5}
}
local invalid = os.time

print(NetworkObject:Matches(valid)) --> true
print(NetworkObject:Matches(invalid)) --> false
```

To convert a value into the correct static type, call the `:Cast()` method. This returns `Maybe<T>` where `T` is the
static type equivalent to the type definition you constructed.

```Lua
-- Defining static types that look like our definitions above...
type NetworkPrimitive = number | boolean | string | nil

type NetworkObject =
	NetworkPrimitive
	| {NetworkPrimitive}
	| {[string]: NetworkPrimitive}

-- Imagine this came in over the network, so we can't be sure what's inside.
local untrustedData: unknown = {
	number = 2,
	string = "foo",
	array = {1, 2, 3, 4, 5}
}

-- Returns the statically typed data we want, if it's safe to do so
local trustedData: Maybe<NetworkObject> = NetworkObject:Cast(untrustedData)

if trustedData.some then
	-- The data matches!
	print("Valid data!", trustedData.value)
else
	-- Something didn't line up with the type definition.
	warn("The data is not valid!", trustedData.reason)
end
```

## Helpful Members

If you don't want to deal with the `Maybe` type, `ty` can unwrap the error for you and throw it like a normal Lua error.
Try calling `:CastOrError()`.

```Lua
-- Returns the statically typed data we want, or errors if it can't
local trustedData: NetworkObject = NetworkObject:CastOrError(untrustedData)
print("Valid data!", trustedData.value)
```

You can access a human-readable description of what a type checks for via the `.ExpectsType` field. This description is
also used in error messages when failing to cast.

```Lua
print(NetworkPrimitive.ExpectsType) --> number | boolean | string | nil
```

Finish off a type with `:Nicknamed()` to customise how it appears in that human-readable description. This is especially
useful for deeply nested types, to ensure your output log stays intelligible.

```Lua
local NetworkPrimitive =
	ty.Number
	:Or(ty.Boolean)
	:Or(ty.String)
	:Or(ty.Nil)
	:Nicknamed("NetworkPrimitive")

local NetworkObject = 
	NetworkPrimitive
	:Or(NetworkPrimitive:Array())
	:Or(ty.String:MapOf(NetworkPrimitive))

print(NetworkPrimitive.ExpectsType) --> NetworkPrimitive
print(NetworkObject.ExpectsType)
	--> NetworkPrimitive | {NetworkPrimitive} | {[string]: NetworkPrimitive}
```

You can erase the static type parameter of a definition using `:Untyped()`, or redefine it using `:Retyped()` (bounding
the final type either by passing it into a specifically-typed location such as a function argument, or by coupling it
with `::` notation). This is only intended for getting around shortcomings in Luau's inference, and probably won't work
very well.

```Lua
local weirdStaticType = NetworkPrimitive:Retyped() :: ty.Def<number | string> 
local noStaticType = NetworkPrimitive:Untyped()
```

## Post processing

In the sprit of libraries like `serde`, there's some basic support for massaging data into a format more amenable to
static typing. Post processing is done by using various `:Into____()` methods, and only affects the value returned from
`:Cast()` and related methods like `:CastOrError()`.

You can add a `__tag` to any type using `:IntoTagged()`.

```Lua
local thing = ty.Number
local taggedThing = ty.Number:IntoTagged("jerry")

print(thing:CastOrError(5)) --> 5
print(taggedThing:CastOrError(5)) --> {__tag = "jerry", value = 5}
```

In particular, using `:Or()` on various `:IntoTagged()` types, you can join together ill-defined types into a
better-defined tagged union, which can aid with type inference.

```Lua
type Response = {
	__tag: "success",
	subject: string,
	body: string
} | {
	__tag: "fail",
	error: string
}

local Success = ty.Struct({
	subject: ty.String,
	body: ty.String
})
local Fail = ty.Struct({
	error: string
})
local Response = Success:IntoTagged("success"):Or(Fail:IntoTagged("fail"))

print(Response.ExpectsType)
	--> {subject: string, body: string} | {error: string}

local foo = Response:CastOrError({error = "Oh shit."})
print(foo)
	--> {__tag = "fail", error = "Oh shit."}
```

Data can be converted to a string using `:IntoString()`, or converted to a number using `:IntoNumber()`. Critically,
`:IntoNumber()` supports the same `base` parameter as `tonumber()`, meaning it can parse hexadecimal numbers directly.

```Lua
local UserInfo = ty.Struct({
	id = ty.Number:IntoString(),
	colourHexCode: ty.String:IntoNumber(16) -- parse as hexadecimal
})

local info = UserInfo:CastOrError({
	id = 123,
	colourHexCode = "FF"
})

print(info) --> {id = "123", colourHexCode = 255}
```

## Next steps

Besides making this library actually work with static types at all, there's a few other things that should be considered
for the future.

- Cyclic types are currently not supported, and you will probably hang your script if you give `ty` one . I imagine 
types would be acyclic by default (rejecting any tables that have already been encountered), but with an option to allow
cycles via a `:Cyclic()` method on the type definition. This would make `ty` valuable for type checking graph-like data.
- `ty` only really provisions for basic Lua types. Roblox types like `Vector3` and `Color3` are absent, but you can
still roughly type check them using `ty.Typeof()`.
- More post processing mechanisms, such as renaming fields or automatically converting capitalisation, would be highly
important for ensuring data can be comfortably worked with while respecting Lua's reserved keywords and coding
conventions.

I'm not planning to work on this too actively, given it seems impossible to fully reach the stated aims of the project
for the time being. I'm interested in keeping an eye on how things develop in the Luau world though.

If you work on Luau itself, or are interested in seeing what features of Luau might be worth expanding upon, feel free
to use `ty` as a point of reference in your work. I would be happy if it facilitated interesting discussions. Just maybe
don't take my written type definitions too seriously - they might be ludicrous!