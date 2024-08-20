
FROM node:16-slim

ENV EMSCRIPTEN_VERSION "1.38.30"

ENV PATH="${PATH}:/emsdk:/emsdk/fastcomp-clang/tag-e${EMSCRIPTEN_VERSION}:/emsdk/emscripten/tag-${EMSCRIPTEN_VERSION}"
ENV EMSDK="/emsdk"
ENV EM_CONFIG="/emsdk/.emscripten"
ENV EMSCRIPTEN="/emsdk/emscripten/tag-${EMSCRIPTEN_VERSION}"
ENV EMSCRIPTEN_NATIVE_OPTIMIZER="/emsdk/emscripten/tag-${EMSCRIPTEN_VERSION}_64bit_optimizer/optimizer"
ENV LLVM_ROOT="/emsdk/fastcomp-clang/tag-e${EMSCRIPTEN_VERSION}"
ENV BINARYEN_ROOT="/emsdk/fastcomp-clang/tag-e${EMSCRIPTEN_VERSION}/binaryen"
ENV EMSDK_NODE="/usr/bin/node"
ENV EMCC_WASM_BACKEND="0"
ENV EM_CACHE="/emsdk/emscripten/tag-${EMSCRIPTEN_VERSION}/cache"

RUN apt-get update -qq && \
    apt-get -qqy install \
    cmake git python3-dev python3-pip npm

RUN python3 -m pip install mbed-cli mercurial

RUN git clone --branch "3.1.29" https://github.com/emscripten-core/emsdk
RUN cd emsdk && git reset --hard 0b2084f 

RUN ln -s /emsdk /usr/lib/emsdk
RUN npm update -g

RUN emsdk/emsdk list
RUN emsdk/emsdk install sdk-fastcomp-tag-${EMSCRIPTEN_VERSION}-64bit && \
    emsdk/emsdk install emscripten-${EMSCRIPTEN_VERSION}  && \
    emsdk/emsdk activate fastcomp-clang-tag-e${EMSCRIPTEN_VERSION}-64bit && \
    emsdk/emsdk activate emscripten-${EMSCRIPTEN_VERSION} 

ADD . /mbed-simulator

WORKDIR /mbed-simulator

RUN npm install
RUN npm audit fix || :
RUN npm audit fix || :
RUN npm run build-demos

EXPOSE 7829

CMD ["node", "server"]
