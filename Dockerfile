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
ARG USERNAME=shantanu
RUN useradd -ms /bin/bash $USERNAME
USER $USERNAME

# Set the home dir
ARG HOME_DIR="/home/${USERNAME}"
ARG PROJ_DIR="/home/${USERNAME}/proj"

# Set the working directory within the container
WORKDIR $HOME_DIR

# Create directory for projects
RUN mkdir -p $PROJ_DIR
RUN mkdir -p $PROJ_DIR/.ssh

# Set up SSH key for Git access
COPY .ssh/github $HOME_DIR/.ssh/github
RUN chmod 600 $HOME_DIR/.ssh/github

# Clone dotfiles repository into /root/proj/dots
RUN git clone https://github.com/8hantanu/dots.git "${PROJ_DIR}/dots"

# Set the bash prompt to reflect the username and machine name
# RUN echo "export PS1='\u@cloud:\w\$ '" >> ~/.bashrc

# Set the entrypoint command to launch Bash
CMD ["/bin/bash"]


