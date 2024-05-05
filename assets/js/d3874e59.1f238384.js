"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[374],{52897:(e,t,a)=>{a.r(t),a.d(t,{HomepageFeatures:()=>m,default:()=>p});var n=a(87462),r=a(39960),o=a(52263),l=a(34510),s=a(86010),i=a(67294);const u={heroBanner:"heroBanner_e1Bh",buttons:"buttons_VwD3",features:"features_WS6B",feature:"feature_moa3",featureImage:"featureImage_YrBe",featureText:"featureText_Nx12"},c=[{image:"Routes.svg",title:"Routes",description:i.createElement("body",null,i.createElement("p",null,"Routes are the way you send and receive data through YetAnotherNet. They are uniquely identified so you're encouraged to create as many as you need as if you were creating individual RemoteEvents."),i.createElement("p",null,"Routes can be Reliable or Unreliable. Reliable events are never dropped and are always in order per frame. Unreliable events might be dropped on bad connections, but they are always received in order per frame."),i.createElement("p",null,"You can also strictly type Routes to get autocompletion and typechecking when Sending and Querying packets."))},{image:"Middleware.svg",title:"Middleware",description:i.createElement("body",null,i.createElement("p",null,"Middleware is another powerful feature of YetAnotherNet, allowing you to validate types before they reach your code."),i.createElement("p",null,"To create Middleware, you set a function in your Route's Middleware that will give you the event ",i.createElement("code",{lang:"lua"},'"send" | "receive"')," and the data that is about to be processed ",i.createElement("code",{lang:"lua"},"U..."),", the types you specify in your type annotation ",i.createElement("code",{lang:"lua"},"Net<U...>")),i.createElement("p",null,"In the Middleware function, you can validate your types. If your data does not match your types, you can do ",i.createElement("code",{lang:"lua"},"return nil")," to drop the packet. Dropped packets will never reach your code, meaning you can ensure that the types your code receives are always the types you expect."),i.createElement("p",null,"You may want to use Middleware to Compress or Decompress your data, but YetAnotherNet has built-in buffer compression!"))},{image:"Hooks.svg",title:"Hooks",description:i.createElement("body",null,i.createElement("p",null,"Hooks are a simple and versatile way to integrate YetAnotherNet into any code architecture."),i.createElement("p",null,"Hooks allow you to run your Route's scheduling whenever you want, such as a specific event. A Hook is simply a function that you can call which will run each Route's scheduling code to process the current frame. Data is not sent over the Network until your hook is called."),i.createElement("p",null,"YetAnotherNet also provides a simple function that hooks your Routes to your Matter Middleware to run before/after your systems. This allows for a simple setup when using the Matter ECS, leaving you to not worry about scheduling your Routes."))}];function d(e){let{image:t,title:a,description:n}=e;return i.createElement("div",{class:u.feature},i.createElement("div",{class:u.featureImage},i.createElement("img",{src:t})),i.createElement("div",{class:u.featureText},i.createElement("h1",null,a),i.createElement(i.Fragment,null,n)))}function m(){return c?i.createElement("section",{className:u.features},i.createElement("div",{className:"container"},i.createElement("div",{className:"row"},i.createElement("div",{className:u.feature},i.createElement("div",{style:{paddingLeft:30,maxWidth:"45%"}},i.createElement("h1",null,"A Type-safe Networking Library"),i.createElement("p",null,"YetAnotherNet is strictly-typed, giving you full auto-completion and type-safety."),i.createElement("p",null,"Send arguments and Query return values of your Routes are fully typed, giving you auto-completion and type-checking when writing your Networking code.")),i.createElement("div",{style:{paddingLeft:100}},i.createElement("h1",null,"Hassle-free Compression Included"),i.createElement("p",null,"YetAnotherNet works behind the scenes to automatically compress the data you send over the network. It features an internal Ser/Des library to serialize all Luau Datatypes and most Roblox Datatypes."),i.createElement("p",null,"This process requires no work on the user's end besides making sure to avoid any ",i.createElement("a",{href:"./docs/getting-started/buffer-compression#unsupported-datatypes"},"Unsupported Datatypes"),".")))),i.createElement("div",{className:"row"},i.createElement("div",{className:u.feature},i.createElement("div",{style:{paddingLeft:30,maxWidth:"45%"}},i.createElement("h1",null,"Data-driven by Design"),i.createElement("p",null,"With it's roots in ECS, YetAnotherNet was designed to promote a Data-driven design.",i.createElement("br",null),"YetAnotherNet's API integrates seamlessly into ECS Libraries like Matter to bring Data-driven Networking in ECS architectures."),i.createElement("p",null,"Read more on why you should use an ECS ",i.createElement("a",{href:"https://matter-ecs.github.io/matter/docs/WhyECS"},"here"),".")),i.createElement("div",{style:{paddingLeft:60}},i.createElement("h1",null,"Available for Roblox Typescript"),i.createElement("p",null,"We provide Typings for Roblox Typescript users, you can get them on NPM ",i.createElement("a",{href:"https://www.npmjs.com/package/@rbxts/yetanothernet"},"here"),", or you can install using ",i.createElement("code",null,"npm i @rbxts/yetanothernet"),".")))),i.createElement("div",{className:"row"},c.map(((e,t)=>i.createElement(d,(0,n.Z)({key:t},e))))))):null}function y(){const{siteConfig:e}=(0,o.Z)(),t=e.customFields.bannerImage,a=!!t,n=a?{backgroundImage:`url("${t}")`}:null;(0,s.Z)("hero__title",{[u.titleOnBannerImage]:a}),(0,s.Z)("hero__subtitle",{[u.taglineOnBannerImage]:a});return i.createElement("header",{className:(0,s.Z)("hero",u.heroBanner),style:n},i.createElement("div",{className:"container"},i.createElement("img",{alt:"YetAnotherNet \u2014 A Data-Driven Networking Library, inspired by Bevy_Renet & BridgeNet2, made for ECS.",src:"Banner.svg"}),i.createElement("div",{className:u.buttons},i.createElement(r.Z,{className:"button button--secondary button--lg",to:"/docs/intro"},"Get Started \u2192"))))}function p(){const{siteConfig:e,tagline:t}=(0,o.Z)();return i.createElement(l.Z,{title:e.title,description:t},i.createElement(y,null),i.createElement("main",null,i.createElement(m,null)))}}}]);