// frontend/public/set-api-url.js
(function(window) {
    window.__env = window.__env || {};
    window.__env.REACT_APP_API_URL = window.REACT_APP_API_URL || 'http://localhost:8000';
  }(this));
  