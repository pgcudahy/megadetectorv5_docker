FROM continuumio/miniconda3:22.11.1-alpine

LABEL "maintainer"="pgcudahy@gmail.com"

RUN conda --version

ENV WORKSPACE /workspace

RUN mkdir $WORKSPACE
WORKDIR $WORKSPACE

RUN git clone https://github.com/ecologize/yolov5/
RUN git clone https://github.com/Microsoft/cameratraps --branch v5.0
RUN git clone https://github.com/Microsoft/ai4eutils
RUN cd $WORKSPACE/yolov5 && git checkout ad033704d1a826e70cd365749e1bb01f1ea8282a
RUN cd $WORKSPACE/ai4eutils && git checkout ccec9fcf008b40e6e24adb9a8097c397a2179556

RUN mkdir $WORKSPACE/blobs
RUN wget -O $WORKSPACE/blobs/5a.0.0.pt https://github.com/microsoft/CameraTraps/releases/download/v5.0/md_v5a.0.0.pt

RUN cd $WORKSPACE/cameratraps
RUN conda env create --file environment-detector.yml
RUN conda init bash
RUN echo "conda activate cameratraps-detector" >> ~/.bashrc

ENV PYTHONPATH="$PYTHONPATH:$WORKSPACE/cameratraps:$WORKSPACE/ai4eutils:$WORKSPACE/yolov5"

ENTRYPOINT [ "conda", "run", "-n", "cameratraps-detector", "--no-capture-output"]
