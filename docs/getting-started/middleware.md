---
sidebar_position: 2
---


# Middleware

Middleware is a powerful feature of Net that allows you to validate types and serialize/deserialize data before it is processed when sending and receiving data.

To create Middleware, you can specify a function in your Route's Configuration with a parameter for the event `"send" | "receive"` and the data that is to be processed `U...`.

```lua
local Net = require("Net.luau")
type Net<U...> = Net.Net<U...>

local Route: Net<number, string, boolean> = Net.new({
    Middleware = function(event, num, str, bool)
        -- Do something

        return num, str, bool
    end
})
```

To validate your types, you can return the values in order to allow it to be processed, or you can drop the packet by returning `nil`. Dropped packets will never reach your code, meaning you can ensure that the types your code receives are always the types you expect.

## Compression

To compress/decompress your data, you can use a library like [Squash](https://github.com/Data-Oriented-House/Squash) to serialize and deserialize your data. Simply return the types in order as a tuple, you can use the event parameter to determine whether to compress or decompress your data.

```lua
local Squash = require("Squash.luau")
local Net = require("Net.luau")
type Net<U...> = Net.Net<U...>

local route: Net<string, number> = Net.new({
    Channel = "Reliable",
    Middleware = function(event: "send" | "receive", str, boolean)
        local values: { any } = {}
        local alphabet = Squash.string.alphabet(str)

        -- Serialize Packets before sending
        if event == "send" then
            -- Type-check sent values,
        	-- Should be of the provided types U... in Net<U...>
            if type(str) ~= "string" or type(boolean) ~= "boolean" then
                return
            end

            values = {
                Squash.string.ser(str, alphabet),
                Squash.boolean.ser(boolean),
            }
        end

        -- Deserialize Packets before returning
        if event == "receive" then
            -- Type-check returned values;
        	-- Squash serializes types into other types, like string
            if type(str) ~= "string" or type(boolean) ~= "string" then
                return
            end

            values = {
                Squash.string.des(str, alphabet),
                Squash.boolean.des(boolean),
            }
        end

        return table.unpack(values)
    end,
})
```