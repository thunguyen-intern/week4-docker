FROM ubuntu:20.04

# Set environment variables
ENV ODOO_VERSION 15.0
ENV ODOO_USER odoo
ENV DEBIAN_FRONTEND noninteractive


# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends strace curl ca-certificates python3 python3-pip python3-dev libxml2-dev libpq-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev build-essential git libssl-dev libffi-dev libjpeg-dev libblas-dev libatlas-base-dev wkhtmltopdf nodejs npm sudo wget gnupg2

RUN apt-get update && apt-get install -yq lsb-release \
    && strace wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
    && apt-get install -yq postgresql-12 postgresql-client-12

# Install Node.js dependencies
RUN apt-get install -y npm \
    && npm install -g less less-plugin-clean-css
    # && ln -s /usr/bin/nodejs /usr/bin/node

# Create a new user and group for Odoo
RUN useradd -ms /bin/bash ${ODOO_USER}

# Download Odoo 15 source code
RUN cd /opt && git clone --depth 1 --branch ${ODOO_VERSION} https://github.com/odoo/odoo.git

ADD config/odoo/odoo.conf /etc/

# Install Python dependencies
RUN pip3 install -r /opt/odoo/requirements.txt

RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_amd64.deb
RUN dpkg -i dumb-init_*.deb

RUN chmod -R 777 /opt/odoo && chown -R odoo:odoo /opt/odoo
RUN mkdir /var/lib/odoo && chown -R odoo: /var/lib/odoo

ADD config/odoo/odoo.conf /opt/odoo/

# Expose Odoo ports
EXPOSE 8069 8071 8072

# USER root
# RUN apt-get update && \
#     apt-get upgrade -y && \
#     apt-get install -y --no-install-recommends iptables && \
#     sudo iptables -F && \
#     apt-get clean    

ADD wait-for-psql.py /usr/local/bin/

# Start Odoo
USER ${ODOO_USER}
# WORKDIR /opt/odoo
# CMD ./odoo-bin

ENTRYPOINT [ "/opt/odoo/odoo-bin" ]
CMD ["-c","/etc/odoo.conf"]