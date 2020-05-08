FROM ruby:2.6.5-alpine

RUN apk add build-base

RUN gem update --system && \
    gem install bundler:2.0.2

RUN mkdir /app
WORKDIR /app
ADD Gemfile* /app/
RUN bundle install

EXPOSE 4567
COPY . /app
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]
