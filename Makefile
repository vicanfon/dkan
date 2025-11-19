.PHONY: help build up down restart logs shell db-shell composer drush clean install fix-permissions install-dkan

# Default target
help:
	@echo "DKAN Docker Management Commands"
	@echo "================================"
	@echo "make build            - Build Docker images"
	@echo "make up               - Start all containers"
	@echo "make down             - Stop all containers"
	@echo "make restart          - Restart all containers"
	@echo "make logs             - Show container logs"
	@echo "make shell            - Access web container shell"
	@echo "make db-shell         - Access database shell"
	@echo "make composer         - Run composer install"
	@echo "make drush            - Access Drush CLI"
	@echo "make fix-permissions  - Fix Drupal file permissions"
	@echo "make install-dkan     - Install DKAN module"
	@echo "make clean            - Remove all containers and volumes"
	@echo "make install          - Full installation (build + up)"
	@echo "make status           - Show container status"

# Build Docker images
build:
	docker-compose build

# Start containers
up:
	docker-compose up -d

# Stop containers
down:
	docker-compose down

# Restart containers
restart:
	docker-compose restart

# Show logs
logs:
	docker-compose logs -f

# Access web container shell
shell:
	docker-compose exec web bash

# Access database shell
db-shell:
	docker-compose exec db mysql -u drupal -pdrupal drupal

# Run composer install
composer:
	docker-compose exec web composer install

# Access Drush
drush:
	docker-compose exec web drush

# Fix file permissions
fix-permissions:
	@echo "Fixing Drupal file permissions..."
	docker-compose exec web bash /var/www/html/modules/contrib/dkan/scripts/fix-permissions.sh

# Install DKAN module
install-dkan:
	@echo "Installing DKAN..."
	docker-compose exec web bash /var/www/html/modules/contrib/dkan/scripts/install-dkan.sh

# Clean everything (WARNING: Deletes all data!)
clean:
	docker-compose down -v
	docker system prune -f

# Full installation
install: build up
	@echo "Waiting for services to be ready..."
	@sleep 10
	@echo "Installation complete! Access the site at http://localhost:8080"

# Show container status
status:
	docker-compose ps
