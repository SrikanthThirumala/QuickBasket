/* src/app/components/GlobalErrorCatcher.jsx */
'use client';
import { useEffect } from 'react';
import axios from 'axios';

export default function GlobalErrorCatcher({ children }) {
  useEffect(() => {
    const apiUrl = process.env.NEXT_PUBLIC_API_URL || '';

    const logToBackend = (message, details) => {
      axios.post(`${apiUrl}/api/logs/client`, {
        level: 'critical',
        message: message,
        details: details
      }).catch(() => {}); // Prevent infinite loops if logging fails
    };

    // Catches raw JS runtime errors and event handler crashes
    const handleWindowError = (event) => {
      logToBackend(
        `Global Window Error: ${event.message}`,
        `File: ${event.filename} | Line: ${event.lineno}:${event.colno} | Stack: ${event.error?.stack || 'N/A'}`
      );
    };

    // Catches failed async operations lacking a .catch() block
    const handleUnhandledRejection = (event) => {
      logToBackend(
        `Unhandled Promise Rejection: ${event.reason?.message || event.reason || 'Unknown'}`,
        event.reason?.stack || 'No stack trace available'
      );
    };

    window.addEventListener('error', handleWindowError);
    window.addEventListener('unhandledrejection', handleUnhandledRejection);

    return () => {
      window.removeEventListener('error', handleWindowError);
      window.removeEventListener('unhandledrejection', handleUnhandledRejection);
    };
  }, []);

  return children;
}