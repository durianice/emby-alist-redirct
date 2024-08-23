```bash
#install
sudo bash -c "$(curl -sL https://raw.githubusercontent.com/durianice/emby-alist-redirct/main/install.sh)"

# setup nginx
cd emby-alist-redirct
bash setup.sh

cp docker-compose-nginx-emby.yml ./nginx_workdir/docker-compose.yml 
cd nginx_workdir
docker compose up -d

# open ip:port
# view logs
tail -f ./nginx/logs/error.log
```
