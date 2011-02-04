Please not that this documentation is not complete, we are working on finishing it.

###Building Erlang###

Make sure to have a valid toolchain in your path, in the EmbErl.sh script there
is a variable named host. The toolchain should have it's binaries named
$(HOST)-command. Example for HOST = arm gcc should be arm-gcc and be available
in your path.

We have used the toolchain that is built by openembedded when building our things.

`./EmbErl.sh -<opts>`

####Available opts are:####

    -s          Strip beam files and compile with the slim flag  
    -S          Stip binaries with the strip-tool  
    -c          Compile beams using the compress flag  
    -C          Compress applications into zip's  
    -o <arg>    Compile the virtual machine with the <arg> optimization flag  
    -H <arg>    Compile the virtual machine for the host <arg>  
    -h          Display help message  


To use another erlang version than the one that  EmbErl.sh uses as default, change the VERSION variable (eg `VERSION=R14B01 ./EmbErl.sh <arguments>` ). One can also set the variable `TARGET_ERL_ROOT=path` to change the location in which erlang will be installed.


###Generate package###
Use the `CreatePackage.sh` script in order to create a package. If you did specify `TARGET_ERL_ROOT` in the build step you should do it for the package generation as well (eg `TARGET_ERL_ROOT=path ./CreatePackage.sh`
