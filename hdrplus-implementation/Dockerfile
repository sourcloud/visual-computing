FROM ubuntu:20.04 as builder

ENV TZ=Europe/Berlin
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
	cmake \
	clang-tools-10 \
	llvm-10-dev \
	lld-10 \
	libclang-10-dev \
	liblld-10-dev \
	libgl-dev \
	libpng-dev \
	libraw-dev \
	libjpeg-dev \
	libtiff-dev \
    python3 \
    python3-pip \
	python3-dev \
	python3-numpy \
	python3-scipy \
	python3-imageio \
	python3-pybind11 \
	libopenblas-dev \
	libeigen3-dev \
	libatlas-base-dev \
	doxygen \
	ninja-build \
    git \
	wget

ENV LLVM_CONFIG=/usr/bin/llvm-config-10
ENV LLVM_DIR=/usr/lib/llvm-10/build
ENV LLD_DIR=/usr/lib/llvm-10/lib/cmake/lld

ENV CMAKE_BUILD_TYPE=Release

# Clone the Halide repository and build
RUN git clone --depth 1 --branch v10.0.0 https://github.com/halide/Halide.git && \
	cd Halide && \
	cmake -G Ninja -S . -B build && \
	cmake --build ./build && \
	cmake --install ./build --prefix /usr/local/bin/halide

# Clone the hdrplus repository and build
RUN git clone --branch master https://github.com/timothybrooks/hdr-plus.git && \
	cd hdr-plus && \
	mkdir build && \
	cd build && \
	cmake -DHALIDE_DISTRIB_DIR=/usr/local/bin/halide .. && \
	make -j$(nproc)

# Use clean image with compiled binary
FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
	libgl-dev \
	libpng-dev \
	libraw-dev \
	libjpeg-dev \
	libtiff-dev

COPY --from=builder /hdr-plus/build /hdr-plus
COPY --from=builder /usr/local/bin/halide/lib/libHalide.so.10 /usr/local/bin/halide/lib/libHalide.so.10 
COPY ./resources/process.sh /usr/local/bin/process.sh

RUN ln -s /hdr-plus/hdrplus /usr/local/bin/hdrplus

ENTRYPOINT ["sh", "/usr/local/bin/process.sh"]
