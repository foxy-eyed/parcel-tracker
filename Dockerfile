FROM ruby:3.2.2

WORKDIR /usr/src/app

RUN bundle config --global frozen 1
COPY Gemfile Gemfile.lock ./
RUN bundle check || bundle install
COPY . .

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
