"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[696],{27390:(e,t,r)=>{r.r(t),r.d(t,{assets:()=>c,contentTitle:()=>i,default:()=>p,frontMatter:()=>l,metadata:()=>u,toc:()=>d});var n=r(74848),a=r(28453),o=r(11470),s=r(19365);const l={sidebar_position:1},i="Matter",u={id:"setup/matter",title:"Matter",description:"Check out the adapted version of the Matter Example game to see how it's used in a real game.",source:"@site/docs/setup/matter.mdx",sourceDirName:"setup",slug:"/setup/matter",permalink:"/YetAnotherNet/docs/setup/matter",draft:!1,unlisted:!1,editUrl:"https://github.com/YetAnotherClown/YetAnotherNet/edit/main/docs/setup/matter.mdx",tags:[],version:"current",sidebarPosition:1,frontMatter:{sidebar_position:1},sidebar:"defaultSidebar",previous:{title:"Flamework Binary Serializer [TS]",permalink:"/YetAnotherNet/docs/even-more-compression/flamework-binary-serializer"},next:{title:"ECR",permalink:"/YetAnotherNet/docs/setup/ecr"}},c={},d=[];function h(e){const t={a:"a",admonition:"admonition",code:"code",h1:"h1",p:"p",pre:"pre",...(0,a.R)(),...e.components};return(0,n.jsxs)(n.Fragment,{children:[(0,n.jsx)(t.h1,{id:"matter",children:"Matter"}),"\n",(0,n.jsxs)(t.admonition,{type:"tip",children:[(0,n.jsx)(t.p,{children:"Check out the adapted version of the Matter Example game to see how it's used in a real game."}),(0,n.jsxs)(t.p,{children:["See all of YetAnotherNet's ",(0,n.jsx)(t.a,{href:"https://github.com/YetAnotherClown/YetAnotherNet/tree/main/examples",children:"example projects"})," in the repository."]})]}),"\n",(0,n.jsxs)(o.A,{children:[(0,n.jsxs)(s.A,{value:"lua",label:"Luau",default:!0,children:[(0,n.jsx)(t.p,{children:"Being initially made for the Matter ECS, YetAnotherNet provides a simple function for scheduling your Routes to run on your Matter Loop."}),(0,n.jsxs)(t.p,{children:["Firstly, create a ",(0,n.jsx)(t.code,{children:"routes.luau"})," ModuleScript in ReplicatedStorage to strictly declare your Routes."]}),(0,n.jsx)(t.pre,{children:(0,n.jsx)(t.code,{className:"language-lua",metastring:'title="shared/routes.luau"',children:'local YetAnotherNet = require("@shared/routes")\r\n\r\nlocal Route = YetAnotherNet.Route\r\ntype Route<U...> = YetAnotherNet.Route<U...>;\r\n\r\nlocal defaultConfiguration = {\r\n  Channel = "Reliable",\r\n  Event = "default",\r\n}\r\n\r\n-- Payload for replicating Entities\r\ntype EntityPayload = {\r\n    [string]: { -- EntityId\r\n        [string]: { -- Component name\r\n            data: ComponentInstance<T>\r\n        }\r\n    }\r\n}\r\n\r\n-- Replicate Matter Components\r\nlocal MatterReplication: Route<EntityPayload> = Route.new(defaultConfiguration)\r\n\r\n-- Signal that the Player has loaded\r\nlocal PlayerLoaded: Route<boolean> = Route.new(defaultConfiguration)\r\n\r\nreturn {\r\n  MatterReplication = MatterReplication,\r\n  PlayerLoaded = PlayerLoaded,\r\n}\n'})}),(0,n.jsxs)(t.p,{children:["And now in the same script where you create your Matter Loop, you can run the ",(0,n.jsx)(t.code,{children:"YetAnotherNet.start(Loop, { Route })"}),"\r\nfunction to schedule your Routes to run on Matter's Middleware."]}),(0,n.jsx)(t.pre,{children:(0,n.jsx)(t.code,{className:"language-lua",metastring:'title="init.server.luau / init.client.luau"',children:'local RunService = game:GetService("RunService")\r\n\r\nlocal Matter = require("@packages/Matter")\r\nlocal World = Matter.World\r\nlocal Loop = Matter.Loop\r\n\r\nlocal YetAnotherNet = require("@packages/YetAnotherNet")\r\nlocal routes = require("@shared/routes")\r\n\r\nlocal world = World.new()\r\nlocal loop = Loop.new(world)\r\n\r\n-- Schedules your Routes\r\nYetAnotherNet.start(loop, routes)\r\n\r\nlocal systems = {}\r\nfor _, child in script.systems:GetChildren() do\r\n    if child:IsA("ModuleScript") then\r\n        table.insert(systems, require(child))\r\n    end\r\nend\r\n\r\nloop:scheduleSystems(systems) -- Schedule systems after running ``YetAnotherNet.start()``\r\n\r\n-- Begin the loop and make sure the ``Event`` key in your Routes configuration are added here\r\nloop:begin({\r\n    default = RunService.Heartbeat\r\n})\n'})}),(0,n.jsxs)(t.p,{children:["Finally, in a Matter System we can use our ",(0,n.jsx)(t.code,{children:"routes.luau"})," ModuleScript to access our Routes and\r\nuse them within our Systems."]}),(0,n.jsx)(t.pre,{children:(0,n.jsx)(t.code,{className:"language-lua",metastring:'title="systems/exampleSystem.luau"',children:'local routes = require("@shared/routes")\r\nlocal PlayerLoaded = routes.PlayerLoaded\r\n\r\nlocal function exampleSystem(world)\r\n    -- Query through every networking call that frame on the Server\r\n    for i, player, ...data in PlayerLoaded:query() do\r\n        -- Do something\r\n    end\r\n\r\n    -- Query through every networking call that frame on the Client\r\n    for i, _, ...data in PlayerLoaded:query() do\r\n        -- Do something\r\n    end\r\n\r\n    -- Send data from the Client to the Server\r\n    PlayerLoaded:send(...data)\r\n\r\n    -- Send data to a Client from the Server\r\n    PlayerLoaded:send(...data):to(Player)\r\nend\n'})})]}),(0,n.jsxs)(s.A,{value:"ts",label:"Typescript",children:[(0,n.jsx)(t.p,{children:"Being initially made for the Matter ECS, YetAnotherNet provides a simple function for scheduling your Routes to run on your Matter Loop."}),(0,n.jsxs)(t.p,{children:["Firstly, create a ",(0,n.jsx)(t.code,{children:"routes.ts"})," ModuleScript in ReplicatedStorage to strictly declare your Routes."]}),(0,n.jsx)(t.pre,{children:(0,n.jsx)(t.code,{className:"language-ts",metastring:'title="routes.ts"',children:'import { Route, Configuration } from "@rbxts/yetanothernet";\r\n\r\nconst defaultConfiguration: Configuration = {\r\n  Channel: "Reliable",\r\n  Event: "default",\r\n};\r\n\r\n// Replicate Matter Components\r\nconst MatterReplication = new Route(defaultConfiguration);\r\n\r\n// Signal that the Player has loaded\r\nconst PlayerLoaded: Route<[boolean]> = new Route(defaultConfiguration);\r\n\r\nexport = {\r\n  MatterReplication: MatterReplication,\r\n  PlayerLoaded: PlayerLoaded,\r\n};\n'})}),(0,n.jsxs)(t.p,{children:["And now in the same script where you create your Matter Loop, you can run the ",(0,n.jsx)(t.code,{children:"Net.start(Loop, { route: Route })"}),"\r\nfunction to schedule your Routes to run on Matter's Middleware."]}),(0,n.jsx)(t.pre,{children:(0,n.jsx)(t.code,{className:"language-ts",metastring:'title="main.server.ts / main.client.ts"',children:'import { RunService } from "@rbxts/services";\r\n\r\nimport { Loop, System } from "@rbxts/matter";\r\n\r\nimport Net from "@rbxts/yetanothernet";\r\nimport routes from "shared/routes";\r\n\r\nconst loop = new Loop();\r\n\r\n// Schedules your Routes\r\nNet.start(loop, routes);\r\n\r\n// Schedule systems\r\nconst systems: System<[]>[] = [];\r\nloop.scheduleSystems(systems);\r\n\r\n// Begin the loop and make sure the ``Event`` key in your Routes configuration are added here\r\nloop.begin({\r\n    default: RunService.Heartbeat\r\n});\n'})}),(0,n.jsxs)(t.p,{children:["Finally, in a Matter System we can use our ",(0,n.jsx)(t.code,{children:"routes.ts"})," ModuleScript to access our Routes and\r\nuse them within our Systems."]}),(0,n.jsx)(t.pre,{children:(0,n.jsx)(t.code,{className:"language-ts",metastring:'title="systems/exampleSystem.ts"',children:'import routes from "shared/routes";\r\n\r\nconst PlayerLoaded = routes.PlayerLoaded;\r\n\r\nfunction exampleSystem(world) {\r\n    // Query through every networking call that frame on the Server\r\n    for (const [pos, player, bool] of PlayerLoaded.query()) {\r\n        // Do something\r\n    }\r\n\r\n    // Query through every networking call that frame on the Client\r\n    for (const [pos, _, bool] of PlayerLoaded.query()) {\r\n        // Do something\r\n    }\r\n\r\n    // Send data from the Client to the Server\r\n    PlayerLoaded.send(true);\r\n\r\n    // Send data to a Client from the Server\r\n    PlayerLoaded.send(true).to(Player);\r\n}\r\n\r\nexport = {\r\n    system: exampleSystem\r\n}\n'})})]})]})]})}function p(e={}){const{wrapper:t}={...(0,a.R)(),...e.components};return t?(0,n.jsx)(t,{...e,children:(0,n.jsx)(h,{...e})}):h(e)}},19365:(e,t,r)=>{r.d(t,{A:()=>s});r(96540);var n=r(34164);const a={tabItem:"tabItem_Ymn6"};var o=r(74848);function s(e){let{children:t,hidden:r,className:s}=e;return(0,o.jsx)("div",{role:"tabpanel",className:(0,n.A)(a.tabItem,s),hidden:r,children:t})}},11470:(e,t,r)=>{r.d(t,{A:()=>w});var n=r(96540),a=r(34164),o=r(23104),s=r(56347),l=r(205),i=r(57485),u=r(31682),c=r(70679);function d(e){return n.Children.toArray(e).filter((e=>"\n"!==e)).map((e=>{if(!e||(0,n.isValidElement)(e)&&function(e){const{props:t}=e;return!!t&&"object"==typeof t&&"value"in t}(e))return e;throw new Error(`Docusaurus error: Bad <Tabs> child <${"string"==typeof e.type?e.type:e.type.name}>: all children of the <Tabs> component should be <TabItem>, and every <TabItem> should have a unique "value" prop.`)}))?.filter(Boolean)??[]}function h(e){const{values:t,children:r}=e;return(0,n.useMemo)((()=>{const e=t??function(e){return d(e).map((e=>{let{props:{value:t,label:r,attributes:n,default:a}}=e;return{value:t,label:r,attributes:n,default:a}}))}(r);return function(e){const t=(0,u.X)(e,((e,t)=>e.value===t.value));if(t.length>0)throw new Error(`Docusaurus error: Duplicate values "${t.map((e=>e.value)).join(", ")}" found in <Tabs>. Every value needs to be unique.`)}(e),e}),[t,r])}function p(e){let{value:t,tabValues:r}=e;return r.some((e=>e.value===t))}function m(e){let{queryString:t=!1,groupId:r}=e;const a=(0,s.W6)(),o=function(e){let{queryString:t=!1,groupId:r}=e;if("string"==typeof t)return t;if(!1===t)return null;if(!0===t&&!r)throw new Error('Docusaurus error: The <Tabs> component groupId prop is required if queryString=true, because this value is used as the search param name. You can also provide an explicit value such as queryString="my-search-param".');return r??null}({queryString:t,groupId:r});return[(0,i.aZ)(o),(0,n.useCallback)((e=>{if(!o)return;const t=new URLSearchParams(a.location.search);t.set(o,e),a.replace({...a.location,search:t.toString()})}),[o,a])]}function f(e){const{defaultValue:t,queryString:r=!1,groupId:a}=e,o=h(e),[s,i]=(0,n.useState)((()=>function(e){let{defaultValue:t,tabValues:r}=e;if(0===r.length)throw new Error("Docusaurus error: the <Tabs> component requires at least one <TabItem> children component");if(t){if(!p({value:t,tabValues:r}))throw new Error(`Docusaurus error: The <Tabs> has a defaultValue "${t}" but none of its children has the corresponding value. Available values are: ${r.map((e=>e.value)).join(", ")}. If you intend to show no default tab, use defaultValue={null} instead.`);return t}const n=r.find((e=>e.default))??r[0];if(!n)throw new Error("Unexpected error: 0 tabValues");return n.value}({defaultValue:t,tabValues:o}))),[u,d]=m({queryString:r,groupId:a}),[f,y]=function(e){let{groupId:t}=e;const r=function(e){return e?`docusaurus.tab.${e}`:null}(t),[a,o]=(0,c.Dv)(r);return[a,(0,n.useCallback)((e=>{r&&o.set(e)}),[r,o])]}({groupId:a}),g=(()=>{const e=u??f;return p({value:e,tabValues:o})?e:null})();(0,l.A)((()=>{g&&i(g)}),[g]);return{selectedValue:s,selectValue:(0,n.useCallback)((e=>{if(!p({value:e,tabValues:o}))throw new Error(`Can't select invalid tab value=${e}`);i(e),d(e),y(e)}),[d,y,o]),tabValues:o}}var y=r(92303);const g={tabList:"tabList__CuJ",tabItem:"tabItem_LNqP"};var b=r(74848);function v(e){let{className:t,block:r,selectedValue:n,selectValue:s,tabValues:l}=e;const i=[],{blockElementScrollPositionUntilNextRender:u}=(0,o.a_)(),c=e=>{const t=e.currentTarget,r=i.indexOf(t),a=l[r].value;a!==n&&(u(t),s(a))},d=e=>{let t=null;switch(e.key){case"Enter":c(e);break;case"ArrowRight":{const r=i.indexOf(e.currentTarget)+1;t=i[r]??i[0];break}case"ArrowLeft":{const r=i.indexOf(e.currentTarget)-1;t=i[r]??i[i.length-1];break}}t?.focus()};return(0,b.jsx)("ul",{role:"tablist","aria-orientation":"horizontal",className:(0,a.A)("tabs",{"tabs--block":r},t),children:l.map((e=>{let{value:t,label:r,attributes:o}=e;return(0,b.jsx)("li",{role:"tab",tabIndex:n===t?0:-1,"aria-selected":n===t,ref:e=>i.push(e),onKeyDown:d,onClick:c,...o,className:(0,a.A)("tabs__item",g.tabItem,o?.className,{"tabs__item--active":n===t}),children:r??t},t)}))})}function x(e){let{lazy:t,children:r,selectedValue:a}=e;const o=(Array.isArray(r)?r:[r]).filter(Boolean);if(t){const e=o.find((e=>e.props.value===a));return e?(0,n.cloneElement)(e,{className:"margin-top--md"}):null}return(0,b.jsx)("div",{className:"margin-top--md",children:o.map(((e,t)=>(0,n.cloneElement)(e,{key:t,hidden:e.props.value!==a})))})}function S(e){const t=f(e);return(0,b.jsxs)("div",{className:(0,a.A)("tabs-container",g.tabList),children:[(0,b.jsx)(v,{...t,...e}),(0,b.jsx)(x,{...t,...e})]})}function w(e){const t=(0,y.A)();return(0,b.jsx)(S,{...e,children:d(e.children)},String(t))}},28453:(e,t,r)=>{r.d(t,{R:()=>s,x:()=>l});var n=r(96540);const a={},o=n.createContext(a);function s(e){const t=n.useContext(o);return n.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function l(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(a):e.components||a:s(e.components),n.createElement(o.Provider,{value:t},e.children)}}}]);