/* src/app/layout.jsx */
import './globals.css';
import { CartProvider } from '../context/CartContext';
import { AuthProvider } from '../context/AuthContext';
import ErrorBoundary from '../components/ErrorBoundary';
import GlobalErrorCatcher from '../components/GlobalErrorCatcher';

export const metadata = {
  title: 'QuickBasket Grocery Store',
  description: 'Fresh groceries delivered fast',
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className="bg-slate-50 text-slate-900">
        <GlobalErrorCatcher>
          <ErrorBoundary>
            <AuthProvider>
              <CartProvider>
                {children}
              </CartProvider>
            </AuthProvider>
          </ErrorBoundary>
        </GlobalErrorCatcher>
      </body>
    </html>
  );
}