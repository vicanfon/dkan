# DKAN Docker Setup

This directory contains a Docker Compose configuration for running DKAN (Drupal Open Data Catalog) in a containerized environment.

## Services Included

- **web**: Drupal 10 with Apache, PHP and all required extensions
- **db**: MySQL 8.0 database server
- **phpmyadmin**: Web-based MySQL administration tool
- **mailhog**: Email testing tool (captures all outgoing emails)
- **redis**: Redis cache server (optional, for performance)

## Prerequisites

- Docker Engine 20.10 or higher
- Docker Compose V2 or higher
- At least 4GB of available RAM

## Quick Start

### 1. Build and start the containers

```bash
docker-compose up -d
```

This will:
- Build the custom Drupal image with all required PHP extensions
- Start MySQL, PHPMyAdmin, Mailhog, and Redis
- Create necessary volumes for persistent data
- Automatically set up proper file permissions

### 2. Install Drupal

You'll need to install Drupal first, then enable DKAN. Access the web container:

```bash
docker-compose exec web bash
```

Inside the container, you can use Composer to create a Drupal project:

```bash
# Install Drupal using Composer (if not already installed)
composer create-project drupal/recommended-project:^10 /tmp/drupal
# Copy files to the web root
cp -r /tmp/drupal/* /var/www/html/
# Set permissions
chown -R www-data:www-data /var/www/html
```

### 3. Install Drupal via Web UI

Navigate to `http://localhost:8080` and follow the Drupal installation wizard:

- **Database Configuration**:
  - Database type: MySQL, MariaDB, or equivalent
  - Database name: `drupal`
  - Database username: `drupal`
  - Database password: `drupal`
  - Host: `db`
  - Port: `3306`

**If you encounter a permissions error** during installation (e.g., "The directory sites/default/files is not writable"), run this in a new terminal:

```bash
docker-compose exec web bash /var/www/html/modules/contrib/dkan/scripts/fix-permissions.sh
```

Then refresh your browser and continue the installation.

### 4. Enable DKAN

After Drupal installation, you can use the installation script:

```bash
docker-compose exec web bash
cd /var/www/html
bash modules/contrib/dkan/scripts/install-dkan.sh
```

Or install manually:

```bash
docker-compose exec web bash
cd /var/www/html
# Install DKAN dependencies
composer require getdkan/dkan
# Enable DKAN
drush en dkan -y
# Clear cache
drush cr
```

### 5. Access DKAN

Once installed, access your DKAN data catalog at:
- **Main site**: http://localhost:8080
- **DKAN API**: http://localhost:8080/api/1
- **Dataset Search**: http://localhost:8080/search
- **Metastore API**: http://localhost:8080/api/1/metastore/schemas

**Optional - Add Sample Content**:

```bash
docker-compose exec web drush en sample_content -y
docker-compose exec web drush dkan:sample-content:create
```

## Access Points

- **Drupal site**: http://localhost:8080
- **PHPMyAdmin**: http://localhost:8081
  - Server: db
  - Username: drupal
  - Password: drupal
- **Mailhog** (email testing): http://localhost:8025
- **MySQL**: localhost:3306
- **Redis**: localhost:6379

## Useful Commands

### Start containers
```bash
docker-compose up -d
```

### Stop containers
```bash
docker-compose stop
```

### Restart containers
```bash
docker-compose restart
```

### View logs
```bash
docker-compose logs -f
# Or for specific service
docker-compose logs -f web
```

### Access web container shell
```bash
docker-compose exec web bash
```

### Access database container
```bash
docker-compose exec db bash
# Or connect to MySQL directly
docker-compose exec db mysql -u drupal -pdrupal drupal
```

### Run Drush commands
```bash
docker-compose exec web drush status
docker-compose exec web drush cr  # Clear cache
docker-compose exec web drush updb -y  # Run database updates
```

### Run Composer commands
```bash
docker-compose exec web composer install
docker-compose exec web composer update
```

### Import database
```bash
docker-compose exec -T db mysql -u drupal -pdrupal drupal < backup.sql
```

### Export database
```bash
docker-compose exec db mysqldump -u drupal -pdrupal drupal > backup.sql
```

## Volumes

Persistent data is stored in Docker volumes:

- `db_data`: MySQL database files
- `drupal_files`: Uploaded files and media
- `drupal_vendor`: Composer dependencies
- `drupal_web`: Drupal web root

## Environment Variables

You can customize the setup by modifying the `docker-compose.yml` file. Key environment variables:

- `MYSQL_ROOT_PASSWORD`: MySQL root password (default: root)
- `MYSQL_DATABASE`: Database name (default: drupal)
- `MYSQL_USER`: Database user (default: drupal)
- `MYSQL_PASSWORD`: Database password (default: drupal)
- `PHP_MEMORY_LIMIT`: PHP memory limit (default: 512M)
- `PHP_MAX_EXECUTION_TIME`: Max execution time (default: 300)

## Troubleshooting

### Container fails to start

Check logs:
```bash
docker-compose logs web
```

### Database connection issues

Ensure the database is healthy:
```bash
docker-compose ps
```

Wait for the database to be fully started before accessing Drupal.

### Permission issues

Fix permissions:
```bash
docker-compose exec web chown -R www-data:www-data /var/www/html/sites/default/files
docker-compose exec web chmod -R 775 /var/www/html/sites/default/files
```

### Clear all data and start fresh

```bash
docker-compose down -v
docker-compose up -d
```

**Warning**: This will delete all data including the database!

## Production Considerations

This setup is intended for development. For production use, consider:

1. Using environment variables file (`.env`) for sensitive data
2. Setting up proper SSL/TLS certificates
3. Configuring production-ready PHP settings
4. Implementing proper backup strategies
5. Using secrets management
6. Hardening security settings
7. Setting up monitoring and logging

## Additional Resources

- [DKAN Documentation](https://dkan.readthedocs.io/)
- [Drupal Docker Documentation](https://www.drupal.org/docs/official_drupal_docker_image)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
