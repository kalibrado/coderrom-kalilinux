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

RUN apt-get install -y  novnc x11vnc net-tools kali-desktop-xfce git \
wget \
python3 \
python3-numpy \
unzip curl

RUN cat <<EOF > /root/startup.sh 
#!/bin/bash
x11vnc -display :0 -autoport -localhost -nopw -bg -xkb -ncache -ncache_cr -quiet -forever

EOF

RUN chmod 0755 /root/startup.sh  && \
apt-get autoremove && \
rm -rf /var/lib/apt/lists/*


CMD ["sh",  "/root/startup.sh"]
