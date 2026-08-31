'use client';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import api from '../lib/api';
import { useCart } from '../context/CartContext';
import { useAuth } from '../context/AuthContext';
import CartDrawer from '../components/CartDrawer';

export default function Storefront() {
  const [products, setProducts] = useState([]);
  const [calorieAnim, setCalorieAnim] = useState([]);
  const [mounted, setMounted] = useState(false);
  const { addToCart, setIsCartOpen, totalItemCount } = useCart();
  const { user, logout } = useAuth();

  useEffect(() => {
    setMounted(true);
    api.get('/api/products').then(res => setProducts(res.data.products));
  }, []);

  const handleAddToCart = (e, product) => {
    addToCart(product);
    const newAnim = { id: Date.now(), x: e.clientX, y: e.clientY, cal: product.calories };
    setCalorieAnim(prev => [...prev, newAnim]);
    setTimeout(() => {
      setCalorieAnim(prev => prev.filter(a => a.id !== newAnim.id));
    }, 1000);
  };

  const zones = [...new Set(products.map(p => p.category))];

  return (
    <div className="min-h-screen bg-slate-50">
      {calorieAnim.map(anim => (
        <div key={anim.id} className="animate-float" style={{ top: anim.y, left: anim.x }}>
          +{anim.cal} kcal
        </div>
      ))}

      <header className="bg-white shadow-sm sticky top-0 z-30 h-16 flex items-center justify-between px-8">
        <div className="flex items-center gap-4">
          {mounted && user?.role === 'admin' && (
            <Link href="/admin" className="text-xs font-bold bg-slate-800 text-white px-2 py-1 rounded hover:bg-slate-700 transition-all">Admin Access</Link>
          )}
          <h1 className="text-2xl font-black text-emerald-700">QuickBasket</h1>
        </div>
        
        <div className="flex gap-6 items-center">
          {mounted && (
            user ? (
              <>
                <Link href="/profile" className="font-bold text-slate-600 hover:text-emerald-600 transition-colors">Profile</Link>
                <Link href="/orders" className="font-bold text-slate-600 hover:text-emerald-600 transition-colors">Orders</Link>
                <button onClick={logout} className="font-bold text-red-500 hover:scale-105 transition-transform">Logout</button>
              </>
            ) : <Link href="/login" className="font-bold text-emerald-600 hover:scale-105 transition-transform">Sign In</Link>
          )}
          <button onClick={() => setIsCartOpen(true)} className="pop-click bg-emerald-600 text-white px-4 py-2 rounded-full font-bold shadow-md hover:bg-emerald-700 hover:shadow-lg transition-all">
            🛒 Basket ({totalItemCount})
          </button>
        </div>
      </header>

      <div className="max-w-7xl mx-auto p-8 space-y-12">
        {zones.map(zone => (
          <section key={zone} className="animate-fade-in">
            <h2 className="text-2xl font-black text-slate-800 mb-6 border-b pb-2">{zone} Zone</h2>
            <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-6">
              {products.filter(p => p.category === zone).map(product => (
                <div key={product.id} className="bg-white rounded-xl shadow-sm border hover:shadow-xl hover:-translate-y-1 transition-all duration-300 overflow-hidden flex flex-col">
                  <div className="h-40 w-full bg-slate-100 p-2">
                    <img src={product.image_url} alt={product.name} className="w-full h-full object-contain mix-blend-multiply" />
                  </div>
                  <div className="p-4 flex-1 flex flex-col justify-between">
                    <div>
                      <div className="flex justify-between items-start mb-1">
                         <h3 className="font-bold text-sm leading-tight text-slate-800">{product.name}</h3>
                         <span className="text-[10px] font-bold bg-orange-100 text-orange-700 px-1.5 py-0.5 rounded-full whitespace-nowrap">{product.calories} kcal</span>
                      </div>
                      <p className="text-xs text-slate-400 mb-3">{product.unit}</p>
                    </div>
                    <div>
                      <p className="text-lg font-black text-emerald-700 mb-3">₹{product.price}</p>
                      <button onClick={(e) => handleAddToCart(e, product)} className="pop-click w-full bg-emerald-50 text-emerald-700 font-bold py-2 rounded-lg hover:bg-emerald-600 hover:text-white transition-colors duration-300 text-sm">
                        Add to Basket
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </section>
        ))}
      </div>
      <CartDrawer />
    </div>
  );
}