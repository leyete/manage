FROM ubuntu:eoan
MAINTAINER matterbeam <mb@matterbeam.com>

# Dockerfile with the instructions to build an image suitable for playing CTF challenges.
# You can specify a list of tools to be installed in the image using the TOOLS build
# argument (zsh, python and golang will be always installed). 

ENV LC_CTYPE C.UTF-8

COPY scripts/apt-get-install /usr/local/bin/apt-get-install
RUN chmod +x /usr/local/bin/apt-get-install

RUN dpkg --add-architecture i386 && \
    apt-get-install build-essential libtool g++ gcc curl wget automake autoconf \
    git unzip p7zip-full sudo ca-certificates strace ltrace ruby-dev libssl-dev \
    zsh libffi-dev libc6:i386 libncurses5:i386 libstdc++6:i386 gettext

RUN useradd -d /home/ctf -m -s /bin/zsh ctf
RUN echo "ctf ALL=NOPASSWD: ALL" > /etc/sudoers.d/ctf

RUN git clone https://github.com/mattrbeam/manage.git /home/ctf/tools && chown -R ctf:ctf /home/ctf/tools

WORKDIR /home/ctf/tools
USER ctf
ARG TOOLS
ENV PATH="/home/ctf/tools/bin:${PATH}"
ENV PY_INTERPRETER="/home/ctf/tools/bin/python3"
RUN manage -s install zsh python golang $TOOLS && manage link -osm zsh python golang $TOOLS

WORKDIR /home/ctf
