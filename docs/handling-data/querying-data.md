---
sidebar_position: 2
---


# Querying Data

To query data, you must iterate over it in a for loop.
To do this, you can either iterate over the Net object itself or use the ``Net:query()`` method.

By default, both of these options will return a tuple consisting of
``position, sender, identifier, args...``.

This may become a lot of values quickly, some of which you may not need. To solve this, you can pass in
specific Types into the ``Net:query()`` method to filter them out.

For example,
```lua
local MyIdentifier = identifiers.MyIdentifier

for i, sender, args... in Net:query(MyIdentifier) do
    -- Retrieves all packets with the specified identifier
end
```

This example only filters out the Identifier. We can also filter out by the Sender by adding
``{ Players }``, ``Player``, or ``Net.Server``.

```lua 
for i, args... in Net:query(YetAnotherClown, MyIdentifier) do
    -- Retrieves all packets from YetAnotherClown with the specified Identifier
end
```

Great, so we managed to filter out both our Sender and Identifier arguments. But what if we provide
multiple Identifiers or Players? When a table or tuple of Players, or a tuple of Identifiers is provided,
the iterator will return the sender and identifier respectfully as neither is known beforehand.

```lua
local MyIdentifier = identifiers.MyIdentifier
local MyOtherIdentifier = Identifiers.MyOtherIdentifier

for i, identifier, args... in Net:query(MyIdentifier, MyOtherIdentifier) do
    -- Retrieves all packets of the specified identifiers
end
```