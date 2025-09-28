FROM ubuntu:24.04

ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       systemd \
       systemd-sysv \
       openssh-server \
       sudo \
       python3 \
       python3-pip \
       python3-apt \
       iproute2 \
       net-tools \
       curl \
       cron \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH for password-based access suitable for ephemeral testing
RUN mkdir -p /var/run/sshd \
    && sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && echo 'ClientAliveInterval 120' >> /etc/ssh/sshd_config \
    && echo 'ClientAliveCountMax 30' >> /etc/ssh/sshd_config

# Create a dedicated ansible user with passwordless sudo for testing
RUN useradd -m -s /bin/bash ansible \
    && echo 'ansible:ansible' | chpasswd \
    && usermod -aG sudo ansible \
    && printf 'ansible ALL=(ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/ansible \
    && chmod 0440 /etc/sudoers.d/ansible

# Set root password for direct access when required
RUN echo 'root:root' | chpasswd

EXPOSE 22

VOLUME ["/sys/fs/cgroup", "/run", "/tmp"]

STOPSIGNAL SIGRTMIN+3

CMD ["/sbin/init"]
