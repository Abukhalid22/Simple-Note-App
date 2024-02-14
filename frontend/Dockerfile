# Build stage
FROM node:20-alpine as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Serve stage
FROM nginx:stable-alpine
COPY --from=build-stage /app/build /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx/nginx-setup.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
