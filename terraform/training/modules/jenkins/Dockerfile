FROM jenkins/jenkins:lts

USER root

# Install Docker CLI and useful utilities
RUN apt-get update \
    && apt-get install -y \
        docker.io \
        curl \
        git \
        jq \
        unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install .NET 8 SDK via Microsoft's install script - avoids needing to match
# the base image's Debian release to a specific packages.microsoft.com apt repo.
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH="${DOTNET_ROOT}:${PATH}"
# Avoids a SIGABRT crash on startup when ICU isn't present/compatible on this
# base image - fine for CI/build purposes; only matters if pipeline code
# depends on culture-specific formatting.
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
RUN curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh \
    && chmod +x /tmp/dotnet-install.sh \
    && /tmp/dotnet-install.sh --channel 8.0 --install-dir "${DOTNET_ROOT}" \
    && rm /tmp/dotnet-install.sh

# Verify .NET SDK installation
RUN dotnet --version \
    && dotnet --info

# Install Node.js via nvm, for the Angular pipeline (npm ci / npm run build).
# PATH points directly at the installed version's bin dir so `node`/`npm`
# work in any shell (Jenkins `sh` steps don't source nvm.sh automatically).
ENV NVM_DIR=/usr/local/nvm
ENV NODE_VERSION=20
RUN mkdir -p "${NVM_DIR}" \
    && curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && . "${NVM_DIR}/nvm.sh" \
    && nvm install "${NODE_VERSION}" \
    && nvm alias default "${NODE_VERSION}" \
    && ln -s "${NVM_DIR}/versions/node/$(nvm version default)" "${NVM_DIR}/versions/node/default"
ENV PATH="${NVM_DIR}/versions/node/default/bin:${PATH}"

# Verify Node.js installation
RUN node --version \
    && npm --version

# Copy Jenkins plugins list
COPY config/plugins.txt /usr/share/jenkins/ref/plugins.txt

# Install Jenkins plugins
RUN jenkins-plugin-cli \
    --plugin-file /usr/share/jenkins/ref/plugins.txt

# Copy Jenkins Configuration as Code
COPY config/jenkins.yaml /usr/share/jenkins/ref/jenkins.yaml

# Jenkins Configuration as Code
ENV CASC_JENKINS_CONFIG=/usr/share/jenkins/ref/jenkins.yaml

# Skip the initial Jenkins setup wizard
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Keep root so Jenkins can access the mounted Docker socket.
USER root
