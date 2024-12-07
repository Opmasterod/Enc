# Base Image 
FROM fedora:37

# 1. Setup home directory, non-interactive shell, and timezone
RUN mkdir -p /bot /tgenc && chmod 777 /bot
WORKDIR /bot
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Africa/Lagos
ENV TERM=xterm

# 2. Install Dependencies
RUN dnf -y update && \
    dnf -y install git aria2 bash xz wget curl pv jq python3-pip mediainfo psmisc procps-ng qbittorrent-nox && \
    if [[ "$(arch)" == "aarch64" ]]; then \
        dnf -y install gcc python3-devel; \
    fi && \
    python3 -m pip install --upgrade pip setuptools wheel

# 3. Install latest ffmpeg
RUN arch=$(arch | sed 's/aarch64/arm64/' | sed 's/x86_64/64/') && \
    wget -q https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n7.1-latest-linux${arch}-gpl-7.1.tar.xz && \
    tar -xvf ffmpeg-n7.1-latest-linux${arch}-gpl-7.1.tar.xz && \
    cp ffmpeg-n7.1-latest-linux${arch}-gpl-7.1/bin/* /usr/bin && \
    rm -rf ffmpeg-n7.1-latest-linux${arch}-gpl-7.1* 

# 4. Copy project files to the container
COPY . .

# 5. Install Python requirements
RUN pip3 install --no-cache-dir -r requirements.txt

# 6. Cleanup
RUN dnf clean all && \
    rm -rf /var/cache/dnf

# 7. Railway entry point - Railway assigns PORT dynamically
ENV PORT 3000
EXPOSE $PORT

# 8. Start bot
CMD ["bash", "run.sh"]
