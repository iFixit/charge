FROM fedora:latest
MAINTAINER "Daryl Metzler"

ADD . /opt/charge

WORKDIR /opt/charge

RUN dnf -y install ruby rubygem-bundler ImageMagick optipng \
   && bundle install --without test development

ENV CHARGE_PORT=8881

EXPOSE ${CHARGE_PORT}

ENTRYPOINT ruby charge.rb
