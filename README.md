# Net
**[View Docs](https://yetanotherclown.github.io/Net/)**

> A Networking Library, inspired by BridgeNet2 & Bevy_Renet, made for ECS.

### WARNING

Net is an experimental library, expect bugs and major design changes. While the API
should remain the same, there is no guarantee.

### Networking on Roblox

Roblox promotes a design behavior where in order to achieve networking, developers must create
multiple RemoteEvents for each use. This leads to malpractice which results in issues with
organization and bandwidth.

Networking Modules and Libraries on Roblox strive to fix one of or both of these issues.
[Knit](https://sleitnick.github.io/Knit/) for example makes it easier to replicate data and removes the need to
make RemoteEvents (though they still exist). And [BridgeNet2](https://ffrostflame.github.io/BridgeNet2/) aims to eliminate the need to create
multiple RemoteEvents while also optimizing bandwidth.

These are great, except using a framework like Knit is, in most cases, detrimental to developer workflows, and with
BridgeNet2 and most other Networking Modules and Libraries, they are all flawed by nature, by promoting
Event-Driven code.

---

### A Data-Driven Networking Library

When making my switch to ECS, I realized there was no real simple way to handle Networking efficiently in [Matter](https://eryn.io/matter/).
Sure, we could use the ``useEvent`` function to use RemoteEvents in our code, but this was not efficient and was
detrimental to organization.

I liked the idea of using BridgeNet2 but I did not like the way it felt when using it in a ECS. So, I decided to
make my own Networking Library akin to BridgeNet2 but built for use in a ECS.

But why? Well, for some of the same [reasons to use a ECS](https://eryn.io/matter/docs/WhyECS), it felt
obvious to create and use a Data-Driven Networking Library as opposed to a Event-Driven Networking Library.

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
Net = "yetanotherclown/net@0.6.x"
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
