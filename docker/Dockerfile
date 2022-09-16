FROM perl:5.36-slim-bullseye

ENV NINJASIGNATURE_HOME=/opt/NinjaSignature
ENV NINJASIGNATURE_USER=ninjasignature

# Install general dependencies

RUN apt update \
    && apt install -qy gcc

# Install NinjaSignature

RUN useradd -ms /bin/bash ${NINJASIGNATURE_USER} \
    && mkdir -p ${NINJASIGNATURE_HOME}

COPY Makefile ${NINJASIGNATURE_HOME}/Makefile
COPY ninjasignature.pl ${NINJASIGNATURE_HOME}
COPY lib/ ${NINJASIGNATURE_HOME}/lib/

RUN cd ${NINJASIGNATURE_HOME} \
    && make build \
    #&& make build-dev \
    && ln -s ${NINJASIGNATURE_HOME}/ninjasignature.pl /usr/local/bin/ninjasignature

USER ninjasignature
WORKDIR /home/ninjasignature

# Run NinjaSignature

CMD ["ninjasignature", "-h"]
