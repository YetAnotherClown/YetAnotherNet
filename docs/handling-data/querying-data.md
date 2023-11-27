---
sidebar_position: 2
---


# Querying Data

To query data, you must iterate over it in a for loop.
To do this, you can either iterate over the [Net:query] method.

By using the [Net:query] method, the returned parameters will be: the position, the sender, the
identifier, and a tuple of the data.

:::tip
If you do not need to know the value of one of these parameters you can silence it by using ``_``.

For example, since we do not need to know the identifier:
```lua
local MyIdentifier = identifiers.MyIdentifier

for i, sender, _, args... in Net:query(MyIdentifier) do
    -- Retrieves all packets with the specified identifier
end
```
:::

## Filtering Identifiers

The [Net:query] method allows you to filter Identifiers by passing a tuple as an argument.
Supplying no Identifier will return all packets, otherwise only packets of the Identifier will
be returned.

```lua
local MyIdentifier = identifiers.MyIdentifier
local MyOtherIdentifier = identifiers.MyOtherIdentifier

for i, sender, identifier, args... in Net:query(MyIdentifier, MyOtherIdentifier) do
    -- Retrieves all packets with the specified identifiers
end
```

## Filtering Senders

Sometimes you may also want to filter by the sender. You can do this by chaining [QueryResult:from]
onto the [Net:query] method and pass a tuple of Senders as the argument.

Any of the following types are recognized as a sender:
```lua
{ Player } | Player | Net.Server
```

An example of this would be:
```lua
local Players = game:GetService("Players")

local MyIdentifier = identifiers.MyIdentifier

for i, sender, identifier, args... in Net:query(MyIdentifier):from(Players) do
    -- Retrieves all packets with the specified identifier and from the table of players
end
```