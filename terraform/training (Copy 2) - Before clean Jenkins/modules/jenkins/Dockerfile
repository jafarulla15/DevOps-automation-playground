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

USER jenkins
