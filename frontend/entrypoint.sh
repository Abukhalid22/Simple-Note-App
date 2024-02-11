#!/bin/sh
# Replace API URL placeholder with the value of REACT_APP_API_URL environment variable
sed -i 's|http://localhost:8000|'"$REACT_APP_API_URL"'|g' /usr/share/nginx/html/set-api-url.js

# Start Nginx
exec "$@"
