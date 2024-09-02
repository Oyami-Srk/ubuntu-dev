# Arguments
ARG VERSION=latest

# Basements
FROM ubuntu:$VERSION

ARG BASEMENT_PACKAGES="ca-certificates tzdata locales git curl zsh file"
ARG ADDITIONAL_DEVELOPMENT_PACKAGES="httpie neovim build-essential cmake python3-dev python3-pip wrk htop tmux"

# Environments
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV LANG=en_US.utf8

# Use USTC mirrors
RUN sed -i 's#//.*.ubuntu.com#//mirrors.ustc.edu.cn#g' /etc/apt/sources.list.d/ubuntu.sources

# Update apt source and install necessary packages
RUN apt-get update \
    && apt-get install -y $BASEMENT_PACKAGES $ADDITIONAL_DEVELOPMENT_PACKAGES \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Timezone and locale
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Clone my dotfiles
RUN cd ~ \
    && git config --global init.defaultBranch master \
    && git init \
    && git remote add origin https://github.com/Oyami-Srk/dotfiles \
    && git pull origin master \
    && git config --local submodule..config/rime.url https://github.com/Oyami-Srk/rime-conf \
    && git submodule init \
    && git submodule update \
    && sed -i "$ s#proxy##g" ~/.config/env.d/01-proxy.sh
##&& git config --global url."https://github.com/Oyami-Srk".insteadOf "git@github.com:Oyami-Srk" \

# Initialize zinit and nvim plugins
RUN cat ~/.zshrc | sed 's/lucid wait//g;s/zinit light/zinit load/g;s/#.*$//g;/^zinit ice *$/d' > /tmp/zshrc \
    && sed -i '/^$/d' /tmp/zshrc \
    && zsh -c "TERM=xterm source /tmp/zshrc; nvim -c 'q'; rm -rf /tmp/*; exit 0"

RUN chsh -s /bin/zsh
CMD ["/bin/zsh"]
