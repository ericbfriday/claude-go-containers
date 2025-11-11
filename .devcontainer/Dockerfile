# Use the latest official Go image
FROM golang:latest

# Install necessary tools and dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    build-essential \
    jq \
    starship \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

# Install Claude CLI (latest version)
# The Claude CLI is distributed via npm, so we need Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Claude CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Install SST OpenCode CLI - The AI coding agent for the terminal
RUN npm install -g opencode-ai@latest

# Install Go tools that are commonly used
RUN go install golang.org/x/tools/gopls@latest \
    && go install github.com/go-delve/delve/cmd/dlv@latest \
    && go install honnef.co/go/tools/cmd/staticcheck@latest \
    && go install golang.org/x/tools/cmd/goimports@latest

# Set up Go environment
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:$PATH

# Switch to non-root user
USER $USERNAME

RUN echo 'eval "$(starship init bash)"' >> ~/.bashrc
RUN starship preset pastel-powerline -o ~/.config/starship.toml

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
