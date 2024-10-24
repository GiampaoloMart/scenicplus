# Start from Micromamba base image
FROM mambaorg/micromamba:1.4.2

# Set environment variables
ENV MAMBA_DOCKERFILE_ACTIVATE=1 \
    MAMBA_ROOT_PREFIX=/opt/conda \
    PATH=$MAMBA_ROOT_PREFIX/bin:$PATH \
    DEBIAN_FRONTEND=noninteractive

# Switch to root for system updates and installations
USER root

# Install system dependencies in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        python3-dev \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /scenicplus

# Create conda environment and install dependencies in a single layer
# This reduces the number of layers and optimizes cache usage
RUN micromamba create -n scenicplus python=3.11 -y && \
    micromamba install -n scenicplus -y \
        pip \
        && \
    micromamba clean -a -y

# Clone and install ScenicPlus
RUN micromamba run -n scenicplus git clone https://github.com/aertslab/scenicplus . && \
    micromamba run -n scenicplus pip install --no-cache-dir .

# Switch back to non-root user for security
USER mambauser

# Set entrypoint to activate the environment
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh"]
CMD ["micromamba", "run", "-n", "scenicplus", "/bin/bash"]
