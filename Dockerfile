# docker-kaldi-instructional - A simplified version of Kaldi in Docker

FROM ubuntu:16.04
MAINTAINER Michael Capizzi <mcapizzi@email.arizona.edu>

# ENV and ARG variables
ARG HOME=/home/
ENV SHELL=/bin/bash
ENV KALDI_PATH=${HOME}/kaldi
ENV KALDI_INSTRUCTIONAL_PATH=${KALDI_PATH}/egs/INSTRUCTIONAL

# install dependencies
RUN apt-get update -qq \
 && apt-get install --no-install-recommends -y \
    git \
    python \
    python3 \
    python-setuptools \
    python-numpy \
    python-dev \
    python-pip \
    python-wheel \
    tmux \
    ffmpeg \
    # kaldi requirements
    g++ \
    libatlas3-base \
    zlib1g-dev \
    make \
    automake \
    autoconf \
    patch \
    bzip2 \
    wget \
    libtool \
    subversion \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN pip install --upgrade pip

# install bash jupyter kernel
RUN pip install jupyter bash_kernel ; python -m bash_kernel.install

# clone kaldi_instructional
WORKDIR ${HOME}
RUN git clone https://github.com/michaelcapizzi/kaldi.git
WORKDIR ${KALDI_PATH}
RUN git fetch
RUN git checkout kaldi_instructional

# install kaldi-specific tools
WORKDIR ${KALDI_PATH}/tools
# irstlm
ENV IRSTLM=${KALDI_PATH}/tools/irstlm
RUN extras/install_irstlm.sh
RUN export PATH=${PATH}:${IRSTLM}/bin
# tensorflow (python)
ARG GPU_SUPPORT=false
RUN extras/install_tensorflow_py.sh ${GPU_SUPPORT}
RUN pip freeze > ${HOME}/pip_freeze.txt
# tensorflow (C)
RUN extras/install_tensorflow_cc.sh
# compile tools
#RUN make -j 2

# make sure all dependencies are present
RUN extras/check_dependencies.sh

# compile kaldi source code
#WORKDIR ${KALDI_PATH}/src
#RUN ./configure --shared
#make depend -j 2

# compile TF C code
#WORKDIR ${KALDI_PATH}/src/tfrnnlm
#RUN make -j 2
#WORKDIR ${KALDI_PATH}/src
#RUN make -j 2

WORKDIR ${KALDI_INSTRUCTIONAL_PATH}
