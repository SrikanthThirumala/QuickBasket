'use client';
import { createContext, useContext, useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const router = useRouter();

  useEffect(() => {
    const token = localStorage.getItem('quickbasket_token');
    if (token) setUser({ token });
  }, []);

  const login = (token) => {
    localStorage.setItem('quickbasket_token', token);
    setUser({ token });
    router.push('/');
  };

  const logout = () => {
    localStorage.removeItem('quickbasket_token');
    setUser(null);
    router.push('/'); // REDIRECT TO HOME ON LOGOUT
  };

  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}
export const useAuth = () => useContext(AuthContext);