# Build the React application
FROM node:20-alpine as build-stage

WORKDIR /frontend

# Copy package.json and package-lock.json to leverage Docker cache
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the application
RUN npm run build

# Serve stage
FROM nginx:stable-alpine as serve-stage

# Copy built static files from the build-stage to Nginx's serve directory
COPY --from=build-stage /frontend/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
