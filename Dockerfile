FROM python:3.9.1-buster


RUN apt-get update && apt-get install -y nginx

# Install PGP key and add HTTPS support for APT
RUN apt-get install -y dirmngr gnupg
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
RUN apt-get install -y apt-transport-https ca-certificates

# Add APT repository
RUN sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger buster main > /etc/apt/sources.list.d/passenger.list'
RUN apt-get update

# Install Passenger + Nginx module
RUN apt-get install -y libnginx-mod-http-passenger

WORKDIR /app
COPY requirements.txt /app/requirements.txt
RUN pip install  -r requirements.txt

COPY . /app

COPY ./nginx/apolloio.conf /etc/nginx/sites-enabled/default

# forward logs to stdout and stderr
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

CMD ["nginx", "-g", "daemon off;"]
