## Running a local proxy (docker)

### Use squid, in a docker container, with parent proxy (cache_peer)

#### Build - with docker-compose (preferred)

    docker-compose build

Ensure the runtime environment vars above are available in the shell.
e.g.

#### Run - with docker compose

    source ./add-proxy-config-to-env.sh ../config-file

    docker-compose up -d

#### Stop
    
    docker-compose down




#### References
https://realpython.com/primer-on-jinja-templating/
https://github.com/kolypto/j2cli
