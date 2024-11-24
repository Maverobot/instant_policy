FROM ubuntu:20.04

# Install base utilities
RUN apt-get update \
    && apt-get install -y build-essential git wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install miniconda
ENV CONDA_DIR=/opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda

# Put conda in path so we can use conda activate
ENV PATH=$CONDA_DIR/bin:$PATH

WORKDIR /instant_policy

COPY ./ip /instant_policy/ip
COPY ./setup.py /instant_policy/setup.py
COPY ./environment.yml /instant_policy/environment.yml

RUN conda create -n ip_env -c nvidia -c pytorch
RUN conda init bash && . ~/.bashrc && conda activate ip_env
RUN conda env update --file environment.yml --prune
RUN pip install pyg-lib -f https://data.pyg.org/whl/torch-2.2.0+cu118.html
RUN pip install -e .

# Install RLBench
ENV COPPELIASIM_ROOT=/opt/CoppeliaSim
ENV LD_LIBRARY_PATH=$COPPELIASIM_ROOT
ENV QT_QPA_PLATFORM_PLUGIN_PATH=$COPPELIASIM_ROOT

RUN wget https://downloads.coppeliarobotics.com/V4_1_0/CoppeliaSim_Edu_V4_1_0_Ubuntu20_04.tar.xz
RUN mkdir -p $COPPELIASIM_ROOT && tar -xf CoppeliaSim_Edu_V4_1_0_Ubuntu20_04.tar.xz -C $COPPELIASIM_ROOT --strip-components 1
RUN rm -rf CoppeliaSim_Edu_V4_1_0_Ubuntu20_04.tar.xz

RUN pip install git+https://github.com/stepjam/RLBench.git
