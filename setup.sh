#!/bin/bash
exec > >(tee /var/log/setup.log) 2>&1

# Update system and install dependencies
apt-get update
apt-get upgrade -y
apt-get install -y netcat-openbsd

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Create script directory
mkdir -p /usr/local/bin

# Copy the MySQL check script to proper location
cp check-mysql.sh /usr/local/bin/
chmod +x /usr/local/bin/check-mysql.sh

# Wait for environment variable to be set
max_attempts=30
attempt=0

while [ -z "$DB_PRIVATE_IP" ]; do
    if [ $attempt -ge $max_attempts ]; then
        echo "Timeout waiting for DB_PRIVATE_IP to be set"
        exit 1
    fi
    echo "Waiting for DB_PRIVATE_IP environment variable..."
    attempt=$((attempt + 1))
    sleep 10
    source /etc/environment
done

echo "DB_PRIVATE_IP is set to: $DB_PRIVATE_IP"

# Execute the MySQL check script
/usr/local/bin/check-mysql.sh
