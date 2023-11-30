---
sidebar_position: 1
---


# Net

## Core Concepts

### A brief introduction to Event-Driven Programming

On Roblox, it is all too common. With the use of Signals, you can represent changes in state
with and react to those changes with connections. A lot of how you interact with the DataModel
and it's properties is through Events, this makes Roblox primarily Event-Driven.

By making Roblox Event-Driven, this is where Roblox both succeeds and fails. They make things
extremely simple for newcomers, but create issues for more experienced programmers. The biggest issue
is that Event-Driven Programming fails when it comes to ordering. Failing to know when your code
will run creates several issues later on.

### A introduction to Data-Driven Programming

In a Data-Driven Architecture, Code runs in a fixed order, enabling developers to know exactly when
something may change. This is something that [Matter](https://eryn.io/matter/), a ECS System, strives to
fix, and does a great job doing so.

In Matter, it exists ways to incorporate a Data-Driven design to Event-Driven objects such as RemoteEvents
on Roblox. It enables us to respond to Events and fire them in a fixed order. But we can do better.

## An Introduction to Net

### Why Net?

The Core issue of using RemoteEvents are the following:
- Event-Driven Code is sensitive to ordering
- Developers must create multiple RemoteEvents..
- ..Which is detrimental to organization
- And, results in inefficient networking practices

Matter alone fixes the first issue, but with Net you can fix them all.
Net abstracts away the need to create multiple RemoteEvents and applies networking tricks
to optimize bandwidth at the same time. Like [BridgeNet2](https://ffrostflame.github.io/BridgeNet2/), Net utilizes a singular
RemoteEvent and structures Data to send the least amount of bytes over networking calls.

And with inspiration from the [Bevy_Renet](https://github.com/lucaspoffo/renet/tree/master/bevy_renet) Crate and Matter itself,
Net provides a effective API to use within an ECS.

### Creating Routes

Routes are the way you send and receive data through Net. They are uniquely identified so you're
encouraged to create as many as you need as if you were creating individual RemoteEvents.

Routes can be Reliable or Unreliable. Reliable events are never dropped and are always in order per frame.
Unreliable events might be dropped on bad connections, but they are always received in order per frame.

You can also strictly type Routes to get autocompletion and typechecking when Sending and Querying packets.

To create a Route, you can use ``Net.new()``
```lua
local Net = require("Net.luau")
type Net<U...> = Net.Net<U...>

local PlayerLoaded: Net<boolean> = Net.new({
    Channel = "Reliable"
})
```

### Sending Data

To send data using Net, you can use the ``Net:send()`` method. For example,
```lua
local routes = require("routes.luau")
local PlayerLoaded = routes.PlayerLoaded

PlayerLoaded:send(true)
```

On the Server, you can also specify a player or players to send the packet to,
```lua
local routes = require("routes.luau")
local PlayerLoaded = routes.PlayerLoaded

PlayerLoaded:send(true):to(Player)
```

### Querying Data

To query data, you must iterate over it in a for loop.
To do this, you can either iterate over the Route itself or use the ``Net:query()`` method.

For example,
```lua
local routes = require("routes.luau")
local PlayerLoaded = routes.PlayerLoaded

for i, sender, ...data in PlayerLoaded:query() do
    -- Retrieves all packets from the Route
end
```

And you can query by sender,
```lua
local routes = require("routes.luau")
local PlayerLoaded = Routes.PlayerLoaded

for i, _, ...data in PlayerLoaded:query():from(Player) do
    -- Retrieves all packets from the Route send by the Player
end
```