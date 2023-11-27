---
sidebar_position: 1
---


# Sending Data

Data is sent through a queue each frame. The library will queue up all data sent through the ``Net:send()`` method
and send it through a RemoteEvent at the start of a new frame.

To send data using Net, you can use the ``Net:send()`` method. For example,
```lua
local MyIdentifier = identifiers.MyIdentifier
Net:send(MyIdentifier, ...)
```

## Identifiers & Data

In the ``Net:send()`` method, the first Parameter will always be your Identifier. Identifiers are of type ``Net.Identifier`` or ``string``.
You must supply an Identifier when sending data and it should always come before you provide your data.
It is recommended you use a ``Net.Identifier`` instead of a ``string``, see [Identifiers](handling-data/compressing-data.md#identifiers) for more.

Any other Parameters will be sent as data.

## Specifying Recipients

In order to specify who to send the data to, you must use the [SendRequest:to] method.

You can chain this onto ``Net:send()`` and pass in ``{ Player }``, ``Player``, or ``Net.Server``,
```lua
local Players = game:GetService("Players")

local MyIdentifier = identifiers.MyIdentifier

Net:send(MyIdentifier, ...):to(Players:GetPlayers())
```

By default, when you do not specify any recipients, it will always send to all players.