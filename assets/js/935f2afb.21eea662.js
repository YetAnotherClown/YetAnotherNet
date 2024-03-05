"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[53],{1109:e=>{e.exports=JSON.parse('{"pluginId":"default","version":"current","label":"Next","banner":null,"badge":false,"noIndex":false,"className":"docs-version-current","isLast":true,"docsSidebars":{"defaultSidebar":[{"type":"link","label":"Introduction","href":"/YetAnotherNet/docs/intro","docId":"intro"},{"type":"category","label":"Getting Started","collapsible":true,"collapsed":false,"items":[{"type":"link","label":"Routes","href":"/YetAnotherNet/docs/getting-started/routes","docId":"getting-started/routes"},{"type":"link","label":"Middleware","href":"/YetAnotherNet/docs/getting-started/middleware","docId":"getting-started/middleware"},{"type":"link","label":"Hooks","href":"/YetAnotherNet/docs/getting-started/hooks","docId":"getting-started/hooks"}]},{"type":"category","label":"Setup Guides","collapsible":true,"collapsed":true,"items":[{"type":"link","label":"ECR","href":"/YetAnotherNet/docs/setup/ecr","docId":"setup/ecr"},{"type":"link","label":"Matter","href":"/YetAnotherNet/docs/setup/matter","docId":"setup/matter"},{"type":"link","label":"Other Setups","href":"/YetAnotherNet/docs/setup/other","docId":"setup/other"}]}]},"docs":{"getting-started/hooks":{"id":"getting-started/hooks","title":"Hooks","description":"Hooks allow you to integrate YetAnotherNet into any game architecture you want. These are simply functions that you can call whenever you want to process your Packets. It\'s recommended that you set your hooks to run on the Heartbeat using RunService.Heartbeat, so your Networking Code can be scheduled to run frame-by-frame as Net was designed to do.","sidebar":"defaultSidebar"},"getting-started/middleware":{"id":"getting-started/middleware","title":"Middleware","description":"Middleware is a powerful feature of YetAnotherNet that allows you to validate types and serialize/deserialize data before it is processed when sending and receiving data.","sidebar":"defaultSidebar"},"getting-started/routes":{"id":"getting-started/routes","title":"Routes","description":"Routes are the core component of YetAnotherNet, these objects are how you send or receive data through YetAnotherNet.","sidebar":"defaultSidebar"},"intro":{"id":"intro","title":"Introduction","description":"What is this?","sidebar":"defaultSidebar"},"setup/ecr":{"id":"setup/ecr","title":"ECR","description":"\ud83c\udfd7\ufe0f This page is under construction.","sidebar":"defaultSidebar"},"setup/matter":{"id":"setup/matter","title":"Matter","description":"Check out the adapted version of the Matter Example game to see how it\'s used in a real game.","sidebar":"defaultSidebar"},"setup/other":{"id":"setup/other","title":"Other Setups","description":"You can integrate YetAnotherNet into whatever game architecture you want by creating a Hook using `Net.createHook({ Route }) which is identical to the Net.start(loop, { Route })` function. This function will return another function which you can call whenever you want to process your Routes\' queues and send/receive your Packets on the Server or Client.","sidebar":"defaultSidebar"}}}')}}]);