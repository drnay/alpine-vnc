FROM alpine:edge

ARG USERNAME=vnc

ENV DISPLAY :0
ENV RESOLUTION 1600x900x24

RUN apk --update --no-cache add supervisor x11vnc xvfb \
	fluxbox openssh-server

# Run as a non-root
RUN addgroup -g 10001 -S $USERNAME \
    && adduser -S -s /bin/sh -G $USERNAME -D -h /home/$USERNAME -u 10000 $USERNAME

COPY supervisord.conf /etc/supervisor/conf.d/

RUN rm -rf /apk /tmp/* /var/cache/apk/*

EXPOSE 2222

WORKDIR /home/$USERNAME

RUN --mount=type=secret,id=authorized_keys mkdir -p /home/$USERNAME/.ssh \
    && chmod 700 /home/$USERNAME/.ssh \
    && cp /run/secrets/authorized_keys /home/$USERNAME/.ssh/ \
    && chmod 600 /home/$USERNAME/.ssh/authorized_keys

RUN echo x11vnc -usepw -localhost -rfbport 5900 -display $DISPLAY \$@ > /home/$USERNAME/runvnc.sh \
    && chmod +x /home/$USERNAME/runvnc.sh
RUN mkdir -p /home/$USERNAME/.vnc
RUN --mount=type=secret,id=passwd cat /run/secrets/passwd | x11vnc -storepasswd /home/$USERNAME/.vnc/passwd
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME

USER $USERNAME

COPY --chown=$USERNAME sshd_config /home/$USERNAME/etc/ssh/

# Persist generated host keys
VOLUME /home/$USERNAME/etc/ssh

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
