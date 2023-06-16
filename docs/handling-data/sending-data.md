---
sidebar_position: 1
---


# Sending Data

Data is sent through a queue each frame. The library will queue up all data sent through the ``Net:send()`` method
and send it through a RemoteEvent at the start of a new frame.

To send data using Net, you can use the ``Net:send()`` method. For example,
```lua
local MyIdentifier = Net.identifier("myIdentifier")
Net:send(MyIdentifier, ...)
```

The first Parameter is an optional one specifying the recipient of the data. This Parameter can be an array of
Players; ``{ Players }``, a single ``Player``, or ``Net.Server``.

The second Parameter is required for sending data. It is a ``string`` of ``Net.Identifier`` or just a plain string.
It is recommended you use a ``Net.Identifier`` instead, see [Identifiers](handling-data/compressing-data.md#identifiers) for more.

Lastly, as a ``tuple``, any other parameter you provide after your Identifier will be sent as data.