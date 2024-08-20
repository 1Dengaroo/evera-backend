FROM ruby:3.1.2
RUN apt-get update -qq && apt-get install -y postgresql-client

ENV BUNDLER_VERSION=2.3.20
ENV INSTALL_PATH /app

RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

ADD Gemfile* $INSTALL_PATH/

ENV BUNDLE_GEMFILE $INSTALL_PATH/Gemfile
ENV BUNDLE_JOBS 2
ENV BUNDLE_PATH /gems

RUN gem install bundler -v $BUNDLER_VERSION
RUN bundle check || bundle install

ADD . $INSTALL_PATH
