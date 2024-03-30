#!/bin/bash

# Run Django database migrations
echo "Running database migrations..."
python manage.py migrate --noinput

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput --clear

# Start Gunicorn server
echo "Starting Gunicorn server..."
gunicorn mynotes.wsgi:application --bind 0.0.0.0:8000

exec "$@"