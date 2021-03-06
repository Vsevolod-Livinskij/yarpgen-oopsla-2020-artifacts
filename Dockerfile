FROM ubuntu:20.04

#Update
RUN apt-get -y update && DEBIAN_FRONTEND="noninteractive" apt-get -y install git cmake ninja-build gcc g++ clang curl wget flex make libisl-dev texinfo build-essential gcc-multilib lcov autogen dejagnu vim python3-pip llvm
RUN pip3 install psutil scipy


#Get LLVM
WORKDIR /usr/local/artifacts
RUN git clone https://github.com/llvm/llvm-project.git llvm-src
RUN mkdir llvm-build llvm-bin llvm-build-cov llvm-bin-cov
WORKDIR /usr/local/artifacts/llvm-src
RUN git checkout -b llvmorg-10.0.1 llvmorg-10.0.1

#Build LLVM
WORKDIR /usr/local/artifacts/llvm-build
RUN cmake -G "Ninja" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON  -DCMAKE_INSTALL_PREFIX=/usr/local/artifacts/llvm-bin -DCMAKE_BUILD_TYPE=Release  -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_ENABLE_DUMP=ON   -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_INSTALL_UTILS=ON  -DLLVM_TARGETS_TO_BUILD=X86 /usr/local/artifacts/llvm-src/llvm
RUN ninja install

#Build LLVM with coverage enabled
WORKDIR /usr/local/artifacts/llvm-build-cov
RUN CC=clang CXX=clang++ cmake -G "Ninja" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON  -DCMAKE_INSTALL_PREFIX=/usr/local/artifacts/llvm-bin-cov -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_ENABLE_DUMP=ON   -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_INSTALL_UTILS=ON -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_BUILD_INSTRUMENTED_COVERAGE=ON /usr/local/artifacts/llvm-src/llvm
RUN ninja install

#Get GCC
WORKDIR /usr/local/artifacts
RUN git clone git://gcc.gnu.org/git/gcc.git gcc-src
RUN mkdir gcc-build gcc-bin gcc-build-cov gcc-bin-cov
WORKDIR /usr/local/artifacts/gcc-src
RUN git checkout releases/gcc-10.2.0
RUN contrib/download_prerequisites
RUN wget https://raw.githubusercontent.com/Vsevolod-Livinskij/yarpgen-oopsla-2020-artifacts/master/no-bootstrap.patch && git apply no-bootstrap.patch

#Build GCC
WORKDIR /usr/local/artifacts/gcc-src
RUN contrib/gcc_build -d /usr/local/artifacts/gcc-src -o /usr/local/artifacts/gcc-build -c "--enable-multilib --prefix=/usr/local/artifacts/gcc-bin --disable-bootstrap" -m "-j120" configure build install

#Build GCC with coverage
WORKDIR /usr/local/artifacts/gcc-src
RUN contrib/gcc_build -d /usr/local/artifacts/gcc-src -o /usr/local/artifacts/gcc-build-cov -c "--enable-coverage --enable-multilib --prefix=/usr/local/artifacts/gcc-bin-cov --disable-bootstrap" -m "-j120" configure build install


# Get YARPGen
WORKDIR /usr/local/artifacts
RUN git clone https://github.com/Vsevolod-Livinskij/yarpgen
WORKDIR /usr/local/artifacts/yarpgen
RUN git checkout origin/artifact-eval
RUN mkdir build && cd build && cmake -G "Ninja" .. && ninja && cp ./yarpgen ..

# Get scripts
WORKDIR /usr/local/artifact
RUN git clone https://github.com/Vsevolod-Livinskij/yarpgen-oopsla-2020-artifacts scripts && cp scripts/*.sh ./ && cp scripts/*.py ./
WORKDIR /usr/local/artifacts/
