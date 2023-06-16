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

### Identifiers

Simply put, Identifiers are strings. You could simply just use a string when sending or querying data as your Identifier.
However, Net provides a function to compress strings into 2 bytes in order to optimize bandwidth.

To create a Identifier, use ``Net.identifier()``. For example,
```lua
local MyIdentifier = Net.identifier("myIdentifier")
```

For more information on Identifiers and compressing data, see the [Compressing Data](handling-data/compressing-data.md) page.

### Sending Data

To send data using Net, you can use the ``Net:send()`` method. For example,
```lua
local MyIdentifier = Net.identifier("myIdentifier")
Net:send(MyIdentifier, ...)
```

For more information on sending data, see the [Sending Data](handling-data/sending-data.md) page.

### Querying Data

To query data, you must iterate over it in a for loop.
To do this, you can either iterate over the Net object itself or use the ``Net:query()`` method.

By default, both of these options will return a tuple consisting of
``position, sender, identifier, args...``.

This may become a lot of values quickly, some of which you may not need. To solve this, you can pass in
specific Types into the ``Net:query()`` method to filter them out.

For example,
```lua
local MyIdentifier = Net.identifier("myIdentifier")

for i, sender, args... in Net:query(MyIdentifier) do
    -- Retrieves all packets with the specified identifier
end
```

For more information on querying data, see the [Querying Data](handling-data/querying-data.md) page.