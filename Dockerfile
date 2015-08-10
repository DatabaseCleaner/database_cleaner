FROM ubuntu:14.04.1
# NOTE: This Dockerfile is in the current state only for development purpose!

# make sure rvm and ruby 2.2.2 are in PATH
ENV PATH=/usr/local/rvm/bin:/usr/local/rvm/rubies/ruby-2.2.2/bin:$PATH
ENV DEBIAN_FRONTEND noninteractive

# create /gem folder and set it as workdir
RUN mkdir /gem
WORKDIR /gem

# update and upgrade packages
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
  curl \
	git \
	&& apt-get clean

# install rvm
RUN command curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN \curl -L https://get.rvm.io | bash -s stable

# install rvm requirements and ruby 2.2.2
RUN rvm requirements
RUN rvm install 2.2.2
RUN gem install bundler --no-ri --no-rdoc

# install database clients and other userful packages
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
	mysql-client \
	mysql-common \
	libmysqlclient-dev \
	libmysqlclient18 \
	sqlite \
	postgresql-9.3 \
	postgresql-9.3-dbg \
	postgresql-client-9.3 \
	postgresql-contrib-9.3 \
	postgresql-client-common \
	postgresql-server-dev-9.3 \
	libpq5 \
	libpq-dev \
	telnet \
  socat \
	&& apt-get clean

ADD ./ /gem/
COPY ./db/sample.config.yml /gem/db/config.yml
RUN ruby -e "File.open('db/config.yml', 'r+'){|f| f.write(f.read.gsub(/username: root\n  password:/, \"username: root\n  password: secret\"))}"

# install gem requirements
RUN bundle install
