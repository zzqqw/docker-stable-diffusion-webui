### Basic usage
~~~
docker run -it --name sd-cpu --env CLI_ARGS="--skip-torch-cuda-test --use-cpu all --no-download-sd-model"  zhiqiangwang/stable-diffusion-webui:latest

chmod -R 777  $(pwd)/sd
chown -R 10000:10000 $(pwd)/sd
docker run -it --name sd-gpu --rm  \
  --gpus all \
  -p 7860:7860 \
  -v $(pwd)/sd/extensions:/sd/stable-diffusion-webui/extensions \
  -v $(pwd)/sd/textual_inversion_templates:/sd/stable-diffusion-webui/textual_inversion_templates \
  -v $(pwd)/sd/embeddings:/sd/stable-diffusion-webui/embeddings \
  -v $(pwd)/sd/models:/sd/stable-diffusion-webui/models \
  -v $(pwd)/sd/localizations:/sd/stable-diffusion-webui/localizations \
  -v $(pwd)/sd/inputs:/sd/stable-diffusion-webui/inputs \
  -v $(pwd)/sd/outputs:/sd/stable-diffusion-webui/outputs \
  -e NVIDIA_VISIBLE_DEVICES=all \
  zhiqiangwang/stable-diffusion-webui:latest
~~~

### GPU driver installation

~~~
//系统更新
$ apt -y update && apt -y upgrade
$ apt-get -y install google-perftools

//查看GPU驱动信息
$ NVIDIA_DRIVER_VERSION=$(sudo apt-cache search 'linux-modules-nvidia-[0-9]+-gcp$' | awk '{print $1}' | sort | tail -n 1 | head -n 1 | awk -F"-" '{print $4}')
//安装GPU驱动
$  apt install linux-modules-nvidia-${NVIDIA_DRIVER_VERSION}-gcp nvidia-driver-${NVIDIA_DRIVER_VERSION}

//安装cuda-toolkit
$ wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb
$ dpkg -i cuda-keyring_1.0-1_all.deb
$ apt-get update
$ apt-get -y install  nvidia-cuda-toolkit


查看CUDA版本
$ nvidia-smi 
$ nvcc --version
~~~

### issues && pip install

```
pip install torch==2.0.1 torchvision==0.15.2
//https://github.com/AUTOMATIC1111/stable-diffusion-webui/issues/13236
pip install httpx==0.24.1
//https://github.com/AUTOMATIC1111/stable-diffusion-webui/issues/11855
pip install gradio_client==0.2.7
//https://github.com/AUTOMATIC1111/stable-diffusion-webui/issues/9136
pip install rubbrband==0.2.19
```

### Using Python to Check PyTorch Environment

~~~
python -c "import torch; print(torch.__version__, torch.cuda.is_available())"
~~~

### Building an image

~~~
docker build --build-arg="SD_VERSION=1.7.0" -t zhiqiangwang/stable-diffusion-webui:latest  .
docker build --build-arg="FORM_IMAGE=ubuntu:22.04" --build-arg="SD_VERSION=1.7.0"  -t zhiqiangwang/stable-diffusion-webui:latest  .
docker build --build-arg="FORM_IMAGE=nvidia/cuda:12.1.1-devel-ubuntu22.04" --build-arg="SD_VERSION=1.7.0"  -t zhiqiangwang/stable-diffusion-webui:latest  .
~~~

###  Related links

- https://github.com/AUTOMATIC1111/stable-diffusion-webui
- https://cloud.google.com/compute/docs/gpus/install-drivers-gpu?hl=zh-cn#ubuntu-20.04
- https://help.aliyun.com/zh/egs/user-guide/install-a-gpu-driver-on-a-gpu-accelerated-compute-optimized-linux-instance
- https://developer.nvidia.com/cuda-12-1-0-download-archive
- https://docs.docker.com/config/containers/resource_constraints/#gpu
- https://github.com/dtlnor/stable-diffusion-webui-localization-zh_CN/wiki

