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
        && dpkg --force-depends -i wkhtmltox.deb \
        && apt-get -y install -f --no-install-recommends \
        && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb \
        && pip install psycogreen==1.0

#&& echo '74abae2c06c49109a8724717e948e5c532cad226 wkhtmltox.deb' | sha1sum -c - \

# Install Odoo
ENV ODOO_VERSION 7.0
ENV ODOO_RELEASE 20170329
RUN set -x; \
        curl -o odoo.deb -SL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/openerp_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
        && dpkg --force-depends -i odoo.deb \
        && apt-get update \
        && apt-get -y install -f --no-install-recommends \
        && rm -rf /var/lib/apt/lists/* odoo.deb
        
#&& echo '9ba26267b23a3204a6d8945ae8deb31339dd16c5 odoo.deb' | sha1sum -c - \

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./openerp-server.conf /etc/odoo/
RUN chown odoo /etc/odoo/openerp-server.conf

# Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN mkdir -p /mnt/extra-addons \
        && chown -R odoo /mnt/extra-addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071

# Set the default config file
ENV OPENERP_SERVER /etc/odoo/openerp-server.conf

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["openerp-server"]
