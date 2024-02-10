#!/bin/sh

# Run Django migrations
python manage.py migrate --noinput

# Start Gunicorn
gunicorn mynotes.wsgi:application --bind 0.0.0.0:8000
