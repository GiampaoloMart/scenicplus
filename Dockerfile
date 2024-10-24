# Start from Micromamba base image
FROM mambaorg/micromamba:1.4.2

# Set environment variables
ENV MAMBA_DOCKERFILE_ACTIVATE=1 \
    MAMBA_ROOT_PREFIX=/opt/conda \
    PATH=$MAMBA_ROOT_PREFIX/bin:$PATH \
    DEBIAN_FRONTEND=noninteractive

# Copy environment file
COPY --chown=$MAMBA_USER:$MAMBA_USER environment.yaml /tmp/env.yaml

# Create the environment using micromamba
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes

# Switch to root for system updates and installations
USER root

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        python3-dev \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /scenicplus

# Install ScenicPlus
SHELL ["/bin/bash", "-c"]
RUN git clone https://github.com/aertslab/scenicplus . && \
    pip install --no-cache-dir .

# Switch back to non-root user
USER $MAMBA_USER

# Set the default shell
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh"]
CMD ["/bin/bash"]
