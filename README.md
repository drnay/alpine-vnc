# alpine-vnc
Minimal non-root xvfb+fluxbox+openssh+x11vnc


## Build container with VNC password from the 'passwd' file
```
docker build -t alpine-vnc --secret id=passwd,src=passwd --secret id=authorized_keys,src=$HOME/.ssh/id_rsa.pub .
```
## Run it
```
docker run -d -p 2222:2222 --name alpine-vnc alpine-vnc
```
## Tunnel via ssh
```
ssh -t -L 5900:localhost:5900 -i ~/.ssh/id_rsa vnc@localhost -p 2222 ./runvnc.sh -q
```
