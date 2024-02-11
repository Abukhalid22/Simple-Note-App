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

# Copy the set-api-url.js.template file from the public directory
COPY public/set-api-url.js.template /usr/share/nginx/html/set-api-url.js.template

# Install gettext for envsubst and replace API URL placeholder
RUN apk add --no-cache gettext && \
    envsubst '${REACT_APP_API_URL}' < /usr/share/nginx/html/set-api-url.js.template > /usr/share/nginx/html/set-api-url.js && \
    rm /usr/share/nginx/html/set-api-url.js.template

CMD ["nginx", "-g", "daemon off;"]
