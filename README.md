
# Nix + CMake template

1. Minimal devshell
2. `CMakeLists.txt` with some additional helpers in `cmake/`

NOTE: First time cmake is run for a template it will deliberately fail with helpful instructions.
Following those should land one with a quick walkthrough the cmake file and highligh all the
necessary project-specific things to edit.

# Structure:

This template has a very opinionated structure (and corresponding CMake setup). Directories are
layed out in unix-cpp library style with a separation between the `include/` and the `src/`
dorectories.

Installation (and packaging of the directory as a dependency) is granular enough to allow only to
expose the minimal interface from the `include/`, so bouilding minimal shared libraries should be a
little easier.

It also has support for custom build strategies forcing the use of usan/asan, using custom linker
(I use `mold`, but with little tweaking it can be swapped to any other linker).

But wait - there is more!

It also includes some support (as much I as insofar has had a need for) for:

- Building documentation from code
- Custom allocator (playing around with mimalloc as I liked their perf charts)
