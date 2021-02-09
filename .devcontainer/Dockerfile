FROM rocker/ml-verse:4.0.3-cuda11.1

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=docker
ARG USER_UID=2000
ARG USER_GID=$USER_UID
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
    && apt-get -y install libzip-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# install R packages needed for VSCode interaction and package management
RUN install2.r languageserver renv remotes
RUN installGithub.r nx10/httpgd

# install dot net core runtime for the R Tools plugin
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb \
    && dpkg -i /tmp/packages-microsoft-prod.deb

RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-transport-https \
    && apt-get -y install --no-install-recommends dotnet-sdk-3.1

# Needed for igraph
RUN apt-get update && apt-get install -y libglpk40

# install radian via python and pip3
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends python3-setuptools

RUN pip3 install radian

# copy the modified .Rprofile template to the renv cache
COPY library-scripts/.Rprofile-vscode /renv/.Rprofile-vscode
