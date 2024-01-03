# Net
**[View Docs](https://yetanotherclown.github.io/Net/)**

> A Networking Library, inspired by BridgeNet2 & Bevy_Renet, made for ECS.

### WARNING

Net is an experimental library, expect bugs and major design changes. While the API
should remain the same, there is no guarantee.

## What is this?

Net is a networking library for Roblox, or rather its a library that wraps around Roblox's RemoteEvents to solve certain issues and provide new API for networking on Roblox.

Some of the issues this library solves are:
- Overhead from RemoteEvents
- Ordering of Networking Events
- Lack of Type-Checking and Intellisense for working with RemoteEvents

Net also provides several utilities:
- Middleware
- Strict Type-Checking & Auto-completion
- Simple integration with Hooks
- Data-driven Design

You can learn more about how Net works and how to use it by visiting [Getting Started with Routes](/docs/getting-started/routes). Or, you can keep reading to learn more about the technical details and design choices that went into creating Net.

## Data-driven by design

One thing that separates Net from other networking libraries on Roblox is this key design choice. Net was made to work with ECS, a Data-driven approach to game design, which has influenced the design of the library largely and makes it unique from the rest.

With inspiration from [Bevy_Renet](https://github.com/lucaspoffo/renet/tree/master/bevy_renet), a Networking crate for use with the Bevy ECS in Rust, and another networking library on Roblox, [BridgeNet2](https://ffrostflame.github.io/BridgeNet2/), Net pushes to provide similar functionality to these two libraries for ECS on Roblox.

### Why go for Data-driven?

Data-driven design opposes Event-driven design, which is what you can commonly see on Roblox, such as RemoteEvents themselves. Event-driven design has it's woes, which is why we opt for ECS and generally Data-driven design.

Event-driven design is sensitive to ordering, this makes it difficult to know when you might get data from an event. To solve this, Net does not use Events, it encourages you to query and send data in an ordered manner frame-by-frame, preferably with ECS.

Since it's encouraged to use ECS with Net, though not required, we suggest reading [Matter — Why ECS?](https://eryn.io/matter/docs/WhyECS) by Evaera.

---

### Basic Usage

In a [Matter](https://github.com/evaera/matter) System:
```lua
local routes = require("routes.luau")
local ExampleRoute = routes.ExampleOne

local function exampleSystem(world)
    -- Query through every networking call that frame on the Server
    for i, player, ...data in ExampleRoute:query() do
        -- Do something
    end

    -- Query through every networking call that frame on the Client
    for i, _, ...data in ExampleRoute:query() do
        -- Do something
    end

    -- Send data from the Client to the Server
    ExampleRoute:send(...)

    -- Send data to a Client from the Server
    ExampleRoute:send(...):to(Player)
end
```

---

### Installing with Wally

```toml
[dependencies]
Net = "yetanotherclown/net@0.7.x"
```

Note: Wally does not export types automatically, if you wish to use Strict Typing with Net, install [Wally Package Types](https://github.com/JohnnyMorganz/wally-package-types) with Aftman.

### Building with Rojo

To build yourself, use: 
```bash
rojo build -o "Net.rbxm"
```

For more help, check out [the Rojo documentation](https://rojo.space/docs).

## Todo for 1.0.0

- [x] Basic Functionality
- [x] Stable Core API
- [x] Strict Typing
- [x] Unreliable Channel
- [X] Middleware
- [ ] Void ``sender`` return argument when querying on the Client, with respect for Strict Typing
- [ ] Rate limiting
- [ ] Debugger

## Planned Features

- [ ] Internal Use of Buffers -- When released on Roblox
