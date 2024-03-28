# Use an official lightweight Python runtime as a base image
FROM python:3.11-slim

# Set environment variables to prevent Python from writing .pyc files to disc
# and to ensure stdout and stderr are directly forwarded to terminal without being buffered
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Create and set the working directory to /django in the container
WORKDIR /django

# Copy the requirements file first to leverage Docker cache
COPY requirements.txt /django/
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Copy the .env file into the container
COPY .env /django/

# Install python-dotenv module
RUN pip install python-dotenv

# After installing dependencies, copy the rest of your application
COPY . /django/

# Run Django migrations and start Gunicorn server as the default command
CMD python manage.py migrate --noinput && gunicorn mynotes.wsgi:application --bind 0.0.0.0:8000
