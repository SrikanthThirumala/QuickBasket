/* src/app/components/ErrorBoundary.jsx */
'use client';
import React from 'react';
import axios from 'axios';

export default class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    const apiUrl = process.env.NEXT_PUBLIC_API_URL || '';
    axios.post(`${apiUrl}/api/logs/client`, {
      level: 'critical',
      message: `UI Crash: ${error.message}`,
      details: errorInfo.componentStack
    }).catch(() => {});
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-slate-50 p-4">
          <div className="bg-white p-8 rounded-xl shadow border text-center max-w-md">
            <h2 className="text-2xl font-black text-red-600 mb-4">Something went wrong.</h2>
            <p className="text-slate-600 mb-6">Our team has been notified of the crash. Please refresh the page.</p>
            <button onClick={() => window.location.reload()} className="bg-emerald-600 text-white font-bold py-2 px-6 rounded">Refresh Page</button>
          </div>
        </div>
      );
    }
    return this.props.children;
  }
}