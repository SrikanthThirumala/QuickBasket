/* src/app/context/AuthContext.jsx */
'use client';
import { createContext, useContext, useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const router = useRouter();

  const decodeToken = (token) => {
    try {
      return JSON.parse(atob(token.split('.')[1]));
    } catch (e) {
      return null;
    }
  };

  useEffect(() => {
    const token = localStorage.getItem('quickbasket_token');
    if (token) {
      const decoded = decodeToken(token);
      setUser({ token, role: decoded?.role || 'user' });
    }
  }, []);

  const login = (token) => {
    localStorage.setItem('quickbasket_token', token);
    const decoded = decodeToken(token);
    setUser({ token, role: decoded?.role || 'user' });
    router.push('/');
  };

  const logout = () => {
    localStorage.removeItem('quickbasket_token');
    setUser(null);
    router.push('/'); 
  };

  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}
export const useAuth = () => useContext(AuthContext);