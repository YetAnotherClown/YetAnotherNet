---
sidebar_position: 2
---


# Other Setups

You can integrate Net into whatever game architecture you want by creating a Hook using ``Net.createHook({ Net })`` which is identical to the ``Net.start(loop, { Net })`` function. This function will return another function which you can call whenever you want to process your Routes' queues and send/receive your Packets on the Server or Client.

Below is a simple example of creating custom scheduling behavior using ``Net.createHook({ Net })``,
```lua
local RunService = game:GetService("RunService")

local Net = require("Net.luau")
local routes = require("routes.luau")

local hook = Net.createHook(routes)
RunService.Heartbeat:Connect(hook)
```