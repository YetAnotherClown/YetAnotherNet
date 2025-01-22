# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.10.0-alpha.2] - 2024-08-29

### Changed

- `Bridge:step()` has been replaced by `Bridge:beginFrame` and `Bridge:endFrame` which separates the logic behind the Incoming and Outgoing queues
- `YetAnotherNet.createHook()` now returns two functions, a `beginFrame` and a `endFrame` function which separates scheduling logic

### Fixed

- QueryResult filter stops iteration, causing packets to not be queried

## [0.9.0] - 2024-07-11

### Added

- Documentation for using Squash 2.0.0
- Setup Darklua and rules
- Add `.vscode` settings for luau-lsp
- Add Lint script
- Add GitHub CI Workflow
- Mention [roblox-project-template](https://github.com/grilme99/roblox-project-template) in README.md
- Add release scripts for Wally and NPM
- Added a [CONTRIBUTING.md](https://github.com/YetAnotherClown/YetAnotherNet/blob/main/CONTRIBUTING.md) guide

### Changed

- All files have been migrated to `.luau` and GitHub Linguist to Luau
- Updated note on Ratelimiting in Documentation
- `SendRequest:to()` no longer calls `RunService:IsClient()` and `RunService:IsRunning()` every invocation
- BrickColor, EnumItem, and boolean serde is now cached
- Changed order and added issue links to the Setup section in Documentation
- Renamed shell scripts
- Switched to String (alias/path) Requires
- Update Stylua configuration and apply changes
- Set exclusions in `selene.toml`
- Exclude docs in `tsconfig.json`
- Changed what is included in Wally and NPM package releases
- Luau types for Middleware are no longer strict due to inaccuracy of the type system
- Typescript types for Middleware have been improved to allow for more use cases

### Fixed

- Instance Changes when sent over the network would turn into a Mixed Table, resulting in incorrect Instances being deserialized
- `./examples` directly was named incorrectly as `./example` which resulted in broken links
- Documentation for `Configuration` now specifies what is optional
- Links to BridgeNet2 were outdated and resulted in 404 pages
- `getSerDes` function is no longer a bottleneck for serialization and now runs roughly 2x more efficiently
- EnumItem serde no longer iterates through all Enums and EnumItems, resulting in it running roughly 4.5x more efficiently
- `deserializeBuffer` function did not utilize Native Code Generation
- Fixed a type error with incoming middleware in internal code


## [0.8.0] - 2024-05-02

### Added

- Unit tests with Jest
    - For Identifier
    - For SendRequest
    - For QueryResult
    - For Route
    - For Bridge
- Bridge, Route, Player, and RemoteEvent Mocking
- Script for Installing Wally and Exporting Wally Types
- Script for running Jest tests using run-in-roblox
- Warning for attempting to send an invalid string as a recipient
- An Internal Ser/Des Library
- Automatic Compression for the Bridge
- Documentation for the Bridge

### Changed

- Updated Rojo to v7.4.0
- Updated Jest-Lua to v0.6.1-rc.2
- Migrate from Aftman to Foreman
- `SendRequest:to()` no longer returns if called on the Client
- Refactored Bridge to better allow for unit tests
- Reduced the average call time of `Route:send()` by 50-60%
- Documentation no longer references Compression with Middleware
- Rewrote the Bridge to support Buffers
- Refactored the Bridge to better support Mocking
- Identifiers are now represented as Buffers instead of packed strings
- Bridge:snapshot() now returns a frozen table instead of a cloned table

### Fixed

- QueryResult does not filter senders
- Incorrect types for Incoming Middleware
- Incorrect and inconsistent Roblox-TS Types
- Default Channel is never applied when no `configuration` parameter was supplied
- Outdated use of `Net.start` in Documentation
- `SendRequest:to()` will show a client warning when using run-in-roblox
- Incorrect Unit Test for Outgoing Middleware

## [0.7.0] - 2024-01-02

### Added

- Roblox Typescript API

### Changed

- Module now returns a Namespace
- Middleware now uses two separate functions instead of configuration
- Refactored internals
- Improved implementation of a default channel

### Fixed

- Channel Validation fails when Channel is Unreliable
- QueryResult returns the incorrect position

## [0.6.0] - 2023-12-14

### Added

- Middleware

### Changed

- Complete overhaul of the Documentation site

### Fixed

- Incoming packets do not respect their channel

## [0.5.0] - 2023-11-30

### Added

- New Routes API
- Strict Typing
- Unreliable Channel
- Hooks

### Changed

- Complete API Overhaul

## [0.4.0] - 2023-11-27

### Changed

- Rewrote ``Net:query()`` to use the new ``QueryResult`` type
- Rewrote ``Net:send()`` to use the new ``SendRequest`` type
- Exported and internal types are now more strict and are just generally improved

### Fixed

- `Priority` artifacts in documentation
- Matter example game has outdated paths
- Matter example game Replication & Formatting (#3)
- Rojo deletes Remotes when live-syncing (#4)

## [0.3.0] - 2023-09-20

### Added

- Matter Example Game AttackOfTheKillerRoombas, adapted from the official Matter Example Game.
- TestEZ Unit Tests to separate branch

### Removed

- Removed the  `ReliableOrdered` and `ReliableUnordered` Channels in favor for the new `Reliable` Channel. ReliableUnordered already sent and received packets in order, rendering ReliableOrdered useless and wasteful.

## [0.2.5] - 2023-09-12

### Fixed

- Query never filters Players, typecheck would always fail because `typeof(Player)` returns `Instance`
- Query filtering all Players on the server when no Player was given in the QueryParams

## [0.2.4] - 2023-08-28

### Fixed

- Middleware in the `start` method runs only once every two frames
- Iterator filter fails to properly filter key-value pairs by @IntegralsGetYouArea in https://github.com/YetAnotherClown/Net/pull/1
- Iterator filter should also take a key with it's value
- Identifiers always have the same position when the `pos` parameter is not given

## [0.2.3] - 2023-08-28

### Changed

- Updated the Getting Started page in Documentation to highlight the need to setup on both the Server and Client with the same configuration.

### Fixed

- The typecheck in Bridge when processing the outgoing queue always fails when the recipient is of type Player.

## [0.2.2] - 2023-07-17

### Changed

- Internal Naming of Functions for support for Roblox Debugging tools such as ScriptProfiler.

### Fixed

- The iterator always defaulting to sending all packet information regardless if an `returnFilter` was provided.
- `Net:query()` returning the Sender on Clients despite the Sender always being known on the Client as `Net.Server`.
- The internal filter of `Net:query()` never returning the Sender when type `{ Player }` is provided as a QueryParam and only one `Player` has sent packets.
- The internal filter of `Net:query()` filtering out Server Packets on the Client.
- The internal `QueryParams` Parser mistaking the `Net.Server` Recipient as an Identifier.

## [0.2.1] - 2023-07-3

### Changed

- `Net:start()` now utilizes middleware in Matter to schedule networking code.

### Fixed

- Minor issues in the Documentation.

## [0.2.0] - 2023-06-21

### Added

- Configuration for Event, Priority, and the ReliableOrdered & ReliableUnordered Channels.
- ReliableUnordered Channel

### Fixed

- Bridge using the wrong RemoteEvents.

## [0.1.1] - 2023-06-16

### Added

- `SendParams` to the `Net:send()` method. See the documentation on [Sending Data](https://yetanotherclown.github.io/Net/docs/handling-data/sending-data) for information on how to use them.
- Guard Clauses and associated Warnings to the ``Bridge:send()`` method to prevent incorrect data entering the queue.
- `Net.Server` key to represent the key associated with the Server.

### Changed

- Internal Configuration type to reflect the appropriate Channel types.

### Fixed

- Bridge creating an additional RemoteEvent that is never used.
- Linguist Syntax Highlighting and Language Stats.
