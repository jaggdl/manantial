## Local development
### Make certificates
1. Install mkcert on your local machine:
```bash
brew install mkcert nss
```

2. Create a local certificate authority (CA):
```bash
mkcert -install
```

3. Create a local certificate authority (CA):
```bash
mkdir certificates
mkcert -key-file certificates/jaggdl.dev.key -cert-file certificates/jaggdl.dev.crt jaggdl.dev
mkcert -key-file certificates/chano.dev.key -cert-file certificates/chano.dev.crt chano.dev
mkcert -key-file certificates/memo.dev.key -cert-file certificates/memo.dev.crt memo.dev
```

(Need to figure out why i need to do this)
3.1 Add the following to `/etc/hosts`:
```
127.0.0.1 jaggdl.dev
127.0.0.1 chano.dev
127.0.0.1 memo.dev
```

4. Export the local CA certificate using mkcert:
```bash
mkcert -CAROOT
```

5. Copy `rootCA.pem` to `./cerfiticates`

### Build and run Docker
```bash
docker compose up --build
```

## Restart nginx with passenger instalation
```bash
sudo kill $(cat /opt/nginx/logs/nginx.pid)
sudo /opt/nginx/sbin/nginx
```
