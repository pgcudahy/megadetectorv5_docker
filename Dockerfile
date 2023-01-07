FROM mambaorg/micromamba:1.1.0-jammy-cuda-11.8.0

LABEL "maintainer"="pgcudahy@gmail.com"

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

ENV WORKSPACE /workspace

RUN mkdir -p $WORKSPACE
WORKDIR $WORKSPACE

RUN cd $WORKSPACE
RUN git clone https://github.com/ecologize/yolov5/
RUN git clone https://github.com/Microsoft/cameratraps --branch v5.0
RUN git clone https://github.com/Microsoft/ai4eutils
RUN cd $WORKSPACE/yolov5 && git checkout ad033704d1a826e70cd365749e1bb01f1ea8282a
RUN cd $WORKSPACE/ai4eutils && git checkout ccec9fcf008b40e6e24adb9a8097c397a2179556

RUN mkdir $WORKSPACE/blobs
RUN wget -O $WORKSPACE/blobs/5a.0.0.pt \
    https://github.com/microsoft/CameraTraps/releases/download/v5.0/md_v5a.0.0.pt

RUN cd $WORKSPACE/cameratraps
RUN --mount=type=cache,target=/opt/conda/pkgs --mount=type=cache,target=/root/.cache \
    micromamba create --file $WORKSPACE/cameratraps/environment-detector.yml
RUN echo "micromamba activate cameratraps-detector" >> ~/.bashrc

ENV PYTHONPATH="$PYTHONPATH:$WORKSPACE/cameratraps:$WORKSPACE/ai4eutils:$WORKSPACE/yolov5"

ENTRYPOINT [ "micromamba", "run", "-n", "cameratraps-detector", "--no-capture-output"]
