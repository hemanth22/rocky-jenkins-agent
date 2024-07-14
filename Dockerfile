FROM quay.io/hemanth22/rockylinux9:9

# Install necessary packages
RUN yum -y update && \
    yum -y install java-17-openjdk wget git sudo && \
    yum clean all

# Install Jenkins agent
RUN mkdir -p /home/jenkins && \
    wget -q -O /usr/local/bin/jenkins-agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/4.10/remoting-4.10.jar && \
    chmod +x /usr/local/bin/jenkins-agent.jar

# Set up Jenkins agent user
RUN useradd -m -d /home/jenkins -s /bin/bash jenkins

# Give Jenkins user passwordless sudo privileges
RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set the user to jenkins
USER jenkins
WORKDIR /home/jenkins

# Entry point for Jenkins agent
ENTRYPOINT ["java", "-jar", "/usr/local/bin/jenkins-agent.jar"]
