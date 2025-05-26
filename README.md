# zig-limine-install

A basic wrapper for `limine bios-install` that separates the input
and output file arguments for easier use from a `build.zig`.

## Usage:
`limine-install [flags] -o <out file> -i <image file> [-p <gpt partition index>]`

When used as a dependency from `build.zig`, zig-limine-install provides an artifact
named `limine-install` and named LazyPaths for the limine binary branch root (`limine`)
and the limine bios stage3 directly (`limine-bios.sys`). 

Files in the limine binary branch other than the stage3 `limine-bios.sys` can be accessed
by calling `.path(...)` on the base `limine` named LazyPath.