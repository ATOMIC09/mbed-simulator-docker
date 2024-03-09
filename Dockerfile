
FROM node:16-slim

ENV PATH="${PATH}:/emsdk:/emsdk/fastcomp-clang/e1.38.21_64bit:/emsdk/emscripten/1.38.21"
ENV EMSDK="/emsdk"
ENV EM_CONFIG="/emsdk/.emscripten"
ENV EMSCRIPTEN="/emsdk/emscripten/1.38.21"
ENV EMSCRIPTEN_NATIVE_OPTIMIZER="/emsdk/fastcomp-clang/e1.38.21_64bit/optimizer"
ENV LLVM_ROOT="/emsdk/fastcomp-clang/e1.38.21_64bit"
ENV BINARYEN_ROOT="/emsdk/fastcomp-clang/e1.38.21_64bit/binaryen"
ENV EMSDK_NODE="/usr/bin/node"
ENV EMCC_WASM_BACKEND="0"
ENV EM_CACHE="/emsdk/emscripten/1.38.21/cache"

RUN apt-get update -qq && \
    apt-get -qqy install \
    cmake git python3-dev python3-pip npm

RUN python3 -m pip install mbed-cli mercurial

RUN git clone https://github.com/emscripten-core/emsdk
RUN cd emsdk && git reset --hard 0b2084f 

RUN ln -s /emsdk /usr/lib/emsdk
RUN npm update -g

RUN emsdk/emsdk install fastcomp-clang-tag-e1.38.21-64bit && \
    emsdk/emsdk activate fastcomp-clang-tag-e1.38.21-64bit && \
    emsdk/emsdk install emscripten-1.38.30  && \
    emsdk/emsdk activate emscripten-1.38.30 

ADD . /mbed-simulator

WORKDIR /mbed-simulator

RUN npm install
RUN npm audit fix || :
RUN npm audit fix || :
RUN npm run build-demos

EXPOSE 7829

CMD ["node", "server"]
