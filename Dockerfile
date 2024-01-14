# Use an official Ubuntu 22.04 image as the base
FROM ubuntu:22.04

# Install necessary utilities
RUN apt update
RUN apt install -y openssh-client curl git tmux neovim rustc cargo ripgrep
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# # Set up Vim, Tmux, and Bash configurations
# RUN ln -s /root/proj/dots/vim/.vimrc /root/.vimrc && \
#     ln -s /root/proj/dots/tmux/.tmux.conf /root/.tmux.conf && \
#     ln -s /root/proj/dots/bash/.bashrc /root/.bashrc

# Set the user as the active user
ARG USER_NAME=shantanu
RUN useradd -ms /bin/bash $USER_NAME

# Set the home dir
ARG HOME_DIR="/home/${USER_NAME}"
ARG PROJ_DIR="/home/${USER_NAME}/proj"

# Set the working directory within the container
WORKDIR $HOME_DIR

# Create directory for projects
RUN mkdir -p $PROJ_DIR
RUN mkdir -p $HOME_DIR/.ssh

# Set up SSH key for Git access
COPY "./github" $HOME_DIR/.ssh/
RUN chown -R $USER_NAME:$USER_NAME $HOME_DIR
RUN chmod 700 $HOME_DIR/.ssh
RUN chmod 600 $HOME_DIR/.ssh/github

USER $USER_NAME

# Clone git repositories
RUN eval "$(ssh-agent -s)" && \
    ssh-add $HOME_DIR/.ssh/github && \
    git config --global core.sshCommand "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" && \
    git clone git@github.com:8hantanu/dots.git "${PROJ_DIR}/dots" && \
    eval "$(ssh-agent -k)"

# Set the bash prompt to reflect the username and machine name
RUN echo "export PS1='\u:\w\$ '" >> ~/.bashrc

# Set the entrypoint command to launch Bash
CMD ["/bin/bash"]
