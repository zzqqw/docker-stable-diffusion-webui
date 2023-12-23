# 使用基础镜像
ARG FORM_IMAGE="nvidia/cuda:12.1.1-devel-ubuntu22.04"
FROM ${FORM_IMAGE}
# sd tag
ARG SD_VERSION=""
# 执行命令追加
ENV CLI_ARGS=""

ENV NVIDIA_VISIBLE_DEVICES=all

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

# 安装必要的库
RUN apt update &&  \
    apt install -y --no-install-recommends bash ca-certificates wget git gcc sudo libgl1 libglib2.0-dev google-perftools && \
    rm -rf /var/lib/apt/lists/*

RUN echo "LD_PRELOAD=/usr/lib/libtcmalloc.so.4" | tee -a /etc/environment

# 创建执行用户
RUN useradd --home /sd -M sd -K UID_MIN=10000 -K GID_MIN=10000 -s /bin/bash && \
    mkdir -p /sd && \
    chown -R sd:sd /sd && \
    usermod -aG sudo sd && \
    echo 'sd ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER sd
WORKDIR /sd

#安装miniconda3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(uname -m).sh && \
    bash ./Miniconda3-latest-Linux-$(uname -m).sh -b  && \
    rm -rf ./Miniconda3-latest-Linux-$(uname -m).sh

ENV PATH=$PATH:/sd/miniconda3/bin

# 安装stable-diffusion-webui
RUN cd /tmp && wget https://github.com/AUTOMATIC1111/stable-diffusion-webui/archive/refs/tags/v${SD_VERSION}.tar.gz -O stable-diffusion-webui.tar.gz && \
    mkdir -p /sd/stable-diffusion-webui && \
    tar -xf stable-diffusion-webui.tar.gz -C /sd/stable-diffusion-webui --strip-components=1 && \
    rm -rf stable-diffusion-webui.tar.gz

# conda python 环境
RUN conda install python="3.10" -y

# 安装扩展
RUN pip install -r /sd/stable-diffusion-webui/requirements_versions.txt

# 设置工作目录
WORKDIR /sd/stable-diffusion-webui

# 目录挂载
VOLUME /sd/stable-diffusion-webui/extensions
VOLUME /sd/stable-diffusion-webui/textual_inversion_templates
VOLUME /sd/stable-diffusion-webui/embeddings
VOLUME /sd/stable-diffusion-webui/models
VOLUME /sd/stable-diffusion-webui/localizations
VOLUME /sd/stable-diffusion-webui/inputs
VOLUME /sd/stable-diffusion-webui/outputs

#开放端口
EXPOSE 7860

CMD python -u launch.py --listen --port 7860 ${CLI_ARGS}
