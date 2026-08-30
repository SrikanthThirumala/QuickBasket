'use client';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import api from '../lib/api';
import { useCart } from '../context/CartContext';
import { useAuth } from '../context/AuthContext';
import CartDrawer from '../components/CartDrawer';

export default function Storefront() {
  const [products, setProducts] = useState([]);
  const { addToCart, setIsCartOpen, totalItemCount } = useCart();
  const { user, logout } = useAuth();

  useEffect(() => {
    api.get('/api/products').then(res => setProducts(res.data.products));
  }, []);

  return (
    <div className="min-h-screen bg-slate-50">
      <header className="bg-white shadow-sm sticky top-0 z-30 h-16 flex items-center justify-between px-8">
        <h1 className="text-2xl font-black text-emerald-700">QuickBasket</h1>
        <div className="flex gap-6 items-center">
          {user ? (
            <>
              <Link href="/profile" className="font-bold text-slate-600 hover:text-emerald-600">Profile</Link>
              <Link href="/orders" className="font-bold text-slate-600 hover:text-emerald-600">Orders</Link>
              <button onClick={logout} className="font-bold text-red-500">Logout</button>
            </>
          ) : <Link href="/login" className="font-bold text-emerald-600">Sign In</Link>}
          <button onClick={() => setIsCartOpen(true)} className="bg-emerald-600 text-white px-4 py-2 rounded-full font-bold">
            🛒 Basket ({totalItemCount})
          </button>
        </div>
      </header>

      <section className="bg-emerald-800 text-white py-16 text-center">
        <h2 className="text-5xl font-black mb-4">Fresh Groceries, Faster.</h2>
        <p className="text-lg text-emerald-100">Apply code <span className="font-mono bg-white text-emerald-800 px-2 py-1 rounded">QUICKFRESH</span> for 15% off your first order!</p>
      </section>

      <main className="max-w-7xl mx-auto p-8 grid grid-cols-2 md:grid-cols-4 gap-6">
        {products.map(product => (
          <div key={product.id} className="bg-white rounded-xl shadow-sm border p-4 hover:shadow-md transition">
            <img src={product.image_url} alt={product.name} className="w-full aspect-square object-cover rounded-lg mb-4" />
            <div className="flex justify-between items-start mb-2">
               <h3 className="font-bold leading-tight">{product.name}</h3>
               <span className="text-xs font-bold bg-orange-100 text-orange-700 px-2 py-1 rounded-full">{product.calories} kcal</span>
            </div>
            <p className="text-lg font-black text-emerald-700 mb-4">₹{product.price}</p>
            <button onClick={() => addToCart(product)} className="w-full bg-emerald-50 text-emerald-700 font-bold py-2 rounded-lg hover:bg-emerald-600 hover:text-white transition">
              Add to Basket
            </button>
          </div>
        ))}
      </main>
      <CartDrawer />
    </div>
  );
}