# Wordpress in Docker

Wordpress in Docker makes it easy to quickly spin up an entire stack for
developing wordpress locally.

# Prerequisites

- [Docker][docker-install]

# Start up wordpress

    docker-compose up -d

Then visit `http://localhost:8080/` to set up a new wordpress install.  It
should already be connected to a database.  You'll be prompted to finish setting
up wordpress.

# Shut down wordpress

To shut down wordpress and still keep your data run:

    docker-compose down

To shut down wordpress and delete all wordpress data:

    docker-compose down -v

To shut down wordpress, delete all data, and delete the machine images:

    docker-compose down -v --rmi all

# Docker image environment variables

> Note: this customization is not recommended.  Secure defaults will
> automatically be generated for all options.

[`docker-compose.yml`](docker-compose.yml) can be modified to provide initial
setup instructions such as initial passwords, user, and database customization.
Both the `mysql` service and the `wordpress` service defined in
`docker-compose.yml` support initial setup.

```yaml
services:
  mysql:
    environment:
      INITIAL_ROOT_PASSWORD: "some password"
      WORDPRESS_USER: someuser
      WORDPRESS_PASSWORD: "some password"
      WORDPRESS_DATABASE: "some database"
  wordpress:
    environment:
      DATABASE_NAME: wordpress
      DATABASE_USER: wordpress
      DATABASE_PASSWORD: "some password"
      DATABASE_HOST: "some host"
      TABLE_PREFIX: "wp_"
      WORDPRESS_DEBUG: false
```

[docker-install]: https://docs.docker.com/install/
