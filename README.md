# alpine-vnc
Minimal non-root xvfb+fluxbox+openssh+x11vnc

## Build
```
docker build -t alpine-vnc .
```
## Deploy
```
docker stack deploy -c docker-compose.yml alpine-vnc
```
## Tunnel via ssh
```
ssh -t -L 5900:localhost:5900 vnc@localhost -p 2222 ./runvnc.sh -q
```
