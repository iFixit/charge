FROM fedora:43
MAINTAINER "Daryl Metzler"

RUN dnf -y install \
  ImageMagick \
  file \
  gcc \
  make \
  pngquant \
  redhat-rpm-config \
  ruby \
  ruby-devel \
  rubygem-bundler

WORKDIR /opt/charge

COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install --without test development

COPY . .

ENV CHARGE_PORT=8881
ENV WEB_CONCURRENCY=0
ENV PUMA_MAX_THREADS=4
EXPOSE ${CHARGE_PORT}

ENTRYPOINT ruby charge.rb
