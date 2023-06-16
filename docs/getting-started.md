---
sidebar_position: 2
---

# Getting Started

### Setting up with Matter

Being made for the Matter ECS, Net provides a simple method for scheduling the Netcode to run
on your Matter Loop.

Firstly, similar to how you would setup your components with Matter, create a ``identifiers.luau`` ModuleScript
to strictly declare your Net identifiers. Identifiers are global and should be the first thing you make when
using the Net library.

```lua title="identifiers.luau"
local Net = require(Net)

local identifiers = {
  ["ExampleOne"] = Net.identifier("ExampleOne"),
  ["ExampleTwo"] = Net.identifier("ExampleTwo")
}
-- Laid out for strict typing

return identifiers
```

And then in the same script you initialize your Matter Systems, you can create a new Net object
with unique configuration by using the ``Net.new()`` function.

In order to use Net with Matter you must also use the ``Net:start()`` method and pass in your Matter
loop and the name of the event to run on. The event should be Heartbeat.

You should have only one Net object for every loop, though you shouldn't, in most cases, have more than one
loop.

```lua title="init.server.luau / init.client.luau"
local Matter = require(Matter)
local World = Matter.World
local Loop = Matter.Loop

local NetLib = require(Net)

-- Create a new Net Server/Client
local Net = NetLib.new({
  Channel: ReliableOrdered | ReliableUnordered | Unreliable, -- Future proofing
  DebugMode: boolean -- Tools for debugging
  DebugKey: KeyCode -- Future addition for a Debug Panel
  Middleware: (sender, identifier, ...) -> any -- Ran before a packet is queried
  RateLimit: number -- Amount of invocations a second
})

-- Create your identifiers before initializing any netcode
local identifiers = require("Identifiers.lua")

local world = World.new()
local loop = Loop.new(world, Net)

Net:start(loop, "default") -- Initializes the net, adding it to your loop.

local systems = {}
for _, child in script.systems:GetChildren() do
    if child:IsA("ModuleScript") then
        table.insert(systems, require(child))
    end
end

loop:scheduleSystems(systems) -- Schedule systems after running Net:start()

-- Begin the loop and make sure the eventName string you passed into Net:start() is in the event table
loop:begin({
    default = RunService.Heartbeat
})
```

Finally, in a Matter System we can use our ``identifiers.luau`` ModuleScript to access our Identifiers and
use them within our System.

And, because we passed in our Net object into our Loop, we can use it in any of our Systems. We can send data
using ``Net:send()`` and query it using ``Net:query()``.

```lua title="systems/exampleSystem.luau"
local identifiers = require("identifier.luau")
local ExampleIdentifier = identifiers.ExampleOne

local function exampleSystem(world, net)
    -- Query through every networking call that frame from Clients
    for i, player, args... in net:query(ExampleIdentifier) do
        -- Do something
    end

    -- Query through every networking call that frame from the Server
    for i, args... in net:query(ExampleIdentifier) do
        -- Do something
    end

    -- Send data from the Client to the Server
    net:send(ExampleIdentifier, ...)

    -- Send data to a Client from the Server
    net:send(Player, ExampleIdentifier, ...)
end
```

### Other Setups

Is Matter not for you? It is possible to use Net outside of Matter by bypassing the ``Net:start()`` method and
scheduling it with your own code using the internal mechanics of your Net object's ``Bridge``.

Please note that if you aren't using Net within an ECS it is strongly discouraged that you use it. You should
consider using alternatives like BridgeNet2.

Below is a simple example of creating custom scheduling behavior using ``Bridge:step()``.

```lua
local RunService = game:GetService("RunService")

local NetLib = require(Net)

-- Create a new Net Server/Client
local Net = NetLib.new({
  Channel: ReliableOrdered | ReliableUnordered | Unreliable, -- Future proofing
  DebugMode: boolean -- Tools for debugging
  DebugKey: KeyCode -- Future addition for a Debug Panel
  Middleware: (sender, identifier, ...) -> any -- Ran before a packet is queried
  RateLimit: number -- Amount of invocations a second
})

-- Create your identifiers before initializing any netcode
local identifiers = require("Identifiers.lua")

RunService.Heartbeat:Connect(function()
    Net._bridge:step() -- The Bridge:step() method processes the incoming and outgoing queues
end)
```

For more information on this, see the [Bridge API](https://yetanotherclown.github.io/Net/api/Bridge).