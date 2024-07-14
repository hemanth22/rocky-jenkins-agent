FROM quay.io/hemanth22/rockylinux9:9

# Install necessary packages
RUN yum -y update && \
    yum -y install java-17-openjdk java-17-openjdk-devel fontconfig wget git sudo git git-lfs less patch && \
    yum clean all && \
    rm -rf /var/cache/yum

# Set up directories and environment variables for Jenkins agent
ENV AGENT_WORKDIR="/home/${user}/agent"

# Set timezone environment variable
ENV TZ=Etc/UTC

# Set LANG environment variable
ENV LANG=C.UTF-8

# Define Jenkins user and group
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

# Set up Jenkins agent user
RUN groupadd -g "${gid}" "${group}" && useradd -l -c "Jenkins user" -d /home/"${user}" -u "${uid}" -g "${gid}" -m "${user}" -s /bin/bash || echo "user ${user} already exists."

# Give Jenkins user passwordless sudo privileges
RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set up volumes and working directory
USER "${user}"
RUN mkdir -p /home/"${user}"/.jenkins && mkdir -p "${AGENT_WORKDIR}"
VOLUME /home/"${user}"/.jenkins
VOLUME "${AGENT_WORKDIR}"
WORKDIR /home/"${user}"

ARG VERSION=3256.v88a_f6e922152
ADD --chown="${user}":"${group}" "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar" /usr/share/jenkins/agent.jar
RUN chmod 0644 /usr/share/jenkins/agent.jar \
  && ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar

# Switch to root user temporarily to install additional tools or binaries
USER root

# Copy custom Jenkins agent script and set permissions
COPY jenkins-agent /usr/local/bin/jenkins-agent
RUN chmod +x /usr/local/bin/jenkins-agent \
    && ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

# Switch back to Jenkins user
USER ${user}

# Entry point for Jenkins agent with environment variables
ENTRYPOINT ["sh", "-c", "java -jar /usr/local/bin/jenkins-agent.jar -jnlpUrl $JENKINS_URL -secret $JENKINS_SECRET -name $JENKINS_AGENT_NAME"]
