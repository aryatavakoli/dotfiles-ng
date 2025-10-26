FROM ubuntu:22.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies (including zsh for testing)
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    procps \
    file \
    zsh \
    sudo \
    rsync \
    && rm -rf /var/lib/apt/lists/*

# Create a test user with sudo privileges
RUN useradd -m -s /bin/zsh testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER testuser
WORKDIR /home/testuser

# Copy chezmoi dotfiles
COPY --chown=testuser:testuser . /home/testuser/dotfiles-src/

# Install chezmoi
RUN sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
ENV PATH="/home/testuser/.local/bin:$PATH"

# Configure chezmoi
RUN mkdir -p ~/.config/chezmoi && \
    echo '[data]' > ~/.config/chezmoi/chezmoi.toml && \
    echo '    name = "Test User"' >> ~/.config/chezmoi/chezmoi.toml && \
    echo '    email = "test@example.com"' >> ~/.config/chezmoi/chezmoi.toml

# Copy dotfiles to chezmoi source directory
RUN mkdir -p ~/.local/share/chezmoi && \
    rsync -a --exclude='.git' --exclude='*.md' --exclude='install.sh' --exclude='test-packages.sh' --exclude='Dockerfile.test' \
        /home/testuser/dotfiles-src/ ~/.local/share/chezmoi/ && \
    chmod +x ~/.local/share/chezmoi/.chezmoiscripts/*.tmpl 2>/dev/null || true

# Apply chezmoi dotfiles (this will run the onchange script)
RUN chezmoi apply -v

CMD ["/bin/zsh"]
