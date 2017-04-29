FROM ubuntu:12.04

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update \
        && apt-get upgrade \
        && apt-get install -y --no-install-recommends \
          curl \
          python-gevent \
          python-pip \
          python-pyinotify \
          python-renderpm \
          python-support \
        && curl -o wkhtmltox.deb -SL http://nightly.odoo.com/deb/precise/wkhtmltox-0.12.1_linux-precise-amd64.deb \
        && echo '74abae2c06c49109a8724717e948e5c532cad226 wkhtmltox.deb' | sha1sum -c - \
        && dpkg --force-depends -i wkhtmltox.deb \
        && apt-get -y install -f --no-install-recommends \
        && pip install psycogreen==1.0

# Install Odoo
ENV ODOO_VERSION 7.0
ENV ODOO_RELEASE 20170329
RUN set -x; \
        curl -o odoo.deb -SL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/openerp_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
        && echo '9ba26267b23a3204a6d8945ae8deb31339dd16c5 odoo.deb' | sha1sum -c - \
        && dpkg --force-depends -i odoo.deb \
        && apt-get update \
        && apt-get -y install -f --no-install-recommends \
        && rm -rf /var/lib/apt/lists/* odoo.deb

# Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN mkdir -p /mnt/extra-addons \
        && chown -R odoo /mnt/extra-addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]
