# Usa un'immagine di base leggera con Micromamba integrato
FROM mambaorg/micromamba:1.4.2

# Imposta le variabili di ambiente per Micromamba
ENV MAMBA_DOCKERFILE_ACTIVATE=1
ENV MAMBA_ROOT_PREFIX=/opt/conda
ENV PATH=$MAMBA_ROOT_PREFIX/bin:$PATH

# Installa strumenti di compilazione e dipendenze di sistema utilizzando apk
RUN apk add --no-cache \
    build-base \
    git \
    python3-dev

# Crea l'ambiente Micromamba con Python 3.11 specificando il canale conda-forge
RUN micromamba create -n scenicplus -c conda-forge python=3.11 -y

# Installa pip e gli strumenti di compilazione per le dipendenze problematiche
RUN micromamba install -n scenicplus -c conda-forge pip -y

# Imposta l'ambiente di lavoro
WORKDIR /scenicplus

# Clona il repository ScenicPlus
RUN micromamba run -n scenicplus git clone https://github.com/aertslab/scenicplus .

# Installa i pacchetti richiesti con pip senza usare cache
RUN micromamba run -n scenicplus pip install --no-cache-dir .

# Imposta l'ambiente Micromamba come predefinito all'avvio
CMD [ "/bin/bash", "-c", "micromamba activate scenicplus && exec bash" ]

