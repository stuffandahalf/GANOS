# ALiX
My Cross-platform Operating System

## Building
 1. Make sure that a version of clang and lld are available. They can be built by entering the tools directory and running `make` (requires cmake)
 2. Configure the toolchain file `make.tc` to point to clang and lld correctly, and add any additional flags
 3. Set the environment variable `PREFIX` to the new root install directory of the OS (what will become /)
 4. From the root directory, run `tools/makegen/makegen.sh -t make.tc` to produce makefiles
 5. run `make`
 6. run `make install`
