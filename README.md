# Respo in MoonBit

> A tiny virtual DOM library ported from [Respo.rs](https://github.com/Respo/respo.rs).

- Home <https://mbt.respo-mvc.org/>
- [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Respo/respo.mbt)
- Types <https://mooncakes.io/docs/#/tiye/respo/>
- Demo <https://repo.respo-mvc.org/respo.mbt>

Core ideas:

- Hot reload friendly for better dev experience
- Embraces types and autocompletion
- States are stored in a single atom, which is a tree structure with a concept like `cursor`
- Uni-directional data flow, dispatching is only allowed when user events occur
- Effects are for DOM updates, rather than dispatching actions

This project is in beta stage. APIs and structure are relatively stable.

Areas that need further exploration:

- Working with MoonBit immutable data structures

### Usage

```bash
moon add tiye/respo
```

To use Respo, start with the boilerplate at <https://github.com/Respo/respo-moonbit-workflow>

### License

Apache-2.0
