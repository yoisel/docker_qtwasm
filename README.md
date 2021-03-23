
# docker_qtwasm

An ubuntu-based dockerfile with emscripten sdk and QT5 open-source preconfigured for WebAssembly

## How to use this dockerfile to build a QT5 app with emscripten

Note that:

1- This docker build command will install qt5 from sources, so it will take a few *hours*

2- Running this dockerfile implies that you are accepting to use qt5 open-source licence and
you are confirming the license terms (see ../qt5/configure -opensource -confirm-license
inside the dockerfile)

    git clone https://github.com/yoisel/docker_qtwasm.git
    cd docker_qtwasm
    docker build -t qasm-dev-env-img .
    cd /path/to/my/qt/source/code
    docker run --rm -v ${PWD}:/src --name qasm-dev-env -it qasm-dev-env-img

Now we are inside a docker container with a folder /qt-wasm that contains qt5 pre-built for wasm

If you have a .pro (example myproject.pro) file under /src you can do:

    cd /src
    /qt-wasm/qtbase/bin/qmake myproject.pro
    emmake make
