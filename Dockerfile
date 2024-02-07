# Use an official lightweight Python runtime as a base image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Create and set the working directory to /Django in the container
WORKDIR /django

# Copy only the relevant files for the Django project
COPY . .

# Install the Python dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

