## Restart nginx with passenger instalation
```bash
sudo kill $(cat /opt/nginx/logs/nginx.pid)
sudo /opt/nginx/sbin/nginx
```
