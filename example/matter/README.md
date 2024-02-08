# Attack of the Killer Roombas

> [!NOTE]
> This is an adapted version of the [Matter Example Game](https://github.com/matter-ecs/matter/tree/main/example), changes are stated below.

Adapted Changes:
- Use of YetAnotherNet instead of RemoteEvents
- Tweak `receiveReplication` to run as a system
- Style & Linting Fixes

If you plan on modifying this example, you may want to run `wally-package-types --sourcemap sourcemap.json Packages/`
with [Wally Package Types](https://github.com/JohnnyMorganz/wally-package-types) after running `wally install` to get Strict-Typing with YetAnotherNet.

## Building with Rojo

To build:

- Clone this repo
- Open the `example/matter` directory
- Run `wally install`
- Run `rojo build example.project.json --output example.rbxl`

Then, open `example.rbxl` and play. Enjoy.

## Hot reloading

This example game supports hot reloading, which lets you edit your systems and see the changes you've made in real time,
without needing to stop and start the game.

- Start live syncing from Rojo with the `example` project
- Connect Rojo from Studio while the game is stopped
- Play the game
- Switch to Server view (click the "Current: client" button next to the play and stop buttons)
- Connect to Rojo from Studio again (you might need to go to Plugins > Rojo if the rojo panel is not visible)

Any changes made to the files (or new or deleted files) in `systems` or `clientSystems` will immediately be reflected
in the game.