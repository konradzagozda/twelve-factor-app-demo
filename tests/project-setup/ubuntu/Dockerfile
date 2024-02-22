FROM cruizba/ubuntu-dind:focal-25.0.3

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y software-properties-common git curl build-essential \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl && \
    apt-add-repository --yes --update ppa:ansible/ansible && \
    apt-get install -y ansible && \
    ansible --version && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Install kind
RUN if [ "$(uname -m)" = "x86_64" ]; then \
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-arm64; \
    fi && \
    chmod +x ./kind && \
    mv ./kind /usr/local/bin/kind

WORKDIR /home/root

# Install pyenv
RUN git clone https://github.com/yyuu/pyenv.git .pyenv

ENV HOME /home/root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

# Install python 3.11
RUN pyenv install 3.11.8 && \
    pyenv global 3.11.8 && \
    pyenv rehash

# Install poetry
ENV POETRY_VERSION=1.6.1
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH $HOME/.local/bin:$PATH

# Copy files
COPY . ./project 
COPY ./tests/project-setup/ubuntu/entrypoint.sh /usr/local/bin/
