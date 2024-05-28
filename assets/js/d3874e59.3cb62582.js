"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[796],{74174:(e,t,s)=>{s.r(t),s.d(t,{HomepageFeatures:()=>u,default:()=>y});var r=s(28774),n=s(44586),a=s(83191),o=s(34164);s(96540);const i={heroBanner:"heroBanner_e1Bh",buttons:"buttons_VwD3",features:"features_WS6B",feature:"feature_moa3",featureImage:"featureImage_YrBe",featureText:"featureText_Nx12"};var d=s(74848);const l=[{image:"Routes.svg",title:"Routes",description:(0,d.jsxs)("body",{children:[(0,d.jsx)("p",{children:"Routes are the way you send and receive data through YetAnotherNet. They are uniquely identified so you're encouraged to create as many as you need as if you were creating individual RemoteEvents."}),(0,d.jsx)("p",{children:"Routes can be Reliable or Unreliable. Reliable events are never dropped and are always in order per frame. Unreliable events might be dropped on bad connections, but they are always received in order per frame."}),(0,d.jsx)("p",{children:"You can also strictly type Routes to get autocompletion and typechecking when Sending and Querying packets."})]})},{image:"Middleware.svg",title:"Middleware",description:(0,d.jsxs)("body",{children:[(0,d.jsx)("p",{children:"Middleware is another powerful feature of YetAnotherNet, allowing you to validate types before they reach your code."}),(0,d.jsxs)("p",{children:["To create Middleware, you set a function in your Route's Middleware that will give you the event ",(0,d.jsx)("code",{lang:"lua",children:'"send" | "receive"'})," and the data that is about to be processed ",(0,d.jsx)("code",{lang:"lua",children:"U..."}),", the types you specify in your type annotation ",(0,d.jsx)("code",{lang:"lua",children:"Net<U...>"})]}),(0,d.jsxs)("p",{children:["In the Middleware function, you can validate your types. If your data does not match your types, you can do ",(0,d.jsx)("code",{lang:"lua",children:"return nil"})," to drop the packet. Dropped packets will never reach your code, meaning you can ensure that the types your code receives are always the types you expect."]}),(0,d.jsx)("p",{children:"You may want to use Middleware to Compress or Decompress your data, but YetAnotherNet has built-in buffer compression!"})]})},{image:"Hooks.svg",title:"Hooks",description:(0,d.jsxs)("body",{children:[(0,d.jsx)("p",{children:"Hooks are a simple and versatile way to integrate YetAnotherNet into any code architecture."}),(0,d.jsx)("p",{children:"Hooks allow you to run your Route's scheduling whenever you want, such as a specific event. A Hook is simply a function that you can call which will run each Route's scheduling code to process the current frame. Data is not sent over the Network until your hook is called."}),(0,d.jsx)("p",{children:"YetAnotherNet also provides a simple function that hooks your Routes to your Matter Middleware to run before/after your systems. This allows for a simple setup when using the Matter ECS, leaving you to not worry about scheduling your Routes."})]})}];function c(e){let{image:t,title:s,description:r}=e;return(0,d.jsxs)("div",{class:i.feature,children:[(0,d.jsx)("div",{class:i.featureImage,children:(0,d.jsx)("img",{src:t})}),(0,d.jsxs)("div",{class:i.featureText,children:[(0,d.jsx)("h1",{children:s}),(0,d.jsx)(d.Fragment,{children:r})]})]})}function u(){return l?(0,d.jsx)("section",{className:i.features,children:(0,d.jsxs)("div",{className:"container",children:[(0,d.jsx)("div",{className:"row",children:(0,d.jsxs)("div",{className:i.feature,children:[(0,d.jsxs)("div",{style:{paddingLeft:30,maxWidth:"45%"},children:[(0,d.jsx)("h1",{children:"A Type-safe Networking Library"}),(0,d.jsx)("p",{children:"YetAnotherNet is strictly-typed, giving you full auto-completion and type-safety."}),(0,d.jsx)("p",{children:"Send arguments and Query return values of your Routes are fully typed, giving you auto-completion and type-checking when writing your Networking code."})]}),(0,d.jsxs)("div",{style:{paddingLeft:100},children:[(0,d.jsx)("h1",{children:"Hassle-free Compression Included"}),(0,d.jsx)("p",{children:"YetAnotherNet works behind the scenes to automatically compress the data you send over the network. It features an internal Ser/Des library to serialize all Luau Datatypes and most Roblox Datatypes."}),(0,d.jsxs)("p",{children:["This process requires no work on the user's end besides making sure to avoid any ",(0,d.jsx)("a",{href:"./docs/getting-started/buffer-compression#unsupported-datatypes",children:"Unsupported Datatypes"}),"."]})]})]})}),(0,d.jsx)("div",{className:"row",children:(0,d.jsxs)("div",{className:i.feature,children:[(0,d.jsxs)("div",{style:{paddingLeft:30,maxWidth:"45%"},children:[(0,d.jsx)("h1",{children:"Data-driven by Design"}),(0,d.jsxs)("p",{children:["With it's roots in ECS, YetAnotherNet was designed to promote a Data-driven design.",(0,d.jsx)("br",{}),"YetAnotherNet's API integrates seamlessly into ECS Libraries like Matter to bring Data-driven Networking in ECS architectures."]}),(0,d.jsxs)("p",{children:["Read more on why you should use an ECS ",(0,d.jsx)("a",{href:"https://matter-ecs.github.io/matter/docs/WhyECS",children:"here"}),"."]})]}),(0,d.jsxs)("div",{style:{paddingLeft:60},children:[(0,d.jsx)("h1",{children:"Available for Roblox Typescript"}),(0,d.jsxs)("p",{children:["We provide Typings for Roblox Typescript users, you can get them on NPM ",(0,d.jsx)("a",{href:"https://www.npmjs.com/package/@rbxts/yetanothernet",children:"here"}),", or you can install using ",(0,d.jsx)("code",{children:"npm i @rbxts/yetanothernet"}),"."]})]})]})}),(0,d.jsx)("div",{className:"row",children:l.map(((e,t)=>(0,d.jsx)(c,{...e},t)))})]})}):null}function h(){const{siteConfig:e}=(0,n.A)(),t=e.customFields.bannerImage,s=!!t,a=s?{backgroundImage:`url("${t}")`}:null;(0,o.A)("hero__title",{[i.titleOnBannerImage]:s}),(0,o.A)("hero__subtitle",{[i.taglineOnBannerImage]:s});return(0,d.jsx)("header",{className:(0,o.A)("hero",i.heroBanner),style:a,children:(0,d.jsxs)("div",{className:"container",children:[(0,d.jsx)("img",{alt:"YetAnotherNet \u2014 A Data-Driven Networking Library, inspired by Bevy_Renet & BridgeNet2, made for ECS.",src:"Banner.svg"}),(0,d.jsx)("div",{className:i.buttons,children:(0,d.jsx)(r.A,{className:"button button--secondary button--lg",to:"/docs/intro",children:"Get Started \u2192"})})]})})}function y(){const{siteConfig:e,tagline:t}=(0,n.A)();return(0,d.jsxs)(a.A,{title:e.title,description:t,children:[(0,d.jsx)(h,{}),(0,d.jsx)("main",{children:(0,d.jsx)(u,{})})]})}}}]);