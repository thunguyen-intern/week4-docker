# Deploy Odoo on Docker

## How to deploy Odoo on Dockerfile?
Write the Dockerfile as you install and set up Odoo provisionly. Then you create a network for Odoo:
``` bash
$ docker network create -d bridge odoo
```

Write the configuration file for Odoo:
``` bash
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
Create a path to start in ENTRYPOINT and CMD:
``` bash
ENTRYPOINT [ "/opt/odoo/odoo-bin" ]
CMD ["-c","/etc/odoo.conf"]
```

Then run the command to start Postgres database:
``` bash
docker run --name db --network=odoo -t postgres:13
```

Run the command to start Odoo:
``` bash
docker run --name odoo -p 8069:8069 --link db:db --network=odoo -t odoo
```

## Write docker-compose.yml
