#!/bin/bash
# Script to install DKAN module and dependencies

set -e

echo "=========================================="
echo "DKAN Installation Script"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "composer.json" ]; then
    echo "Error: composer.json not found. Please run this script from the Drupal root directory."
    exit 1
fi

# Check if Drush is available
if ! command -v drush &> /dev/null; then
    echo "Installing Drush..."
    composer require drush/drush
fi

echo "Step 1: Installing DKAN via Composer..."
composer require getdkan/dkan

echo ""
echo "Step 2: Enabling DKAN core modules..."
drush en dkan -y

echo ""
echo "Step 3: Clearing cache..."
drush cr

echo ""
echo "=========================================="
echo "DKAN installation completed!"
echo "=========================================="
echo ""
echo "Optional: Install sample content"
echo "Run the following commands to add sample datasets:"
echo ""
echo "  drush en sample_content -y"
echo "  drush dkan:sample-content:create"
echo ""
echo "Access your DKAN site:"
echo "  - Main site: http://localhost:8080"
echo "  - API endpoint: http://localhost:8080/api/1"
echo "  - Dataset search: http://localhost:8080/search"
echo ""
