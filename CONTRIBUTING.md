# Contributing

## Contents

- [**Where to Discuss**]
    - [**Discord**]
    - [**GitHub Discussions**]
- [**Contributing on GitHub**]
    - [**Issues/Bug Reports**]
    - [**Pull Requests**]
- [**Local Development**]
    - [**Scripts**]
    - [**Code Conventions**]
    - [**String Requires**]
    - [**Tests**]
    - [**Commit Messages**]

[**Where to Discuss**]: #discussion
[**Discord**]: #discord
[**GitHub Discussions**]: #github-discussions
[**Contributing on GitHub**]: #on-github
[**Issues/Bug Reports**]: #issues
[**Pull Requests**]: #pull-requests
[**Local Development**]: #local-development
[**Scripts**]: #scripts
[**Code Conventions**]: #code-conventions
[**String Requires**]: #string-requires
[**Tests**]: #tests
[**Commit Messages**]: #commit-messages

## Discussion

### Discord

We have a Project Thread in the [Roblox OSS Community Server](https://quenty.org/oss/conduct), please read the Code of Conduct on that link before joining.
You can find the Project thread under the [#Projects](https://discord.com/channels/385151591524597761/1019724676265676930) threads channel titled as "YetAnotherNet," or you can follow [this link](https://discord.com/channels/385151591524597761/1179944163844825209).

**Please be mindful that the Roblox OSS Community is a professional workspace and not a general help desk, please keep questions and discussions about YetAnotherNet in our Project Thread and keep any other appropriate conversations in their respective channels.**

Please also be patient when awaiting a response in the thread, I will get to it when I can.

### GitHub Discussions

GitHub has a Discussions category on the repository page, you can start a discussion there to discuss your ideas, ask your questions,
or discuss other relevant topics regarding the project.

## On GitHub

### Issues

GitHub issues are used for submitting bug reports, requesting or submitting ideas for features or changes, etc.

#### Bug Reports

Please use a clear and short title that explains what the bug is,
in your description you should detail the steps to reproduce the bug, providing minimal reproduction code or files if possible.
Make sure not to submit a duplicate report for the same bug, check the issues tab in GitHub first.

### Pull Requests

GitHub Pull Requests are for when you've made an addition, change, or removal from the codebase or documentation.

A Pull Request should have a clear title that explains it's purpose.
The description should go over all changes made and any necessary implementation details.
If your PR fixes an Issue on GitHub, you should include ``Fixes #n`` in your description, e.g. ``Fixes #5``.

In your changes, you should appropriately list your changes in the CHANGELOG.md and update any relevant documentation.

Your PR will be reviewed and go through CI tests, if there are any changes requested or a failed CI, you're expected to fix it before your PR is merged.

## Local Development

### Scripts

All scripts are contained in the `./scripts` directory.

- analyze.sh: Analyzes the code with Luau-LSP
- build.sh: Builds the library into a .rbxm
- dev.sh: Serves Rojo with Darklua processing
- install-dependencies.sh: Installs all dev-packages from Wally
- lint.sh: Lints the code with Selene
- style.sh: Runs StyLua over the code and applies changes
- test.sh: Runs unit tests

You can run these scripts in bash, e.g.
```bash
./scripts/dev.sh
```

---

The following scripts are for the Maintainer and you **should not use them**.
They should error for you anyways.

These scripts will prepare the `/dist` directory and then publish to the respective registry.

- publish-wally.sh: Publishes to the Wally registry
- publish-rbxts.sh: Publishes to the NPM registry

### Code Conventions

This project follows the [Roblox Lua Style Guide](https://roblox.github.io/lua-style-guide/), additionally all tooling is pre-configured to follow conventions.
Make sure you use the `analyze`, `lint`, and `style` scripts before committing changes.

We also use strict typing, you can see [Type checking in Luau](https://luau-lang.org/typecheck) for more information on how to use strict typing.
It's not necessary to add ``--!strict`` to any file, Luau-LSP is setup to treat all files with strict typechecking.

### String Requires

We use String Requires, or alias/path requires, as opposed to Instance-based requires. String requires are path requires, meaning you can do `"./*"` to get the child of a script, or do `"../"` to get the parent of the script and so on.

We also have aliases that you can use:
- `"@yetanothernet"` will point to the project root
- `"@serdes"` will point to the root of the internal serdes library
- `"@dev-packages"` points to our wally dev-packages. String requires are already setup in all tooling and scripts

You shouldn't need to do any setup yourself unless you use an IDE other than VSCode.

### Tests

Tests ensure we don't introduce new or pre-existing bugs into our code. You should be adding tests with your changes where applicable, and running the tests with `test.sh` after your changes to make sure they all pass. If a pre-existing test is failing, do not edit the test to fix it failing, it is most likely an issue with your code.

If you're unable to run the `test.sh` script, serve the `dev.project.json` project with Rojo and then connect in Studio. You can hit the Run button to run the server and it'll run all tests and output the results.

### Commit Messages

Commit messages should be short, and expressive. If your commit fixes a bug, it should be prefixed with ``Fix:``.
See the commit history for examples.
