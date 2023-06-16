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

In the ``Net:send()`` method, the first Parameters you provide should be the Recipients of your packet.
These can be of types ``{ Players }`` or ``Player`` if called from the Server, or ``Net.Server`` if called from the client.
If you call from the client, you do not have to provide a Recipient Parameter.

The next Parameter after your Recipients should be an Identifier. Identifiers are of type ``Net.Identifier`` or ``string``.
You must supply an Identifier when sending data and it should always come before you provide your data.
It is recommended you use a ``Net.Identifier`` instead of a ``string``, see [Identifiers](handling-data/compressing-data.md#identifiers) for more.

Any other Parameters will be sent as data.