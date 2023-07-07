# Deploy Odoo on Docker

## How to deploy Odoo on Dockerfile?

Write the `Dockerfile` as you install and set up Odoo provisionly. Then you create a network for Odoo:

```bash
$ docker network create -d bridge odoo
```

Write the configuration file for Odoo:

```bash
[options]
admin_passwd = admin
; http_port = 8069
db_host = db
db_port = 5432
db_user = odoo
db_database = False
db_password = odoo
; proxy_mode = True
addons_path = /opt/odoo/addons
```

Create a path to start in `ENTRYPOINT` and `CMD`:

```bash
ENTRYPOINT [ "/opt/odoo/odoo-bin" ]
CMD ["-c","/etc/odoo.conf"]
```

Then run the command to start Postgres database:

```bash
docker run --name db -e POSTGRES_USER=odoo -e POSTGRES_PASSWORD=odoo -e POSTGRES_DB=db --network=odoo -t postgres:13
```

Run the command to start Odoo:

```bash
docker run --name odoo -p 8069:8069 -e POSTGRES_USER=odoo -e POSTGRES_PASSWORD=odoo -e POSTGRES_DB=db --link db:db --network=odoo -t odoo
```

## Write docker-compose.yml

Write `docker-compose.yml` for NGINX server (remember to expose port 80):

```yaml
nginx:
        build: .
        container_name: nginx
        image: nginx
        restart: always
        networks:
            - odoo-default
        ports:
            - 80:80
            - 443:443
        volumes:
            - ./config/nginx:/etc/nginx/conf.d
        depends_on:
            - odoo
        expose:
            - 80
```

Write for multiple Odoo servers (do not add `container_name`):

* In `docker-compose.yml`, we will deploy for multiple servers using scaling to create replicas. We would use the module `deploy` to scale:

```yaml
odoo:
        build: .
        # container_name: odoo
        image: odoo
        restart: always
        networks:
            - odoo-default
        volumes:
            - ./addons:/mnt/extra-addons
            - ./config/odoo:/etc/odoo
            - odoo-web-data:/var/lib/odoo
        links:
            - db:db
        ports:
            - "8070-8072:8069"
        depends_on:
            - db
        deploy:
            replicas: 3
```

* Or we can use command line:

```
$ docker compose up --scale odoo=${NUM1} nginx=${NUM2} ...
```

## High Availability
