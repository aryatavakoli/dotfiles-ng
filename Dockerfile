FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    sudo \
    build-essential \
    file \
    procps \
    locales \
    zsh \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8

RUN useradd -m -s /bin/zsh testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

COPY --chown=testuser:testuser . /home/testuser/dotfiles/

ENV USER_NAME="Test User" \
    USER_EMAIL="test@example.com" \
    NONINTERACTIVE=1

RUN cd /home/testuser/dotfiles && \
    chmod +x install.sh && \
    ./install.sh --force

CMD ["/bin/zsh", "-l"]
