FROM ubuntu:20.04 as base

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=america/new_york

RUN apt update -yy && apt upgrade -yy

# Some basic tools that tend to be usefull
RUN apt-get install -yy \
    sudo curl git wget build-essential vim mc screen \
    iputils-ping openssh-server \
    maven ant openjdk-8-jdk openjdk-11-jdk unzip \
    telnet

# Installing qt5 dependencies
RUN apt-get install -yy python perl llvm cmake extra-cmake-modules

# Installing nvm, nodejs, npm (not strictly needed for QT, but useful to test emscripten results)
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash \
 && export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" \
 && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
 && nvm install v10.13 \
 && nvm use v10.13

## Installing emsdk
# Get the emsdk repo
RUN git clone https://github.com/emscripten-core/emsdk.git
# Download and install the latest SDK tools.
RUN /emsdk/emsdk install latest
# Make the "latest" SDK "active" for the current user. (writes .emscripten file)
RUN /emsdk/emsdk activate latest
# Activate emsdk PATH and other environment variables in the terminal
RUN echo "source /emsdk/emsdk_env.sh" >> ~/.bashrc

## Installing QT and configuring qt-webasm
RUN git clone git://code.qt.io/qt/qt5.git && cd qt5 && git checkout 5.15.2 && \
    ./init-repository --module-subset=default,-qtwebengine

# ## configuring qt for webasm
RUN mkdir /qt5-wasm
RUN cd /emsdk && \. ./emsdk_env.sh && cd /qt5-wasm && \
    ../qt5/configure -opensource -confirm-license -xplatform wasm-emscripten -feature-thread -nomake tests -prefix /qt5-wasm/qtbase
RUN cd /emsdk && \. ./emsdk_env.sh && cd /qt5-wasm && \
    make module-qtbase module-qtdeclarative module-qtimageformats

# Activate qasm environment variables in the terminal
RUN echo 'export CMAKE_PREFIX_PATH="/qt5-wasm/qtbase/lib/cmake"' >> ~/.bashrc
RUN echo 'export Qt5_DIR="/qt5-wasm/qtbase/lib/cmake/Qt5/"' >> ~/.bashrc
RUN echo 'export QMAKE_EXECUTABLE="/src/dev_env/qt5-wasm/qtbase/bin/qmake"' >> ~/.bashrc
RUN echo 'export Qt5Core_DIR="/src/dev_env/qt5-wasm/qtbase/lib/cmake/Qt5Core"' >> ~/.bashrc

ENTRYPOINT ["/bin/bash"]
