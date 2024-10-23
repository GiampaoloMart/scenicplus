# Usa un'immagine di base con Micromamba integrato
FROM mambaorg/micromamba:1.4.2

# Imposta le variabili di ambiente per Micromamba
ENV MAMBA_DOCKERFILE_ACTIVATE=1
ENV MAMBA_ROOT_PREFIX=/opt/conda
ENV PATH=$MAMBA_ROOT_PREFIX/bin:$PATH

# Aggiorna il sistema e installa gli strumenti di compilazione e git
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Crea l'ambiente Micromamba con Python 3.11
RUN micromamba create -n scenicplus python=3.11 -y

# Installa pip e gli strumenti di compilazione per le dipendenze problematiche
RUN micromamba install -n scenicplus pip -y

# Imposta l'ambiente di lavoro
WORKDIR /scenicplus

# Clona il repository ScenicPlus
RUN micromamba run -n scenicplus git clone https://github.com/aertslab/scenicplus .

# Installa i pacchetti richiesti con pip senza usare cache
RUN micromamba run -n scenicplus pip install --no-cache-dir .

# Imposta l'ambiente Micromamba come predefinito all'avvio
CMD [ "/bin/bash", "-c", "micromamba activate scenicplus && exec bash" ]
