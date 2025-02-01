#!/bin/bash

echo "Stopping all running Docker containers..."
docker stop $(docker ps -q)

echo "Removing all stopped containers..."
docker rm $(docker ps -aq)

echo "Removing unused Docker volumes..."
docker volume prune -f

echo "✅ Docker cleanup complete!"
