FROM ruby:2.6

SHELL ["/bin/bash", "-c", "-l"]

RUN set -x && curl -sL https://deb.nodesource.com/setup_14.x | bash -

RUN set -x && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

RUN set -x && apt-get update -qq && apt-get install -yq nodejs yarn vim default-mysql-client

# rbenvのインストール
RUN git clone https://github.com/sstephenson/rbenv.git ~/.rbenv && \
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile && \
    echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

# rubyのインストール
RUN source ~/.bash_profile  && \
    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build && \
    rbenv install 2.7.6 && \
    rbenv global 2.7.6

# bundlerのインストール
RUN gem install bundler -v 1.17.2
RUN gem install bundler -v 2.2.17

RUN mkdir /app
WORKDIR /app
ADD rails_app/ /app
RUN rbenv local system
RUN bundle _1.17.2_ install

# Add a script to be executed every time the container starts.
ADD ./forDocker/rails/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
