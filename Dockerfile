
# Use an official Ubuntu latest image as the base
FROM ubuntu:latest

# Install necessary utilities
RUN apt update
RUN apt install -y openssh-client curl tmux git
RUN apt install -y rustc cargo ripgrep
# RUN apt install -y python-dev python-pip python3-dev python3-pip

# Install build dependencies
RUN apt install -y build-essential cmake libtool libtool-bin autoconf automake pkg-config unzip gettext

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# Set the user as the active user
ARG USER_NAME=user
RUN useradd -ms /bin/bash $USER_NAME

# Set the home dir
ARG HOME_DIR="/home/${USER_NAME}"
ARG PROJ_DIR="/home/${USER_NAME}/proj"

# Set the working directory within the container
WORKDIR $HOME_DIR

# Create directory for projects
RUN mkdir -p $PROJ_DIR
RUN mkdir -p $HOME_DIR/.ssh
RUN mkdir -p $HOME_DIR/.config/nvim
RUN mkdir -p $HOME_DIR/.local/share/nvim/site/autoload

# Set up SSH key for Git access
ADD ".ssh/github" $HOME_DIR/.ssh/
RUN chown -R $USER_NAME:$USER_NAME $HOME_DIR
RUN chmod 700 $HOME_DIR/.ssh
RUN chmod 600 $HOME_DIR/.ssh/github

# Get rust-analyzer
RUN curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-linux -o /usr/local/bin/rust-analyzer && chmod +x /usr/local/bin/rust-analyzer

# Get chatgpt-cli
RUN curl -L https://github.com/kardolus/chatgpt-cli/releases/latest/download/chatgpt-linux-amd64 -o /usr/local/bin/hey && chmod +x /usr/local/bin/hey

# Clone Neovim repository and build
RUN git clone --branch v0.9.0 --depth 1 https://github.com/neovim/neovim.git /tmp/nvim && \
    cd /tmp/nvim && \
    make CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make install && \
    rm -rf /tmp/nvim

# Switch from root to user
USER $USER_NAME

# Clone git repositories
RUN eval "$(ssh-agent -s)" && \
    ssh-add $HOME_DIR/.ssh/github && \
    git config --global core.sshCommand "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" && \
    git clone git@github.com:8hantanu/dots.git "${HOME_DIR}/dots"

# Set up configurations
RUN ln -s $HOME_DIR/dots/.vimrc $HOME_DIR/.vimrc
RUN ln -s $HOME_DIR/dots/.tmux.conf $HOME_DIR/.tmux.conf
RUN ln -s $HOME_DIR/dots/.nvimrc $HOME_DIR/.config/nvim/init.vim

# Set git author
RUN git config --global user.name "Shantanu Mishra"
RUN git config --global user.email "dev@8hantanu.net"

# Set the bash prompt to reflect the username and machine name
RUN echo "export PS1='\u@dock:\w\$ '" >> $HOME_DIR/.bashrc

RUN echo 'if [ -z "$SSH_AUTH_SOCK" ] ; then' >> $HOME_DIR/.bashrc && \
    echo '    eval "$(ssh-agent -s)"' >> $HOME_DIR/.bashrc && \
    echo '    ssh-add ~/.ssh/github' >> $HOME_DIR/.bashrc && \
    echo 'fi' >> $HOME_DIR/.bashrc

# Set the entrypoint command to launch Bash
CMD ["/bin/bash"]
