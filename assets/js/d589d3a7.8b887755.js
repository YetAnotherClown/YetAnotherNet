"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[162],{3905:(e,t,n)=>{n.d(t,{Zo:()=>d,kt:()=>h});var r=n(67294);function i(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function a(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function o(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?a(Object(n),!0).forEach((function(t){i(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):a(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function l(e,t){if(null==e)return{};var n,r,i=function(e,t){if(null==e)return{};var n,r,i={},a=Object.keys(e);for(r=0;r<a.length;r++)n=a[r],t.indexOf(n)>=0||(i[n]=e[n]);return i}(e,t);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);for(r=0;r<a.length;r++)n=a[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(i[n]=e[n])}return i}var s=r.createContext({}),u=function(e){var t=r.useContext(s),n=t;return e&&(n="function"==typeof e?e(t):o(o({},t),e)),n},d=function(e){var t=u(e.components);return r.createElement(s.Provider,{value:t},e.children)},p="mdxType",c={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},m=r.forwardRef((function(e,t){var n=e.components,i=e.mdxType,a=e.originalType,s=e.parentName,d=l(e,["components","mdxType","originalType","parentName"]),p=u(n),m=i,h=p["".concat(s,".").concat(m)]||p[m]||c[m]||a;return n?r.createElement(h,o(o({ref:t},d),{},{components:n})):r.createElement(h,o({ref:t},d))}));function h(e,t){var n=arguments,i=t&&t.mdxType;if("string"==typeof e||i){var a=n.length,o=new Array(a);o[0]=m;var l={};for(var s in t)hasOwnProperty.call(t,s)&&(l[s]=t[s]);l.originalType=e,l[p]="string"==typeof e?e:i,o[1]=l;for(var u=2;u<a;u++)o[u]=n[u];return r.createElement.apply(null,o)}return r.createElement.apply(null,n)}m.displayName="MDXCreateElement"},99390:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>s,contentTitle:()=>o,default:()=>c,frontMatter:()=>a,metadata:()=>l,toc:()=>u});var r=n(87462),i=(n(67294),n(3905));const a={sidebar_position:2},o="Getting Started",l={unversionedId:"getting-started",id:"getting-started",title:"Getting Started",description:"Check out the adapted version of the Matter Example game to see how it's used in a real game.",source:"@site/docs/getting-started.md",sourceDirName:".",slug:"/getting-started",permalink:"/Net/docs/getting-started",draft:!1,editUrl:"https://github.com/YetAnotherClown/Net/edit/main/docs/getting-started.md",tags:[],version:"current",sidebarPosition:2,frontMatter:{sidebar_position:2},sidebar:"defaultSidebar",previous:{title:"Net",permalink:"/Net/docs/intro"},next:{title:"Sending Data",permalink:"/Net/docs/handling-data/sending-data"}},s={},u=[{value:"Setting up with Matter",id:"setting-up-with-matter",level:3},{value:"Other Setups",id:"other-setups",level:3}],d={toc:u},p="wrapper";function c(e){let{components:t,...n}=e;return(0,i.kt)(p,(0,r.Z)({},d,n,{components:t,mdxType:"MDXLayout"}),(0,i.kt)("h1",{id:"getting-started"},"Getting Started"),(0,i.kt)("admonition",{type:"tip"},(0,i.kt)("p",{parentName:"admonition"},"Check out the adapted version of the Matter Example game to see how it's used in a real game."),(0,i.kt)("p",{parentName:"admonition"},"See all of Net's ",(0,i.kt)("a",{parentName:"p",href:"https://github.com/YetAnotherClown/Net/tree/main/examples"},"example projects")," in the repository.")),(0,i.kt)("h3",{id:"setting-up-with-matter"},"Setting up with Matter"),(0,i.kt)("p",null,"Being made for the Matter ECS, Net provides a simple method for scheduling the Netcode to run\non your Matter Loop."),(0,i.kt)("p",null,"Firstly, similar to how you would setup your components with Matter, create a ",(0,i.kt)("inlineCode",{parentName:"p"},"identifiers.luau")," ModuleScript\nto strictly declare your Net identifiers. Identifiers are global and should be the first thing you make when\nusing the Net library."),(0,i.kt)("pre",null,(0,i.kt)("code",{parentName:"pre",className:"language-lua",metastring:'title="identifiers.luau"',title:'"identifiers.luau"'},'local Net = require(Net)\n\nlocal IDENTIFIERS = {\n  ["ExampleOne"] = Net.identifier("ExampleOne"),\n  ["ExampleTwo"] = Net.identifier("ExampleTwo")\n}\n-- Laid out for strict typing\n\nreturn IDENTIFIERS\n')),(0,i.kt)("p",null,"And then in the same script you initialize your Matter Systems, you can create a new Net object\nwith unique configuration by using the ",(0,i.kt)("inlineCode",{parentName:"p"},"Net.new()")," function. For example, you can change the Event and\nthe Priority the Net System is ran on in Configuration with the ",(0,i.kt)("inlineCode",{parentName:"p"},"Event")," and ",(0,i.kt)("inlineCode",{parentName:"p"},"Priority")," Parameters."),(0,i.kt)("p",null,"In order to use Net with Matter you must also use the ",(0,i.kt)("inlineCode",{parentName:"p"},"Net:start()")," method and pass in your Matter\nloop."),(0,i.kt)("p",null,"You should have only one Net object for every loop, though you shouldn't, in most cases, have more than one\nloop."),(0,i.kt)("p",null,"This same setup should be ran on both the Client and the Server with the same configuration in order to work."),(0,i.kt)("pre",null,(0,i.kt)("code",{parentName:"pre",className:"language-lua",metastring:'title="init.server.luau / init.client.luau"',title:'"init.server.luau',"/":!0,'init.client.luau"':!0},'local Matter = require(Matter)\nlocal World = Matter.World\nlocal Loop = Matter.Loop\n\nlocal Net = require(Net)\n\n-- Create a new Net Server/Client\nlocal net = Net.new({\n  Channel: "ReliableOrdered"\n  Event: "default",\n})\n\n-- Create your identifiers before initializing any netcode\nlocal identifiers = require("Identifiers.lua")\n\nlocal world = World.new()\nlocal loop = Loop.new(world, net)\n\nnet:start(loop) -- Initializes the net, adding it to your loop.\n\nlocal systems = {}\nfor _, child in script.systems:GetChildren() do\n    if child:IsA("ModuleScript") then\n        table.insert(systems, require(child))\n    end\nend\n\nloop:scheduleSystems(systems) -- Schedule systems after running Net:start()\n\n-- Begin the loop and make sure the eventName string you passed into Net:start() is in the event table\nloop:begin({\n    default = RunService.Heartbeat\n})\n')),(0,i.kt)("p",null,"Finally, in a Matter System we can use our ",(0,i.kt)("inlineCode",{parentName:"p"},"identifiers.luau")," ModuleScript to access our Identifiers and\nuse them within our System."),(0,i.kt)("p",null,"And, because we passed in our Net object into our Loop, we can use it in any of our Systems. We can send data\nusing ",(0,i.kt)("inlineCode",{parentName:"p"},"Net:send()")," and query it using ",(0,i.kt)("inlineCode",{parentName:"p"},"Net:query()"),"."),(0,i.kt)("pre",null,(0,i.kt)("code",{parentName:"pre",className:"language-lua",metastring:'title="systems/exampleSystem.luau"',title:'"systems/exampleSystem.luau"'},'local identifiers = require("identifier.luau")\nlocal ExampleIdentifier = identifiers.ExampleOne\n\nlocal function exampleSystem(world, net)\n    -- Query through every networking call that frame on the Server\n    for i, player, args... in net:query(ExampleIdentifier) do\n        -- Do something\n    end\n\n    -- Query through every networking call that frame on the Client\n    for i, args... in net:query(ExampleIdentifier) do\n        -- Do something\n    end\n\n    -- Send data from the Client to the Server\n    net:send(ExampleIdentifier, ...)\n\n    -- Send data to a Client from the Server\n    net:send(Player, ExampleIdentifier, ...)\nend\n')),(0,i.kt)("h3",{id:"other-setups"},"Other Setups"),(0,i.kt)("p",null,"Is Matter not for you? It is possible to use Net outside of Matter by bypassing the ",(0,i.kt)("inlineCode",{parentName:"p"},"Net:start()")," method and\nscheduling it with your own code using the internal mechanics of your Net object's ",(0,i.kt)("inlineCode",{parentName:"p"},"Bridge"),"."),(0,i.kt)("p",null,"Please note that if you aren't using Net within an ECS it is strongly discouraged that you use it. You should\nconsider using alternatives like BridgeNet2."),(0,i.kt)("p",null,"Below is a simple example of creating custom scheduling behavior using ",(0,i.kt)("inlineCode",{parentName:"p"},"Bridge:step()"),"."),(0,i.kt)("pre",null,(0,i.kt)("code",{parentName:"pre",className:"language-lua"},'local RunService = game:GetService("RunService")\n\nlocal Net = require(Net)\n\n-- Create a new Net Server/Client\nlocal net = NetLib.new()\n\n-- Create your identifiers before initializing any netcode\nlocal identifiers = require("Identifiers.lua")\n\nRunService.Heartbeat:Connect(function()\n    net._bridge:step() -- The Bridge:step() method processes the incoming and outgoing queues\nend)\n')),(0,i.kt)("p",null,"For more information on this, see the ",(0,i.kt)("a",{parentName:"p",href:"https://yetanotherclown.github.io/Net/api/Bridge"},"Bridge API"),"."))}c.isMDXComponent=!0}}]);