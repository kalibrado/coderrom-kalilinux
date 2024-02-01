FROM kalilinux/kali-rolling

LABEL org.label-schema.name='Kali Linux' \
      org.label-schema.description='Official Kali Linux docker image' \
      org.label-schema.usage='https://www.kali.org/news/official-kali-linux-docker-images/' \
      org.label-schema.url='https://www.kali.org/' \
      org.label-schema.vendor='Offensive Security' \
      org.label-schema.schema-version='1.0' \
      org.label-schema.docker.cmd='docker run --rm kalilinux/kali-linux-docker' \
      org.label-schema.docker.cmd.devel='docker run --rm -ti kalilinux/kali-linux-docker' \
      org.label-schema.docker.debug='docker logs $CONTAINER' \
      io.github.offensive-security.docker.dockerfile="Dockerfile" \
      io.github.offensive-security.license="GPLv3"

RUN echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" > /etc/apt/sources.list && \
echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free" >> /etc/apt/sources.list

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y && apt-get dist-upgrade -y

RUN apt-get install -y \
net-tools \
kali-desktop-xfce \
git \
x11vnc \
xvfb \
wget \
python3 \
python3-numpy \
unzip \
menu && \
cd /root && git clone https://github.com/kanaka/noVNC.git && \
cd noVNC/utils && git clone https://github.com/kanaka/websockify websockify && \
cd /root

RUN cat <<EOF > /root/startup.sh 
#!/bin/bash
export DISPLAY=:1
Xvfb :1 -screen 0 1600x900x16 &
sleep 5
xfce4-session&
x11vnc -display :1 -nopw -listen localhost -xkb -forever &
cd /root/noVNC && ln -s vnc_auto.html index.html && ./utils/launch.sh --vnc localhost:5900
EOF

RUN chmod 0755 /root/startup.sh  && \
apt-get autoremove && \
rm -rf /var/lib/apt/lists/*


CMD ["sh",  "/root/startup.sh"]
