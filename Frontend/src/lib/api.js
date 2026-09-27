/* src/lib/api.js */
import axios from 'axios';

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || '',
  headers: { 'Content-Type': 'application/json' },
});

api.interceptors.request.use((config) => {
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('quickbasket_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (typeof window !== 'undefined' && error.response) {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || '';
      
      // Prevent infinite loops if the logging endpoint itself fails
      if (!error.config.url.includes('/api/logs/client')) {
        axios.post(`${apiUrl}/api/logs/client`, {
          level: 'error',
          message: `Frontend API Error: ${error.config.method.toUpperCase()} ${error.config.url} failed with status ${error.response.status}`,
          details: JSON.stringify(error.response.data)
        }).catch(() => {});
      }
    }
    return Promise.reject(error);
  }
);

export default api;