<div align="center">
    <img alt="YetAnotherNet — A Data-Driven Networking Library, inspired by Bevy_Renet & BridgeNet2, made for ECS." src=".moonwave/static/Banner.svg">
</div>

## Quick Start

- [**Documentation**]
- [**Basic Use**]
- [**To-do**]
- **Getting Started**
    - [**Routes**]
    - [**Middleware**]
    - [**Hooks**]
- **Setup Guides**
    - [**Matter**]
    - [**Other**]
- **Installation**
    - [**Wally**]
    - [**NPM**]

[**Documentation**]: https://yetanotherclown.github.io/YetAnotherNet/
[**Basic Use**]: #basic-usage
[**To-do**]: #to-do
[**Routes**]: https://yetanotherclown.github.io/YetAnotherNet/docs/getting-started/routes
[**Middleware**]: https://yetanotherclown.github.io/YetAnotherNet/docs/getting-started/middleware
[**Hooks**]: https://yetanotherclown.github.io/YetAnotherNet/docs/getting-started/hooks
[**Matter**]: https://yetanotherclown.github.io/YetAnotherNet/docs/setup/matter
[**Other**]: https://yetanotherclown.github.io/YetAnotherNet/docs/setup/other
[**Wally**]: #wally
[**NPM**]: #npm-for-roblox-typescript

## About

YetAnotherNet is a Networking Library for Roblox, which wraps around Roblox's RemoteEvents to improve developer experience, offer efficient networking, and provide other tools, utilities, and features relating to Networking on Roblox.

### Features

- Complete Typechecking & Intellisense
- No Overhead from RemoteEvents
- Ordered Networking
- Middleware
- Data-Driven Design
- Simple Integration & API
- Hot-reloading Support with [Rewire]

[Rewire]: https://github.com/sayhisam1/Rewire

### Data-driven by design

One thing that separates YetAnotherNet from other networking libraries on Roblox is this key design choice. YetAnotherNet was made to work with ECS, a Data-driven approach to game design, which has influenced the design of the library largely and makes it unique from the rest.

With inspiration from [Bevy_Renet], a Networking crate for use with the Bevy ECS in Rust, and another networking library on Roblox, [BridgeNet2], YetAnotherNet pushes to provide similar functionality to these two libraries for ECS on Roblox.

[Bevy_Renet]: https://github.com/lucaspoffo/renet/tree/master/bevy_renet
[BridgeNet2]: https://ffrostflame.github.io/BridgeNet2/

#### Why go for Data-Driven Design?

Data-driven design opposes Event-driven design, which is what you can commonly see on Roblox, such as RemoteEvents themselves. Event-driven design has it's woes, which is why we opt for ECS and generally Data-driven design.

Event-driven design is sensitive to ordering, this makes it difficult to know when you might get data from an event. To solve this, YetAnotherNet does not use Events, it encourages you to query and send data in an ordered manner frame-by-frame, preferably with ECS.

Since it's encouraged to use ECS with YetAnotherNet, though not required, we suggest reading [Matter — Why ECS?] by Evaera.

[Matter — Why ECS?]: https://matter-ecs.github.io/matter/docs/WhyECS

---

## To-do

Tasks to complete before version 1.0.0 is released.

- [x] Basic Functionality
- [x] Stable Core API
- [x] Strict Typing
- [x] Unreliable Channel
- [X] Middleware
- [X] Typescript Support
- [ ] Unit + Integration Tests w/ Jest 
- [ ] Rate limiting
- [ ] Internal Use of Buffers
- [ ] Debugger

Other Tasks
- [ ] Minimal Example
- [ ] ECR Setup Guide
- [ ] ECR Example
- [ ] Docs Page for Technical Details

---

## Basic Usage

> [!TIP]
> See full documentation on [How to Use Routes] and [How to Setup with Matter] on the Documentation Site.

[How to Use Routes]: https://yetanotherclown.github.io/YetAnotherNet/docs/getting-started/routes
[How to Setup with Matter]: https://yetanotherclown.github.io/YetAnotherNet/docs/setup/matter

### Setup

Basic Setup for Routes
```lua
local Net = require("Net.luau")

local Route = Net.Route
type Route<U...> = Net.Route<U...>;

-- You can specify the type(s) between the <> for Typechecking + Intellisense
local ExampleRoute: Route<any> = Route.new()

return {
    ExampleRoute = ExampleRoute
}
```

### Example Use

Example of how to use YetAnotherNet in a [Matter] System
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

[Matter]: https://github.com/matter-ecs/matter

---

## Installation

### Wally

Add YetAnotherNet to your project with [Wally] by adding the following to your ``wally.toml`` file:
```toml
[dependencies]
Net = "yetanotherclown/yetanothernet@0.7.0"
```

> [!NOTE]
> Wally does not export types automatically, if you wish to use Strict Typing with YetAnotherNet, install [Wally Package Types] with Aftman.

[Wally]: https://github.com/UpliftGames/wally
[Wally Package Types]: https://github.com/JohnnyMorganz/wally-package-types

### NPM for Roblox Typescript

You can find YetAnotherNet on [NPM], or install it with the command line:

```
npm i @rbxts/yetanothernet
```

[NPM]: https://www.npmjs.com/package/@rbxts/yetanothernet

## Building

To build yourself with Rojo, use: 
```bash
rojo build -o "Net.rbxm"
```

For more help, check out [the Rojo documentation].

[the Rojo documentation]: https://rojo.space/docs