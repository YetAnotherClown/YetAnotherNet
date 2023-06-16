"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[362],{64760:e=>{e.exports=JSON.parse('{"functions":[{"name":"__iter","desc":"Creates an iterator function that creates a snapshot and iterates over it; \\nfiltering out key-value pairs of the snapshot when a filter is provided, and filtering out \\nthe return results of the iterator function when a returnFilter is provided.\\n\\n```lua\\ntype FilteredResults = (\\n\\tpos: number?,\\n\\tsender: (Player | string)?,\\n\\tidentifier: Identifier?,\\n\\tpacketData: any?...\\n)\\n\\nNet:__iter(\\n\\tfilter: (\\n\\t\\tk: number,\\n\\t\\tv: any\\n\\t) -> (\\n\\t\\tnumber?,\\n\\t\\tany?\\n\\t)?,\\n\\treturnFilter: (\\n\\t\\tpos: number,\\n\\t\\tsender: (Player | string),\\n\\t\\tidentifier: string,\\n\\t\\tpacketData: {any}\\n\\t) -> FilteredResults\\n) -> () -> FilteredResults","params":[],"returns":[{"desc":"","lua_type":"(pos: number?, sender: (Player | string)?, identifier: string?, packetData: any?...)"}],"function_type":"method","tags":["Internal Use Only"],"private":true,"source":{"line":79,"path":"lib/init.luau"}},{"name":"query","desc":"Allows for iteration of all packets of the previous frame with support for QueryParameters.\\nQueryParameters can be ``Player``, ``{Players}``, or ``Identifier``.\\nWhen provided, related return values will not be returned.\\n\\nSee [Querying Data](https://yetanotherclown.github.io/Net/docs/querying-data) for more information.","params":[],"returns":[{"desc":"","lua_type":"() -> (pos: number, sender: (Player | string)?, identifier: (string)?, packetData: any...)"}],"function_type":"method","source":{"line":146,"path":"lib/init.luau"}},{"name":"send","desc":"Sends data to a recipient or the server if not specified under a unique identifier.\\n\\nSee [Sending Data](https://yetanotherclown.github.io/Net/docs/sending-data) for more information.","params":[],"returns":[],"function_type":"method","source":{"line":283,"path":"lib/init.luau"}},{"name":"start","desc":"Initializes your Net Server by scheduling it on your Matter Loop.\\nThis ensures that your netcode runs first every frame.\\n\\n:::note\\nPlease make sure that the event you provided is the same index you used for your ``RunService.Heartbeat`` event in your ``Loop:begin()`` method.\\n\\nYour netcode is meant to run on the heartbeat, like most systems. In some cases you may want to run your netcode on different events, in this case\\nit is acceptable to change it to a different event.\\nYou should have different netcodes for each event in this case.\\n:::\\n\\n:::warning\\nThe ``start`` method assumes your systems are ordered from ``0`` to ``inf``.\\nIf you have any systems that run on a priority below zero, you should either change your system\'s priority or manually set the priority in the ``start`` method.\\n\\nIf your netcode runs after any system, it may cause undesired behavior.\\n:::","params":[{"name":"loop","desc":"An optional First Parameter that specifies a recipient of Player, { Player }, or ``Net.Server``. If not specified, the packet will be sent to the server.","lua_type":"Loop"},{"name":"event","desc":"The Index of the Event you want Net to use in your ``Loop:begin()`` method.","lua_type":"string"},{"name":"priorityOverride","desc":"A optional override for the priority of the Net System/","lua_type":"number"}],"returns":[],"function_type":"method","source":{"line":363,"path":"lib/init.luau"}},{"name":"new","desc":"Creates a new Net object with unique configuration.\\n\\n:::warning\\nYou should limit the amount of Net objects you create, each object runs on a separate RemoteEvent.\\nNet achieves it\'s performance gains by primarily reducing the overhead of RemoteEvent calls.\\n:::","params":[{"name":"configuration","desc":"","lua_type":"Configuration?"}],"returns":[],"function_type":"static","source":{"line":390,"path":"lib/init.luau"}}],"properties":[],"types":[{"name":"Configuration","desc":"As of v0.1.0, none of these are implemented. All are planned and will be implemented in later versions.","fields":[{"name":"Channel","lua_type":"\\"Reliable\\" | \\"Unreliable\\"","desc":"Default: Reliable"},{"name":"DebugMode","lua_type":"boolean","desc":"Enable Debug Features?"},{"name":"DebugKey","lua_type":"KeyCode","desc":"The key to open the Debug Panel"},{"name":"Middleware","lua_type":"(sender, identifier, ...) -> any","desc":"Ran before a packet is queried"},{"name":"Ratelimit","lua_type":"number","desc":"Amount of allowed invocations a frame"}],"tags":["Future Feature"],"source":{"line":22,"path":"lib/init.luau"}}],"name":"Net","desc":"A Networking Library, inspired by BridgeNet2 & Bevy_Renet, made for ECS.\\n\\nSee the [Intro](https://yetanotherclown.github.io/Net/docs/intro) to get started.","source":{"line":37,"path":"lib/init.luau"}}')}}]);