FROM fedora:43
MAINTAINER "Daryl Metzler"

RUN dnf -y install ruby ruby-devel rubygem-bundler ImageMagick pngquant file gcc make redhat-rpm-config

WORKDIR /opt/charge

COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install --without test development

COPY . .

ENV CHARGE_PORT=8881
EXPOSE ${CHARGE_PORT}

ENTRYPOINT ruby charge.rb
