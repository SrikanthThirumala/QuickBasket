'use client';

import { useEffect, useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { useRouter } from 'next/navigation';
import api from '../../lib/api';

export default function OrdersPage() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const { user, logout } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!user) {
      router.push('/login');
      return;
    }
    const fetchOrders = async () => {
      try {
        const { data } = await api.get('/api/orders/history');
        setOrders(data.orders);
      } catch (err) {
        if (err.response?.status === 401) logout();
      } finally {
        setLoading(false);
      }
    };
    fetchOrders();
  }, [user]);

  if (!user) return null;

  return (
    <div className="min-h-screen bg-slate-50 py-10 px-4 sm:px-6 lg:px-8">
      <div className="max-w-4xl mx-auto">
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-3xl font-black text-slate-900">Order History</h1>
          <button onClick={() => router.push('/')} className="text-emerald-600 font-bold hover:underline">Back to Store</button>
        </div>

        {loading ? (
          <p className="text-center text-slate-500 font-medium">Loading your orders...</p>
        ) : orders.length === 0 ? (
          <div className="bg-white p-10 text-center rounded-2xl shadow-sm border border-slate-100">
            <p className="text-slate-500 font-medium">You haven't placed any orders yet.</p>
          </div>
        ) : (
          <div className="space-y-6">
            {orders.map((order) => (
              <div key={order.id} className="bg-white border border-slate-200 rounded-2xl shadow-sm overflow-hidden">
                <div className="bg-slate-100 p-4 border-b border-slate-200 flex flex-wrap justify-between gap-4">
                  <div>
                    <p className="text-xs text-slate-500 font-bold uppercase">Order Placed</p>
                    <p className="text-sm font-semibold text-slate-800">{new Date(order.created_at).toLocaleDateString()}</p>
                  </div>
                  <div>
                    <p className="text-xs text-slate-500 font-bold uppercase">Total Amount</p>
                    <p className="text-sm font-semibold text-emerald-700">₹{order.total_amount.toFixed(2)}</p>
                  </div>
                  <div className="text-right">
                    <span className={`inline-block px-3 py-1 text-xs font-bold rounded-full ${
                      order.status === 'Pending' ? 'bg-orange-100 text-orange-700' :
                      order.status === 'Shipped' ? 'bg-blue-100 text-blue-700' :
                      'bg-emerald-100 text-emerald-700'
                    }`}>
                      {order.status}
                    </span>
                  </div>
                </div>

                <div className="p-4">
                  <div className="flex justify-between items-start mb-4">
                    <div>
                      <p className="text-xs text-slate-500 font-bold uppercase mb-1">Delivery Address</p>
                      <p className="text-sm text-slate-700 bg-slate-50 p-2 rounded border border-slate-100">{order.delivery_address}</p>
                    </div>
                    {order.total_calories > 0 && (
                      <div className="text-right">
                        <p className="text-xs text-slate-500 font-bold uppercase mb-1">Calories Gained</p>
                        <p className="text-sm font-black text-orange-600">+{order.total_calories} kcal</p>
                      </div>
                    )}
                  </div>

                  <div className="space-y-3">
                    {order.items.map((item, idx) => (
                      <div key={idx} className="flex gap-4 items-center p-2 hover:bg-slate-50 rounded">
                        <img src={item.image_url} alt={item.name} className="w-12 h-12 object-cover rounded shadow-sm" />
                        <div>
                          <p className="text-sm font-bold text-slate-800">{item.name}</p>
                          <p className="text-xs text-slate-500">Qty: {item.quantity} x ₹{item.price_at_purchase.toFixed(2)}</p>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}