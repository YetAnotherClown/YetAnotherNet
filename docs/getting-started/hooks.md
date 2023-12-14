---
sidebar_position: 3
---


# Hooks

Hooks allow you to integrate Net into any game architecture you want. These are simply functions that you can call whenever you want to process your Packets. It's recommended that you set your hooks to run on the Heartbeat using `RunService.Heartbeat`, so your Networking Code can be scheduled to run frame-by-frame as Net was designed to do.

To create a hook, you can use ``Net.createHook({ Net })`` and pass in a table of your Routes, then you can call it whenever you want to process your packets.

```lua
local RunService = game:GetService("RunService")

local Net = require("Net.luau")
local routes = require("routes.luau")

local hook = Net.createHook(routes)
RunService.Heartbeat:Connect(hook)
```