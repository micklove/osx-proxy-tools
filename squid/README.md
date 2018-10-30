## Running a local proxy (docker)

### Use squid, in a docker container, with parent proxy (cache_peer)

#### Build - with docker-compose (preferred)

    docker-compose build

Ensure the runtime environment vars above are available in the shell.
e.g.

#### Run - with docker compose

    source ./add-proxy-config-to-env.sh ../config-file

    docker-compose up -d
    
or

```bash
source ./add-proxy-config-to-env.sh ../proxy-config.json  && docker-compose up -d
```

#### Stop
    
    docker-compose down


#### Read squid logs - with human readable timestamp
```bash
cat squid-access.log | perl -p -e 's/^([0-9]*)/"[".localtime($1)."]"/e'
```

or 

```bash
docker exec \
  -it $(docker ps --filter ancestor="ml/squidproxy-compose:latest" -q) \
   tail -f /var/log/squid/squid-access.log \
   | perl -p -e 's/^([0-9]*)/"[".localtime($1)."]"/e'
```

#### References
+ https://realpython.com/primer-on-jinja-templating/
+ https://github.com/kolypto/j2cli
+ https://www.commandlinefu.com/commands/view/8784/read-squid-logs-with-human-readable-timestamp

