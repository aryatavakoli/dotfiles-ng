FROM ubuntu:latest

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal dependencies needed for install.sh to work
# (mimicking a fresh machine)
RUN apt-get update && apt-get install -y \
    curl \
    git \
    sudo \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create a test user with sudo privileges (no password)
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

# Copy the entire dotfiles repo
COPY --chown=testuser:testuser . /home/testuser/dotfiles/

# Run the install.sh script with non-interactive environment variables
# This tests the script as if it were a real installation
ENV USER_NAME="Test User" \
    USER_EMAIL="test@example.com"

RUN cd /home/testuser/dotfiles && \
    chmod +x install.sh && \
    bash -c 'echo "y" | ./install.sh'

CMD ["/bin/zsh"]
