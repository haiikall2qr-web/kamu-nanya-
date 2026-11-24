FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install SSH server, Node.js 22, dan tools dasar
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    git \
    nano \
    tmux \
    ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && mkdir -p /var/run/sshd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Konfigurasi SSH agar bisa login root pakai password
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Buat script entrypoint agar password bisa diatur lewat Variables Railway (ROOT_PASSWORD)
RUN cat <<'EOF' > /entrypoint.sh
#!/bin/bash
PASS="${ROOT_PASSWORD:-thiskyro}"
echo "root:${PASS}" | chpasswd
exec /usr/sbin/sshd -D
EOF
RUN chmod +x /entrypoint.sh

WORKDIR /root

EXPOSE 22

CMD ["/entrypoint.sh"]
