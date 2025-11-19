# DKAN Docker Setup - Complete Guide

This guide will walk you through setting up DKAN (Drupal Open Data Catalog) using Docker from start to finish.

## Table of Contents

- [What is DKAN?](#what-is-dkan)
- [Prerequisites](#prerequisites)
- [Architecture Overview](#architecture-overview)
- [Complete Installation Guide](#complete-installation-guide)
- [Accessing Your DKAN Site](#accessing-your-dkan-site)
- [Common Commands](#common-commands)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)

---

## What is DKAN?

DKAN is a **Drupal module** that turns Drupal into a powerful open data catalog platform. It provides:
- Data catalog functionality
- Dataset management
- API endpoints for data access
- Harvesting capabilities from external catalogs
- Data visualization and exploration tools

**Important**: DKAN is not a standalone application. You need to:
1. Install Drupal (the base CMS)
2. Install DKAN (the data catalog module)

---

## Prerequisites

Before you begin, ensure you have:

- **Docker Engine** 20.10 or higher
- **Docker Compose** V2 or higher
- At least **4GB of available RAM**
- A web browser

To verify Docker is installed:
```bash
docker --version
docker-compose --version
```

---

## Architecture Overview

This Docker setup includes:

- **web**: Drupal 10 with Apache, PHP, and all required extensions
- **db**: MySQL 8.0 database server
- **phpmyadmin**: Web-based MySQL administration tool
- **mailhog**: Email testing tool (captures all outgoing emails)
- **redis**: Redis cache server (optional, for performance)

**Ports Used**:
- `8080` - Drupal/DKAN website
- `8081` - PHPMyAdmin
- `8025` - Mailhog web interface
- `3306` - MySQL database
- `6379` - Redis

---

## Complete Installation Guide

### Step 1: Start the Docker Environment

Navigate to the DKAN project directory and start the containers:

```bash
# Stop any existing containers
docker-compose down

# Build the Docker images from scratch
docker-compose build --no-cache

# Start all containers in detached mode
docker-compose up -d
```

**What this does**:
- Builds a custom PHP/Apache image with Drupal requirements
- Starts MySQL database
- Starts PHPMyAdmin, Mailhog, and Redis
- Creates persistent volumes for data storage
- Automatically sets up file permissions

**Verify containers are running**:
```bash
docker-compose ps
```

You should see all services with status "Up" or "healthy".

---

### Step 2: Install Drupal (The Base CMS)

#### 2.1 Access the Installation Wizard

1. Open your web browser and go to: **http://localhost:8080**
2. You'll see the Drupal installation welcome screen

#### 2.2 Choose Language

- Select **English** (or your preferred language)
- Click **Save and continue**

#### 2.3 Select Installation Profile

- Choose **Standard** installation profile
- Click **Save and continue**

#### 2.4 Verify Requirements

Drupal will check system requirements. If everything is OK, you'll move to the next step automatically.

**If you see a permissions error** about `sites/default/files`:

Open a new terminal and run:
```bash
docker-compose exec web bash -c "mkdir -p /var/www/html/sites/default/files && chown -R www-data:www-data /var/www/html/sites/default/files && chmod -R 775 /var/www/html/sites/default/files"
```

Then refresh your browser and continue.

#### 2.5 Configure Database

This is the most important step! Enter these database credentials:

- **Database type**: MySQL, MariaDB, Percona Server, or equivalent
- **Database name**: `drupal`
- **Database username**: `drupal`
- **Database password**: `drupal`

Click **Advanced options** and enter:
- **Host**: `db`
- **Port number**: `3306`
- **Table name prefix**: (leave empty)

Click **Save and continue**

#### 2.6 Install Site

Drupal will now install modules and configure the database. This takes 2-5 minutes. Wait for it to complete.

#### 2.7 Configure Site Settings

Enter the following information:

**Site information**:
- **Site name**: Your site name (e.g., "My Data Catalog")
- **Site email address**: Your email address

**Site maintenance account** (admin user):
- **Username**: `admin` (or your preferred username)
- **Password**: Choose a strong password
- **Email address**: Your email address

**Regional settings**:
- **Default country**: Choose your country
- **Default time zone**: Choose your timezone

Click **Save and continue**

#### 2.8 Drupal Installation Complete

You'll see a success message and be logged into Drupal. At this point, you have a working Drupal site, but **DKAN is not installed yet**.

---

### Step 3: Install DKAN (The Data Catalog Module)

Now that Drupal is installed, you'll add the DKAN functionality.

#### 3.1 Access the Container

Open a terminal and access the web container:

```bash
docker-compose exec web bash
```

You'll see a prompt like: `root@xxxxxxxxx:/var/www/html#`

#### 3.2 Navigate to Drupal Root

Ensure you're in the Drupal installation directory:

```bash
cd /var/www/html
pwd  # Should show: /var/www/html
```

#### 3.3 Install Drush (Drupal Command-Line Tool)

```bash
composer require drush/drush
```

This installs Drush, which allows you to manage Drupal from the command line.

#### 3.4 Install DKAN

Install DKAN and its dependencies:

```bash
composer require getdkan/dkan
```

This will take a few minutes as it downloads DKAN and all required packages.

#### 3.5 Enable DKAN Modules

```bash
./vendor/bin/drush en dkan -y
```

This enables the DKAN module and all its sub-modules. You'll see output showing which modules are being enabled.

#### 3.6 Clear Drupal Cache

```bash
./vendor/bin/drush cr
```

This clears the cache so Drupal recognizes the new DKAN functionality.

#### 3.7 Exit the Container

```bash
exit
```

You're back on your host machine.

---

### Step 4: Access Your DKAN Data Catalog

DKAN is now installed and enabled! Access it at:

- **Main Site**: http://localhost:8080
- **DKAN API**: http://localhost:8080/api/1
- **Dataset Search**: http://localhost:8080/search
- **Metastore Schemas**: http://localhost:8080/api/1/metastore/schemas

**Note**: The main Drupal homepage won't look dramatically different. DKAN adds specific data catalog features accessible through the URLs above.

---

### Step 5 (Optional): Add Sample Data

To see DKAN in action with example datasets:

```bash
# Access the container
docker-compose exec web bash
cd /var/www/html

# Enable sample content module
./vendor/bin/drush en sample_content -y

# Generate sample datasets
./vendor/bin/drush dkan:sample-content:create

# Exit
exit
```

Now visit **http://localhost:8080/search** to see the sample datasets!

---

## Accessing Your DKAN Site

### Main Access Points

| Service | URL | Credentials |
|---------|-----|-------------|
| DKAN Website | http://localhost:8080 | Admin user from setup |
| Dataset Search | http://localhost:8080/search | - |
| DKAN API | http://localhost:8080/api/1 | - |
| PHPMyAdmin | http://localhost:8081 | User: `drupal`, Pass: `drupal` |
| Mailhog | http://localhost:8025 | - |

### DKAN Features

Once installed, you can:

1. **Create Datasets**: Log in as admin → Content → Add content → Dataset
2. **View Datasets**: http://localhost:8080/search
3. **Access API**: http://localhost:8080/api/1
4. **Harvest Data**: Configure harvesters to pull data from external catalogs
5. **Manage Data Store**: Upload CSV files and make them queryable

---

## Common Commands

### Docker Container Management

```bash
# Start all containers
docker-compose up -d

# Stop all containers
docker-compose down

# Restart containers
docker-compose restart

# View logs for all services
docker-compose logs -f

# View logs for specific service
docker-compose logs -f web

# Check container status
docker-compose ps

# Access web container shell
docker-compose exec web bash

# Access database shell
docker-compose exec db mysql -u drupal -pdrupal drupal
```

### Using the Makefile

This project includes a Makefile with helpful shortcuts:

```bash
# Show all available commands
make help

# Start containers
make up

# Stop containers
make down

# Access web container shell
make shell

# Access database shell
make db-shell

# Run Drush
make drush

# View container status
make status

# Clean everything (WARNING: Deletes all data!)
make clean
```

### Drush Commands (Inside Container)

```bash
# Check Drupal status
./vendor/bin/drush status

# Clear cache
./vendor/bin/drush cr

# List all modules
./vendor/bin/drush pml

# List DKAN modules
./vendor/bin/drush pml | grep dkan

# Run database updates
./vendor/bin/drush updb -y

# Export configuration
./vendor/bin/drush cex -y

# Import configuration
./vendor/bin/drush cim -y
```

### Composer Commands (Inside Container)

```bash
# Install dependencies
composer install

# Update dependencies
composer update

# Require a new package
composer require drupal/module_name

# Show installed packages
composer show
```

---

## Troubleshooting

### Problem: Cannot access http://localhost:8080

**Solution**:
1. Check containers are running:
   ```bash
   docker-compose ps
   ```
2. Check web container logs:
   ```bash
   docker-compose logs web
   ```
3. Verify port 8080 is not used by another application
4. Try restarting containers:
   ```bash
   docker-compose restart
   ```

### Problem: "Permission denied" or "Directory not writable"

**Solution**:
```bash
docker-compose exec web bash
cd /var/www/html
chown -R www-data:www-data sites/default/files
chmod -R 775 sites/default/files
exit
```

### Problem: "Database connection failed"

**Solution**:
1. Wait for database to be fully started (can take 30-60 seconds):
   ```bash
   docker-compose logs db
   ```
2. Ensure you're using correct credentials:
   - Host: `db`
   - Database: `drupal`
   - User: `drupal`
   - Password: `drupal`

### Problem: "drush: command not found"

**Solution**:
Use the full path to Drush:
```bash
./vendor/bin/drush [command]
```

Or install Drush if not present:
```bash
composer require drush/drush
```

### Problem: White screen or errors after enabling DKAN

**Solution**:
Clear cache:
```bash
docker-compose exec web bash
cd /var/www/html
./vendor/bin/drush cr
exit
```

### Problem: Want to start fresh

**Solution** (WARNING: Deletes all data!):
```bash
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
# Then repeat installation from Step 2
```

---

## File Structure

### On Your Computer (Host Machine)

```
/your/project/dkan/
├── docker-compose.yml          # Docker orchestration configuration
├── Dockerfile                  # Custom PHP/Apache image definition
├── Makefile                    # Helpful command shortcuts
├── README_DOCKER.md           # This documentation
├── .env.example               # Environment variables template
├── .dockerignore              # Files to exclude from Docker build
└── scripts/
    ├── install-dkan.sh        # Automated DKAN installation
    └── fix-permissions.sh     # Fix file permission issues
```

### Inside the Container

```
/var/www/html/                  # Drupal root directory
├── composer.json               # PHP dependencies
├── vendor/                     # Composer packages (including Drush)
├── web/                        # Web accessible directory
├── modules/
│   ├── contrib/
│   │   └── dkan/              # DKAN module code
├── sites/
│   └── default/
│       ├── settings.php       # Drupal configuration
│       └── files/             # Uploaded files and media
└── themes/                     # Drupal themes
```

---

## Environment Variables

You can customize the setup by creating a `.env` file based on `.env.example`:

```bash
cp .env.example .env
```

Key variables you can customize:

```bash
# Database Configuration
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=drupal
MYSQL_USER=drupal
MYSQL_PASSWORD=drupal

# PHP Configuration
PHP_MEMORY_LIMIT=512M
PHP_MAX_EXECUTION_TIME=300

# Port Configuration (change if ports are already in use)
WEB_PORT=8080
PHPMYADMIN_PORT=8081
MYSQL_PORT=3306
```

After changing `.env`, restart containers:
```bash
docker-compose down
docker-compose up -d
```

---

## Data Persistence

All data is stored in Docker volumes and persists even when containers are stopped:

- `db_data` - MySQL database files
- `drupal_files` - Uploaded files and media
- `drupal_vendor` - Composer dependencies
- `drupal_web` - Drupal installation

To completely remove all data:
```bash
docker-compose down -v  # WARNING: Deletes everything!
```

---

## Backup and Restore

### Backup Database

```bash
# Export database to backup.sql
docker-compose exec db mysqldump -u drupal -pdrupal drupal > backup.sql
```

### Restore Database

```bash
# Import database from backup.sql
docker-compose exec -T db mysql -u drupal -pdrupal drupal < backup.sql

# Clear Drupal cache after restore
docker-compose exec web bash -c "cd /var/www/html && ./vendor/bin/drush cr"
```

### Backup Files

```bash
# Backup uploaded files
docker cp dkan_web:/var/www/html/sites/default/files ./files-backup
```

### Restore Files

```bash
# Restore uploaded files
docker cp ./files-backup/. dkan_web:/var/www/html/sites/default/files/
docker-compose exec web chown -R www-data:www-data /var/www/html/sites/default/files
```

---

## Production Considerations

**⚠️ This setup is for development only!**

For production deployment, consider:

1. **Security**:
   - Change all default passwords
   - Use environment variables for sensitive data
   - Enable HTTPS/SSL
   - Implement proper firewall rules
   - Disable debug modes

2. **Performance**:
   - Enable Redis caching
   - Configure OPcache properly
   - Use a CDN for static assets
   - Optimize database settings
   - Enable Drupal's aggregation and caching

3. **Reliability**:
   - Set up automated backups
   - Implement monitoring and alerting
   - Use container orchestration (Kubernetes)
   - Set up health checks
   - Plan for disaster recovery

4. **Maintenance**:
   - Regular security updates
   - Monitor logs
   - Performance monitoring
   - Database optimization
   - Regular testing

---

## Additional Resources

### DKAN Documentation
- [DKAN Official Documentation](https://dkan.readthedocs.io/)
- [DKAN GitHub Repository](https://github.com/GetDKAN/dkan)
- [DKAN API Documentation](https://dkan.readthedocs.io/en/latest/apis/index.html)

### Drupal Resources
- [Drupal Official Documentation](https://www.drupal.org/documentation)
- [Drupal Docker Image](https://hub.docker.com/_/drupal)
- [Drush Documentation](https://www.drush.org/)

### Docker Resources
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

## Getting Help

If you encounter issues:

1. **Check the logs**:
   ```bash
   docker-compose logs -f
   ```

2. **Search existing issues**:
   - [DKAN Issues](https://github.com/GetDKAN/dkan/issues)
   - [Drupal Support](https://www.drupal.org/support)

3. **Ask for help**:
   - DKAN community channels
   - Drupal Stack Exchange
   - Docker community forums

---

## Summary

You've now completed a full DKAN installation! Here's what you accomplished:

1. ✅ Set up Docker containers for Drupal/DKAN
2. ✅ Installed Drupal CMS
3. ✅ Installed and enabled DKAN module
4. ✅ Configured database and file storage
5. ✅ (Optional) Added sample datasets

**Next Steps**:
- Explore the DKAN API at http://localhost:8080/api/1
- Create your first dataset
- Configure harvesters to import external data
- Customize the theme and appearance
- Set up user roles and permissions

Enjoy your DKAN data catalog! 🎉
