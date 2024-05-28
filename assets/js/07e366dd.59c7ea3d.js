"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[488],{69217:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>c,contentTitle:()=>u,default:()=>p,frontMatter:()=>l,metadata:()=>i,toc:()=>d});var r=n(74848),o=n(28453),s=n(11470),a=n(19365);const l={sidebar_position:1},u="Routes",i={id:"getting-started/routes",title:"Routes",description:"Routes are the core component of YetAnotherNet, these objects are how you send or receive data through YetAnotherNet.",source:"@site/docs/getting-started/routes.mdx",sourceDirName:"getting-started",slug:"/getting-started/routes",permalink:"/YetAnotherNet/docs/getting-started/routes",draft:!1,unlisted:!1,editUrl:"https://github.com/YetAnotherClown/YetAnotherNet/edit/main/docs/getting-started/routes.mdx",tags:[],version:"current",sidebarPosition:1,frontMatter:{sidebar_position:1},sidebar:"defaultSidebar",previous:{title:"Introduction",permalink:"/YetAnotherNet/docs/intro"},next:{title:"Middleware",permalink:"/YetAnotherNet/docs/getting-started/middleware"}},c={},d=[{value:"Configuration",id:"configuration",level:2},{value:"Type-checking",id:"type-checking",level:2},{value:"Sending",id:"sending",level:2},{value:"Querying",id:"querying",level:2}];function h(e){const t={code:"code",h1:"h1",h2:"h2",hr:"hr",p:"p",pre:"pre",table:"table",tbody:"tbody",td:"td",th:"th",thead:"thead",tr:"tr",...(0,o.R)(),...e.components};return(0,r.jsxs)(r.Fragment,{children:[(0,r.jsx)(t.h1,{id:"routes",children:"Routes"}),"\n",(0,r.jsx)(t.p,{children:"Routes are the core component of YetAnotherNet, these objects are how you send or receive data through YetAnotherNet.\r\nThese are uniquely identified and come with no overhead, so you're encouraged to create as many as you need as if you were creating individual RemoteEvents."}),"\n",(0,r.jsx)(t.h2,{id:"configuration",children:"Configuration"}),"\n",(0,r.jsx)(t.p,{children:"There are a few ways you can configure your Routes:"}),"\n",(0,r.jsxs)(s.A,{children:[(0,r.jsxs)(a.A,{value:"channel",label:"Channel",default:!0,children:[(0,r.jsx)("p",{children:(0,r.jsxs)(t.p,{children:["All Routes run on one of two channels: Reliable & Unreliable.",(0,r.jsx)("br",{}),"\r\nThese channels change the way your packets are sent over the network."]})}),(0,r.jsxs)(t.table,{children:[(0,r.jsx)(t.thead,{children:(0,r.jsxs)(t.tr,{children:[(0,r.jsx)(t.th,{children:"Channel"}),(0,r.jsx)(t.th,{children:"Description"})]})}),(0,r.jsxs)(t.tbody,{children:[(0,r.jsxs)(t.tr,{children:[(0,r.jsx)(t.td,{children:"Reliable"}),(0,r.jsx)(t.td,{children:"Packets are never dropped, and are always ordered."})]}),(0,r.jsxs)(t.tr,{children:[(0,r.jsx)(t.td,{children:"Unreliable"}),(0,r.jsx)(t.td,{children:"Packets may be dropped per frame, but are always ordered per frame."})]})]})]})]}),(0,r.jsxs)(a.A,{value:"event",label:"Event",children:[(0,r.jsx)("p",{children:(0,r.jsxs)(t.p,{children:["The ",(0,r.jsx)("code",{lang:"lua",children:"Event"})," field is only used when you're using the Matter ECS.",(0,r.jsx)("br",{}),"\r\nThis is used internally in the ",(0,r.jsx)("code",{lang:"lua",children:"Net.start(loop, \t{ routes })"})," hook to schedule your Routes."]})}),(0,r.jsx)("p",{children:(0,r.jsxs)(t.p,{children:["You can safely ignore this field if you do not use the ",(0,r.jsx)("code",{lang:"lua",children:"Net.start(loop, \t{ routes })"})," hook."]})})]})]}),"\n",(0,r.jsx)(t.hr,{}),"\n",(0,r.jsx)(t.h2,{id:"type-checking",children:"Type-checking"}),"\n",(0,r.jsx)(t.p,{children:"Routes can be Type-checked to provide intellisense and auto-completion by providing a type annotation when creating your Routes."}),"\n",(0,r.jsxs)(s.A,{children:[(0,r.jsxs)(a.A,{value:"lua",label:"Luau",default:!0,children:[(0,r.jsx)(t.pre,{children:(0,r.jsx)(t.code,{className:"language-lua",children:'local Net = require("Net.luau")\r\n\r\nlocal Route = Net.Route\r\ntype Route<U...> = Net.Route<U...>;\r\n\r\nlocal route: Route<number, string, boolean> = Route.new()\r\n\r\n-- Send will expect the types annotated\r\nroute:send(1, "Hello, world!", true)\r\n\r\n-- The returned arguments are typed\r\nfor pos, num, str, bool in route:query() do\r\n  -- Do something\r\nend\n'})}),(0,r.jsxs)(t.p,{children:["In this example, the Route is annotated with the types ",(0,r.jsx)(t.code,{children:"number, string, boolean"}),", this means that our methods like ",(0,r.jsx)(t.code,{children:"Route:query()"})," and ",(0,r.jsx)(t.code,{children:"Route:send()"})," will return or expect\r\nthese types."]}),(0,r.jsx)(t.p,{children:"This will enable auto-completion and type-checking when working with your Routes, as such it is encouraged you enable Strict Typing to compliment these features."})]}),(0,r.jsxs)(a.A,{value:"ts",label:"Typescript",children:[(0,r.jsx)(t.pre,{children:(0,r.jsx)(t.code,{className:"language-ts",children:'import { Route } from "@rbxts/yetanothernet";\r\n\r\nconst route: Route<[number, boolean, string]> = new Route({\r\n  Channel: "Reliable",\r\n  Event: undefined,\r\n});\r\n\r\n// Send will expect the types annotated\r\nroute.send(1, "Hello, world!", true)\r\n\r\n// The returned arguments are typed\r\nfor (const [pos, sender, num, str, bool] of route.query()) {\r\n  // Do something\r\n}\n'})}),(0,r.jsxs)(t.p,{children:["In this example, the Route is annotated with the types ",(0,r.jsx)(t.code,{children:"number, string, boolean"}),", this means that our methods like ",(0,r.jsx)(t.code,{children:"Route.query()"})," and ",(0,r.jsx)(t.code,{children:"Route.send()"})," will return or expect\r\nthese types."]}),(0,r.jsx)(t.p,{children:"This will enable auto-completion and type-checking when working with your Routes, as such it is encouraged you enable Strict Typing to compliment these features."})]})]}),"\n",(0,r.jsx)(t.h2,{id:"sending",children:"Sending"}),"\n",(0,r.jsxs)(s.A,{children:[(0,r.jsxs)(a.A,{value:"lua",label:"Luau",default:!0,children:[(0,r.jsxs)(t.p,{children:["You can use ",(0,r.jsx)(t.code,{children:"Route:send(...data)"})," to send data over the Route. This data will be processed next frame, which is when you'll be able to query it on the receiving end."]}),(0,r.jsx)(t.pre,{children:(0,r.jsx)(t.code,{className:"language-lua",children:'local Net = require("Net.luau")\r\n\r\nlocal Route = Net.Route\r\ntype Route<U...> = Net.Route<U...>;\r\n\r\nlocal route: Route<number, string, boolean> = Route.new()\r\n\r\n-- Send will expect the types annotated\r\nroute:send(1, "Hello, world!", true)\r\n\r\n-- The returned arguments are typed\r\nfor pos, num, str, bool in route:query() do\r\n  -- Do something\r\nend\r\n\r\nlocal Route: Net<number, string, boolean> = Net.new()\r\n\r\nRoute:send(5, true, "Hello, world!")\n'})}),(0,r.jsxs)(t.p,{children:["By default, ",(0,r.jsx)(t.code,{children:"Route:send()"})," will send the Packet of data to all Clients when used on the Server. You can specify a ",(0,r.jsx)(t.code,{children:"Player"})," or ",(0,r.jsx)(t.code,{children:"{ Player }"})," to send it to by using ",(0,r.jsx)(t.code,{children:"Route:send():to(recipient)"}),"."]})]}),(0,r.jsxs)(a.A,{value:"ts",label:"Typescript",children:[(0,r.jsxs)(t.p,{children:["You can use ",(0,r.jsx)(t.code,{children:"Route.send(...data)"})," to send data over the Route. This data will be processed next frame, which is when you'll be able to query it on the receiving end."]}),(0,r.jsx)(t.pre,{children:(0,r.jsx)(t.code,{className:"language-ts",children:'import Route from "@rbxts/yetanothernet";\r\n\r\nconst route: Route<[number, boolean, string]> = new Route({\r\n  Channel: "Reliable",\r\n  Event: undefined,\r\n});\r\n\r\nRoute.send(5, true, "Hello, world!")\n'})}),(0,r.jsxs)(t.p,{children:["By default, ",(0,r.jsx)(t.code,{children:"Route.send()"})," will send the Packet of data to all Clients when used on the Server. You can specify a ",(0,r.jsx)(t.code,{children:"Player"})," or ",(0,r.jsx)(t.code,{children:"[Player]"})," to send it to by using ",(0,r.jsx)(t.code,{children:"Route.send().to(recipient)"}),"."]})]})]}),"\n",(0,r.jsx)(t.h2,{id:"querying",children:"Querying"}),"\n",(0,r.jsxs)(s.A,{children:[(0,r.jsxs)(a.A,{value:"lua",label:"Luau",default:!0,children:[(0,r.jsxs)(t.p,{children:["Querying is simple, you can query for Packets by using ",(0,r.jsx)(t.code,{children:"Route:query()"})," which will return an iterator that will output ",(0,r.jsx)(t.code,{children:"position, sender, ...data"})," in your for loop."]}),(0,r.jsx)(t.pre,{children:(0,r.jsx)(t.code,{className:"language-lua",children:'local Net = require("Net.luau")\r\n\r\nlocal Route = Net.Route\r\ntype Route<U...> = Net.Route<U...>;\r\n\r\nlocal Route: Route<number, string, boolean> = Route.new()\r\n\r\nfor pos, sender, num, str, bool in Route:query() do\r\n  -- Do something\r\nend\n'})}),(0,r.jsxs)(t.p,{children:["When you call the ",(0,r.jsx)(t.code,{children:"query"})," method, it will take a snapshot of all Packets from the previous frame and filter it for you, such as only returning Packets from the Route the method was called on.\r\nOr, you can also filter out senders by calling ",(0,r.jsx)(t.code,{children:"Route:query():from(...sender)"})," on the QueryResult and putting any values of type ",(0,r.jsx)(t.code,{children:"{ Player } | Player | Net.server"})," in the arguments."]})]}),(0,r.jsxs)(a.A,{value:"ts",label:"Typescript",children:[(0,r.jsxs)(t.p,{children:["Querying is simple, you can query for Packets by using ",(0,r.jsx)(t.code,{children:"Route.query()"})," which will return an iterator that will output ",(0,r.jsx)(t.code,{children:"position, sender, ...data"})," in your for loop."]}),(0,r.jsx)(t.pre,{children:(0,r.jsx)(t.code,{className:"language-ts",children:'import { Route } from "@rbxts/yetanothernet";\r\n\r\nconst route: Route<[number, boolean, string]> = new Route({\r\n  Channel: "Reliable",\r\n  Event: undefined,\r\n});\r\n\r\nfor (const [pos, sender, num, str, bool] of route.query()) {\r\n  // Do something\r\n}\n'})}),(0,r.jsxs)(t.p,{children:["When you call the ",(0,r.jsx)(t.code,{children:"query"})," function, it will take a snapshot of all Packets from the previous frame and filter it for you, such as only returning Packets from the Route the function was called on.\r\nOr, you can also filter out senders by calling ",(0,r.jsx)(t.code,{children:"Route.query().from(...sender)"})," on the QueryResult and putting any values of type ",(0,r.jsx)(t.code,{children:"[Player] | Player | Net.server"})," in the arguments."]})]})]})]})}function p(e={}){const{wrapper:t}={...(0,o.R)(),...e.components};return t?(0,r.jsx)(t,{...e,children:(0,r.jsx)(h,{...e})}):h(e)}},19365:(e,t,n)=>{n.d(t,{A:()=>a});n(96540);var r=n(34164);const o={tabItem:"tabItem_Ymn6"};var s=n(74848);function a(e){let{children:t,hidden:n,className:a}=e;return(0,s.jsx)("div",{role:"tabpanel",className:(0,r.A)(o.tabItem,a),hidden:n,children:t})}},11470:(e,t,n)=>{n.d(t,{A:()=>w});var r=n(96540),o=n(34164),s=n(23104),a=n(56347),l=n(205),u=n(57485),i=n(31682),c=n(89466);function d(e){return r.Children.toArray(e).filter((e=>"\n"!==e)).map((e=>{if(!e||(0,r.isValidElement)(e)&&function(e){const{props:t}=e;return!!t&&"object"==typeof t&&"value"in t}(e))return e;throw new Error(`Docusaurus error: Bad <Tabs> child <${"string"==typeof e.type?e.type:e.type.name}>: all children of the <Tabs> component should be <TabItem>, and every <TabItem> should have a unique "value" prop.`)}))?.filter(Boolean)??[]}function h(e){const{values:t,children:n}=e;return(0,r.useMemo)((()=>{const e=t??function(e){return d(e).map((e=>{let{props:{value:t,label:n,attributes:r,default:o}}=e;return{value:t,label:n,attributes:r,default:o}}))}(n);return function(e){const t=(0,i.X)(e,((e,t)=>e.value===t.value));if(t.length>0)throw new Error(`Docusaurus error: Duplicate values "${t.map((e=>e.value)).join(", ")}" found in <Tabs>. Every value needs to be unique.`)}(e),e}),[t,n])}function p(e){let{value:t,tabValues:n}=e;return n.some((e=>e.value===t))}function y(e){let{queryString:t=!1,groupId:n}=e;const o=(0,a.W6)(),s=function(e){let{queryString:t=!1,groupId:n}=e;if("string"==typeof t)return t;if(!1===t)return null;if(!0===t&&!n)throw new Error('Docusaurus error: The <Tabs> component groupId prop is required if queryString=true, because this value is used as the search param name. You can also provide an explicit value such as queryString="my-search-param".');return n??null}({queryString:t,groupId:n});return[(0,u.aZ)(s),(0,r.useCallback)((e=>{if(!s)return;const t=new URLSearchParams(o.location.search);t.set(s,e),o.replace({...o.location,search:t.toString()})}),[s,o])]}function f(e){const{defaultValue:t,queryString:n=!1,groupId:o}=e,s=h(e),[a,u]=(0,r.useState)((()=>function(e){let{defaultValue:t,tabValues:n}=e;if(0===n.length)throw new Error("Docusaurus error: the <Tabs> component requires at least one <TabItem> children component");if(t){if(!p({value:t,tabValues:n}))throw new Error(`Docusaurus error: The <Tabs> has a defaultValue "${t}" but none of its children has the corresponding value. Available values are: ${n.map((e=>e.value)).join(", ")}. If you intend to show no default tab, use defaultValue={null} instead.`);return t}const r=n.find((e=>e.default))??n[0];if(!r)throw new Error("Unexpected error: 0 tabValues");return r.value}({defaultValue:t,tabValues:s}))),[i,d]=y({queryString:n,groupId:o}),[f,b]=function(e){let{groupId:t}=e;const n=function(e){return e?`docusaurus.tab.${e}`:null}(t),[o,s]=(0,c.Dv)(n);return[o,(0,r.useCallback)((e=>{n&&s.set(e)}),[n,s])]}({groupId:o}),m=(()=>{const e=i??f;return p({value:e,tabValues:s})?e:null})();(0,l.A)((()=>{m&&u(m)}),[m]);return{selectedValue:a,selectValue:(0,r.useCallback)((e=>{if(!p({value:e,tabValues:s}))throw new Error(`Can't select invalid tab value=${e}`);u(e),d(e),b(e)}),[d,b,s]),tabValues:s}}var b=n(92303);const m={tabList:"tabList__CuJ",tabItem:"tabItem_LNqP"};var x=n(74848);function g(e){let{className:t,block:n,selectedValue:r,selectValue:a,tabValues:l}=e;const u=[],{blockElementScrollPositionUntilNextRender:i}=(0,s.a_)(),c=e=>{const t=e.currentTarget,n=u.indexOf(t),o=l[n].value;o!==r&&(i(t),a(o))},d=e=>{let t=null;switch(e.key){case"Enter":c(e);break;case"ArrowRight":{const n=u.indexOf(e.currentTarget)+1;t=u[n]??u[0];break}case"ArrowLeft":{const n=u.indexOf(e.currentTarget)-1;t=u[n]??u[u.length-1];break}}t?.focus()};return(0,x.jsx)("ul",{role:"tablist","aria-orientation":"horizontal",className:(0,o.A)("tabs",{"tabs--block":n},t),children:l.map((e=>{let{value:t,label:n,attributes:s}=e;return(0,x.jsx)("li",{role:"tab",tabIndex:r===t?0:-1,"aria-selected":r===t,ref:e=>u.push(e),onKeyDown:d,onClick:c,...s,className:(0,o.A)("tabs__item",m.tabItem,s?.className,{"tabs__item--active":r===t}),children:n??t},t)}))})}function j(e){let{lazy:t,children:n,selectedValue:o}=e;const s=(Array.isArray(n)?n:[n]).filter(Boolean);if(t){const e=s.find((e=>e.props.value===o));return e?(0,r.cloneElement)(e,{className:"margin-top--md"}):null}return(0,x.jsx)("div",{className:"margin-top--md",children:s.map(((e,t)=>(0,r.cloneElement)(e,{key:t,hidden:e.props.value!==o})))})}function v(e){const t=f(e);return(0,x.jsxs)("div",{className:(0,o.A)("tabs-container",m.tabList),children:[(0,x.jsx)(g,{...t,...e}),(0,x.jsx)(j,{...t,...e})]})}function w(e){const t=(0,b.A)();return(0,x.jsx)(v,{...e,children:d(e.children)},String(t))}},28453:(e,t,n)=>{n.d(t,{R:()=>a,x:()=>l});var r=n(96540);const o={},s=r.createContext(o);function a(e){const t=r.useContext(s);return r.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function l(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(o):e.components||o:a(e.components),r.createElement(s.Provider,{value:t},e.children)}}}]);