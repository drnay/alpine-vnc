FROM alpine:edge

ARG USERNAME=vnc
ARG UID=10000
ARG GID=10001

ENV DISPLAY :0
ENV RESOLUTION 1600x900x24

RUN apk --update --no-cache add multirun x11vnc xvfb \
	fluxbox openssh-server \
	&& chmod a+x `which multirun` \
	&& rm -rf /apk /tmp/* /var/cache/apk/*

# Run as a non-root
RUN addgroup -g $GID -S $USERNAME \
    && adduser -S -s /bin/sh -G $USERNAME -D -h /home/$USERNAME -u $UID $USERNAME

EXPOSE 2222

USER $USERNAME

WORKDIR /home/$USERNAME

RUN echo x11vnc -usepw -localhost -rfbport 5900 \$@ > /home/$USERNAME/runvnc.sh \
    && chmod +x /home/$USERNAME/runvnc.sh

# Persist generated host keys
VOLUME /home/$USERNAME/etc/ssh

CMD ssh-keygen -A -f $PWD \
    && multirun -v \
    "Xvfb $DISPLAY -screen 0 $RESOLUTION -listen tcp -ac" \
    "fluxbox" \
    "/usr/sbin/sshd -Deq -p 2222 \
    -o AllowTcpForwarding=Yes \
    -h $PWD/etc/ssh/ssh_host_rsa_key \
    -h $PWD/etc/ssh/ssh_host_ecdsa_key \
    -h $PWD/etc/ssh/ssh_host_ed25519_key \
    "
