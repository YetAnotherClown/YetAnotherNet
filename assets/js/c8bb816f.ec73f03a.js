"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[536],{3905:(e,t,n)=>{n.d(t,{Zo:()=>p,kt:()=>m});var a=n(67294);function r(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function i(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);t&&(a=a.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,a)}return n}function o(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?i(Object(n),!0).forEach((function(t){r(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):i(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function d(e,t){if(null==e)return{};var n,a,r=function(e,t){if(null==e)return{};var n,a,r={},i=Object.keys(e);for(a=0;a<i.length;a++)n=i[a],t.indexOf(n)>=0||(r[n]=e[n]);return r}(e,t);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);for(a=0;a<i.length;a++)n=i[a],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(r[n]=e[n])}return r}var l=a.createContext({}),s=function(e){var t=a.useContext(l),n=t;return e&&(n="function"==typeof e?e(t):o(o({},t),e)),n},p=function(e){var t=s(e.components);return a.createElement(l.Provider,{value:t},e.children)},u="mdxType",c={inlineCode:"code",wrapper:function(e){var t=e.children;return a.createElement(a.Fragment,{},t)}},f=a.forwardRef((function(e,t){var n=e.components,r=e.mdxType,i=e.originalType,l=e.parentName,p=d(e,["components","mdxType","originalType","parentName"]),u=s(n),f=r,m=u["".concat(l,".").concat(f)]||u[f]||c[f]||i;return n?a.createElement(m,o(o({ref:t},p),{},{components:n})):a.createElement(m,o({ref:t},p))}));function m(e,t){var n=arguments,r=t&&t.mdxType;if("string"==typeof e||r){var i=n.length,o=new Array(i);o[0]=f;var d={};for(var l in t)hasOwnProperty.call(t,l)&&(d[l]=t[l]);d.originalType=e,d[u]="string"==typeof e?e:r,o[1]=d;for(var s=2;s<i;s++)o[s]=n[s];return a.createElement.apply(null,o)}return a.createElement.apply(null,n)}f.displayName="MDXCreateElement"},31784:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>l,contentTitle:()=>o,default:()=>c,frontMatter:()=>i,metadata:()=>d,toc:()=>s});var a=n(87462),r=(n(67294),n(3905));const i={sidebar_position:1},o="Sending Data",d={unversionedId:"handling-data/sending-data",id:"handling-data/sending-data",title:"Sending Data",description:"Data is sent through a queue each frame. The library will queue up all data sent through the `Net:send()` method",source:"@site/docs/handling-data/sending-data.md",sourceDirName:"handling-data",slug:"/handling-data/sending-data",permalink:"/Net/docs/handling-data/sending-data",draft:!1,editUrl:"https://github.com/YetAnotherClown/Net/edit/main/docs/handling-data/sending-data.md",tags:[],version:"current",sidebarPosition:1,frontMatter:{sidebar_position:1},sidebar:"defaultSidebar",previous:{title:"Getting Started",permalink:"/Net/docs/getting-started"},next:{title:"Querying Data",permalink:"/Net/docs/handling-data/querying-data"}},l={},s=[{value:"Identifiers &amp; Data",id:"identifiers--data",level:2},{value:"Specifying Recipients",id:"specifying-recipients",level:2}],p={toc:s},u="wrapper";function c(e){let{components:t,...n}=e;return(0,r.kt)(u,(0,a.Z)({},p,n,{components:t,mdxType:"MDXLayout"}),(0,r.kt)("h1",{id:"sending-data"},"Sending Data"),(0,r.kt)("p",null,"Data is sent through a queue each frame. The library will queue up all data sent through the ",(0,r.kt)("inlineCode",{parentName:"p"},"Net:send()")," method\nand send it through a RemoteEvent at the start of a new frame."),(0,r.kt)("p",null,"To send data using Net, you can use the ",(0,r.kt)("inlineCode",{parentName:"p"},"Net:send()")," method. For example,"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},"local MyIdentifier = identifiers.MyIdentifier\nNet:send(MyIdentifier, ...)\n")),(0,r.kt)("h2",{id:"identifiers--data"},"Identifiers & Data"),(0,r.kt)("p",null,"In the ",(0,r.kt)("inlineCode",{parentName:"p"},"Net:send()")," method, the first Parameter will always be your Identifier. Identifiers are of type ",(0,r.kt)("inlineCode",{parentName:"p"},"Net.Identifier")," or ",(0,r.kt)("inlineCode",{parentName:"p"},"string"),".\nYou must supply an Identifier when sending data and it should always come before you provide your data.\nIt is recommended you use a ",(0,r.kt)("inlineCode",{parentName:"p"},"Net.Identifier")," instead of a ",(0,r.kt)("inlineCode",{parentName:"p"},"string"),", see ",(0,r.kt)("a",{parentName:"p",href:"/Net/docs/handling-data/compressing-data#identifiers"},"Identifiers")," for more."),(0,r.kt)("p",null,"Any other Parameters will be sent as data."),(0,r.kt)("h2",{id:"specifying-recipients"},"Specifying Recipients"),(0,r.kt)("p",null,"In order to specify who to send the data to, you must use the ","[SendRequest:to]"," method."),(0,r.kt)("p",null,"You can chain this onto ",(0,r.kt)("inlineCode",{parentName:"p"},"Net:send()")," and pass in ",(0,r.kt)("inlineCode",{parentName:"p"},"{ Player }"),", ",(0,r.kt)("inlineCode",{parentName:"p"},"Player"),", or ",(0,r.kt)("inlineCode",{parentName:"p"},"Net.Server"),","),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'local Players = game:GetService("Players")\n\nlocal MyIdentifier = identifiers.MyIdentifier\n\nNet:send(MyIdentifier, ...):to(Players:GetPlayers())\n')),(0,r.kt)("p",null,"By default, when you do not specify any recipients, it will always send to all players."))}c.isMDXComponent=!0}}]);