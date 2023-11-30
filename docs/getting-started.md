---
sidebar_position: 2
---

# Getting Started

:::tip
Check out the adapted version of the Matter Example game to see how it's used in a real game.

See all of Net's [example projects](https://github.com/YetAnotherClown/Net/tree/main/examples) in the repository.
:::

### Setting up with Matter

Being made for the Matter ECS, Net provides a simple method for scheduling your Routes to run
on your Matter Loop.

Firstly, create a ``routes.luau`` ModuleScript in ReplicatedStorage to strictly declare your Routes.

```lua title="routes.luau"
local Net = require("Net.luau")
type Net<U...> = Net.Net<U...>

local defaultConfiguration = {
  Channel = "Reliable",
  Event = "default",
}

-- Payload for replicating Entities
type EntityPayload = {
    [string]: { -- EntityId
        [string]: { -- Component name
            data: ComponentInstance<T>
        }
    }
}

-- Replicate Matter Components
local MatterReplication: Net<EntityPayload> = Net.new(defaultConfiguration)

-- Signal that the Player has loaded
local PlayerLoaded: Net<boolean> = Net.new(defaultConfiguration)

return {
  MatterReplication = MatterReplication,
  PlayerLoaded = PlayerLoaded,
}
```

And now in the same script where you create your Matter Loop, you can run the ``Net.start({ Net })``
function to schedule your Routes to run on Matter's Middleware.

```lua title="init.server.luau / init.client.luau"
local Matter = require("Matter.luau")
local World = Matter.World
local Loop = Matter.Loop

local Net = require("Net.luau")
local routes = require("routes.luau")

local world = World.new()
local loop = Loop.new(world, net)

-- Schedules your Routes
Net.start(loop, routes)

local systems = {}
for _, child in script.systems:GetChildren() do
    if child:IsA("ModuleScript") then
        table.insert(systems, require(child))
    end
end

loop:scheduleSystems(systems) -- Schedule systems after running ``Net.start()``

-- Begin the loop and make sure the ``Event`` key in your Routes configuration are added here
loop:begin({
    default = RunService.Heartbeat
})
```

Finally, in a Matter System we can use our ``routes.luau`` ModuleScript to access our Routes and
use them within our Systems.

```lua title="systems/exampleSystem.luau"
local routes = require("routes.luau")
local PlayerLoaded = routes.PlayerLoaded

local function exampleSystem(world)
    -- Query through every networking call that frame on the Server
    for i, player, ...data in PlayerLoaded:query() do
        -- Do something
    end

    -- Query through every networking call that frame on the Client
    for i, _, ...data in PlayerLoaded:query() do
        -- Do something
    end

    -- Send data from the Client to the Server
    PlayerLoaded:send(...)

    -- Send data to a Client from the Server
    PlayerLoaded:send(...):to(Player)
end
```

### Other Setups

Is Matter not for you? It is possible to use Net outside of Matter by creating a Hook using ``Net.createHook({ Net })``
which is identical to the ``Net.start(loop, { Net })`` function. This function will return another function which you can
call whenever you want to process your Routes' queues and send/receive your Packets on the Server or Client.

Below is a simple example of creating custom scheduling behavior using ``Net.createHook({ Net })``,
```lua
local RunService = game:GetService("RunService")

local Net = require("Net.luau")
local routes = require("routes.luau")

local hook = Net.createHook({ routes })
RunService.Heartbeat:Connect(hook)
```