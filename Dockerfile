FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive


ENV OPENSSL_VERSION "1.1.1k"

RUN apt-get update \
    && apt-get install -y git \
    perl \
    binutils \
    gcc \
    g++  \
    curl \
    make \
    wget \
    cmake \
    build-essential checkinstall zlib1g-dev \
    maven \
    ca-certificates \
    gosu \
    dirmngr \
    libtool \
    libssl-dev \
    libzmq3-dev \
    python3.8 python3 python-dev libboost-python-dev \
    python3-pip \
    coreutils \
    doxygen \
    libgmp3-dev \
    vim \
    rpm \
    npm \
    software-properties-common
    
    
# set python 3 as the default python version
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
RUN pip3 install --upgrade pip setuptools pipenv

ENV KUTILS          "1.6.1" 
ENV BOOSTVER        "1_76_0"
ENV BOOSTDIR        "1.76.0"
ENV GRPC_RELEASE_TAG "v1.34.0"

RUN curl -sL https://deb.nodesource.com/setup_14.x |  bash - && apt-get install -y nodejs

# install key utils
WORKDIR /home
RUN wget -O keyutils-${KUTILS}.tar.bz2  http://people.redhat.com/~dhowells/keyutils/keyutils-${KUTILS}.tar.bz2 \
    && tar xjvf keyutils-${KUTILS}.tar.bz2 && cd keyutils-${KUTILS} && make -j$(nproc --all) && make install 
    
# openssl

WORKDIR /
RUN wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz;  \
    mkdir -p /opt/openssl && tar xvf "openssl-${OPENSSL_VERSION}.tar.gz" --directory=/opt/openssl
    
WORKDIR /opt/openssl/openssl-${OPENSSL_VERSION}
RUN  export LIBS=-ldl && ./config --prefix=/opt/openssl --openssldir=/opt/openssl -Wl,-rpath=\\\$\$ORIGIN/../lib \
                       && make -j$(nproc --all)    

WORKDIR /
ENV CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/usr/include/python3.8
ENV C_INCLUDE_PATH=$C_INCLUDE_PATH:/usr/include/python3.8
RUN wget -c  https://boostorg.jfrog.io/artifactory/main/release/${BOOSTDIR}/source/boost_${BOOSTVER}.tar.bz2 && tar --bzip2 -xf ./boost_${BOOSTVER}.tar.bz2 && \
   cd boost_${BOOSTVER} && ./bootstrap.sh --with-python-version=3.9 --prefix=/usr/local && ./b2 -q cxxflags=-fPIC cflags=-fPIC install

WORKDIR /

RUN git clone -b ${GRPC_RELEASE_TAG} https://github.com/grpc/grpc /var/local/git/grpc && \
    cd /var/local/git/grpc && \
    git submodule update --init --recursive
   
RUN echo "-- installing protobuf" && \
    cd /var/local/git/grpc/third_party/protobuf && \
    ./autogen.sh && ./configure --enable-shared && \
    make -j 4 && make -j 4 check && make install && make clean && ldconfig

WORKDIR /

RUN echo "-- installing grpc" && \
    cd /var/local/git/grpc && mkdir -p cmake/build && cd cmake/build && \
    cmake ../.. -DRPC_INSTALL=ON -DCMAKE_BUILD_TYPE=Release -DgRPC_SSL_PROVIDER=package && \
    make -j 4 && make install && make clean && ldconfig
    
    

RUN pip3 install grpcio 
RUN pip3 install pytest

RUN python -m pip install grpcio-tools



                       
WORKDIR /
SHELL ["/bin/bash", "-c"]

