---
sidebar_position: 3
---


# Compressing Data

## Why it matters

We live in a highly technologically advanced world today, despite this many households still have a subpar internet connection.
Because of this, clients can only send and receive a limited amount of data in a given time frame.
To ease this issue, we as programmers can optimize and reduce how much data we send over the internet, allowing for our
players to spend more time playing and less time waiting for things to load.

## Identifiers

Simply put, Identifiers are strings. You could simply just use a string when sending or querying data as your Identifier.
However, Net provides a function to compress strings into 2 bytes in order to optimize bandwidth.

To create a Identifier, use ``Net.identifier()``. For example,
```lua
local MyIdentifier = Net.identifier("myIdentifier")
```

For more technical details on how Identifiers work, Identifiers are stored in a global table and are packed using ``string.pack()``
based on the position in which they are being packed. The global table looks something like:

```lua
local identifiers = {
    [Index] = PackedString
}
```

Where ``Index`` is the string passed through the function and the ``PackedString`` is the return of running it through
``string.pack("B", pos)``. Because of the nature of this, and the design choice to promote strictly declared identifiers,
creating identifiers dynamically after running any ``Net:start()`` may result in incorrect identifiers between the
client and server.