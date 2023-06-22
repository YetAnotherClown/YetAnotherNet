"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[362],{64760:e=>{e.exports=JSON.parse('{"functions":[{"name":"__iter","desc":"Creates an iterator function that creates a snapshot and iterates over it; \\nfiltering out key-value pairs of the snapshot when a filter is provided, and filtering out \\nthe return results of the iterator function when a returnFilter is provided.\\n\\n```lua\\ntype FilteredResults = (\\n\\tpos: number?,\\n\\tsender: (Player | string)?,\\n\\tidentifier: Identifier?,\\n\\tpacketData: any?...\\n)\\n\\nNet:__iter(\\n\\tfilter: (\\n\\t\\tk: number,\\n\\t\\tv: any\\n\\t) -> (\\n\\t\\tnumber?,\\n\\t\\tany?\\n\\t)?,\\n\\treturnFilter: (\\n\\t\\tpos: number,\\n\\t\\tsender: (Player | string),\\n\\t\\tidentifier: string,\\n\\t\\tpacketData: {any}\\n\\t) -> FilteredResults\\n) -> () -> FilteredResults","params":[],"returns":[{"desc":"","lua_type":"(pos: number?, sender: (Player | string)?, identifier: string?, packetData: any?...)"}],"function_type":"method","tags":["Internal Use Only"],"private":true,"source":{"line":95,"path":"lib/init.luau"}},{"name":"query","desc":"Allows for iteration of all packets of the previous frame with support for QueryParameters.\\nQueryParameters can be ``Player``, ``{Players}``, or ``Identifier``.\\nWhen provided, related return values will not be returned.\\n\\nSee [Querying Data](https://yetanotherclown.github.io/Net/docs/querying-data) for more information.","params":[],"returns":[{"desc":"","lua_type":"() -> (pos: number, sender: (Player | string)?, identifier: (string)?, packetData: any...)"}],"function_type":"method","source":{"line":162,"path":"lib/init.luau"}},{"name":"send","desc":"Sends data to a recipient or the server if not specified under a unique identifier.\\n\\nSee [Sending Data](https://yetanotherclown.github.io/Net/docs/sending-data) for more information.","params":[],"returns":[],"function_type":"method","source":{"line":299,"path":"lib/init.luau"}},{"name":"start","desc":"Initializes your Net Server by scheduling it on your Matter Loop.\\nThis ensures that your netcode runs first every frame.\\n\\n:::note\\nPlease make sure that the event you set in the Configuration, or the default, is the same index you used for your ``RunService.Heartbeat`` event in your ``Loop:begin()`` method.\\n\\nYour netcode is meant to run on the heartbeat, like most systems. In some cases you may want to run your netcode on different events, in this case\\nit is acceptable to change it to a different event.\\nYou should have different Net objects for each event in this case.\\n:::\\n\\n:::warning\\nThe ``start`` method assumes your systems are ordered from ``0`` to ``inf``.\\nIf you have any systems that run on a priority below zero, you should either change your system\'s priority or manually set the priority in the Configuration.\\n\\nIf your netcode runs after any system, it may cause undesired behavior.\\n:::","params":[{"name":"loop","desc":"A Matter Loop","lua_type":"Loop"}],"returns":[],"function_type":"method","source":{"line":377,"path":"lib/init.luau"}},{"name":"new","desc":"Creates a new Net object with unique configuration.\\n\\n:::warning\\nYou should limit the amount of Net objects you create, each object runs on a separate RemoteEvent based on it\'s\\nChannel and Event. Net Objects with the same Channel and Event will run on the same RemoteEvent.\\nNet achieves it\'s performance gains by primarily reducing the overhead of RemoteEvent calls.\\n:::","params":[{"name":"configuration","desc":"","lua_type":"Configuration?"}],"returns":[],"function_type":"static","source":{"line":405,"path":"lib/init.luau"}}],"properties":[],"types":[{"name":"Configuration","desc":"As of v0.2.0, the only two configuration parameters that are implemented are Event and Priority.\\nAll other parameters will be implemented at a later date. With the exception of Middleware & Ratelimiting,\\nmost of these parameters should not change and remain stable API.\\n\\n### Channel\\n\\n**ReliableOrdered**: Ensures the order in which Packets were sent at the cost of a few bytes. It is not recommended\\nthat this is used. In most cases, ``ReliableUnordered`` should work.\\n\\n**ReliableUnordered**: Does not ensure the order in which Packets are sent. However, Packets will be ordered properly\\nper Identifier only. This should work in most cases and does not have any overhead.\\n\\n**Unreliable**: Anticipated feature that Roblox may add, this is here for planning and is not yet available.","fields":[{"name":"Channel","lua_type":"\\"ReliableOrdered\\" | \\"ReliableUnordered\\" | \\"Unreliable\\"","desc":"Default: ReliableUnordered"},{"name":"DebugMode","lua_type":"boolean","desc":"Enable Debug Features?"},{"name":"DebugKey","lua_type":"KeyCode","desc":"The key to open the Debug Panel"},{"name":"Event","lua_type":"string","desc":"The event to schedule Net on in your Matter Loop -- Default: \\"default\\""},{"name":"Middleware","lua_type":"(sender, identifier, ...) -> any","desc":"Ran before a packet is queried"},{"name":"Priority","lua_type":"number","desc":"The priority to schedule Net as in your Matter Loop -- Default: -1"},{"name":"Ratelimit","lua_type":"number","desc":"Amount of allowed invocations a frame"}],"tags":["Future Feature"],"source":{"line":36,"path":"lib/init.luau"}}],"name":"Net","desc":"A Networking Library, inspired by BridgeNet2 & Bevy_Renet, made for ECS.\\n\\nSee the [Intro](https://yetanotherclown.github.io/Net/docs/intro) to get started.","source":{"line":53,"path":"lib/init.luau"}}')}}]);