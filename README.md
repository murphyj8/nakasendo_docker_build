# nakasendo_docker_build
This container is to help with the building of the Nakasendo libraries. It is docker based. 


## Build the container
Execute ./build.sh

This may take some time depending on your docker settings. When building on the MacOS, I had to change the docker VM settings to the following
* CPUs -> 2
* Memory -> 10GB
* Swap Space -> 2GB
* Disk Image Size -> 50GB

## Set up

1. Clone the Naksendo repo to this location
    * If you are using the Nakasendo library from github then you'll need to make a change to one of the example CMakefile.txt files. Please remove the library Boost::date_time from the target_link_libraries list for the server_listener program. The file is nakasendo/examples/TS_protobuf/cpp/CMakeLists.txt and it's roughly line 30. This is required as the dockerfile installs boost_1_76 in the container whereas this build of Nakasendo uses boost_1_68. 
2. Create a 'build' directory
3. execute ./run.sh (this should start the container & mount the current location into the container until the location /SDK
4. change directory to the build directory & execute

    cmake ../naksendo
    make 
    make test


