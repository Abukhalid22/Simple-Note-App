# Stage 1: Build Stage
# Use a specific version of Node.js to ensure compatibility and predictability
FROM node:20-buster as build-stage

# Install build tools for native dependencies
RUN apt-get update && apt-get install -y build-essential python3

# Set the working directory in the container to /frontend
WORKDIR /frontend

# Copy package.json and package-lock.json to leverage Docker's cache mechanism efficiently
COPY package*.json ./

# Install dependencies, making sure to log any errors to a file within the current working directory
RUN npm install --verbose --registry=https://registry.npmjs.org || cat npm-debug.log

# Copy the rest of the app's source code into the container
COPY . .

# Build the React app
RUN npm run build

# Stage 2: Serve Stage - Using Nginx to serve the built React app
FROM nginx:stable-alpine

# Copy the build artifacts from the build stage to Nginx's serve directory
COPY --from=build-stage /frontend/build /usr/share/nginx/html

# Copy the custom Nginx configuration
COPY nginx/nginx-setup.conf /etc/nginx/conf.d/default.conf

# Command to run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
