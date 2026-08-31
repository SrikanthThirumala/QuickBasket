'use client';
import { useEffect, useState } from 'react';
import api from '../../lib/api';
import { useRouter } from 'next/navigation';

export default function AdminDashboard() {
  const [orders, setOrders] = useState([]);
  const [newPromo, setNewPromo] = useState({ code: '', discount_percent: 10 });
  const [status, setStatus] = useState('');
  const router = useRouter();

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      const { data } = await api.get('/api/admin/orders');
      setOrders(data.orders);
    } catch (err) {
      if (err.response?.status === 403 || err.response?.status === 401) {
        router.push('/');
      }
    }
  };

  const updateOrderStatus = async (id, newStatus) => {
    try {
      await api.put(`/api/admin/orders/${id}/status`, { status: newStatus });
      fetchOrders();
    } catch (err) {
      setStatus('Failed to update order');
    }
  };

  const createPromo = async (e) => {
    e.preventDefault();
    try {
      await api.post('/api/admin/promocodes', newPromo);
      setStatus('Promo created successfully!');
    } catch (err) {
      setStatus('Failed to create promo');
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 p-8">
      <div className="max-w-6xl mx-auto space-y-8">
        <div className="flex justify-between items-center bg-slate-800 text-white p-6 rounded-xl shadow-lg">
          <h1 className="text-3xl font-black">Admin Dashboard</h1>
          <button onClick={() => router.push('/')} className="bg-slate-600 px-4 py-2 rounded font-bold hover:bg-slate-500 transition-all">Back to Store</button>
        </div>
        
        {status && <div className="bg-blue-100 text-blue-800 p-3 rounded font-bold">{status}</div>}

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          <div className="bg-white p-6 rounded-xl shadow border">
            <h2 className="text-xl font-bold mb-4">Generate Promo Code</h2>
            <form onSubmit={createPromo} className="space-y-4">
              <input type="text" placeholder="CODE (e.g. SUMMER20)" className="w-full p-2 border rounded uppercase" onChange={e => setNewPromo({...newPromo, code: e.target.value})} required/>
              <input type="number" placeholder="Discount %" className="w-full p-2 border rounded" onChange={e => setNewPromo({...newPromo, discount_percent: parseInt(e.target.value)})} required/>
              <button className="pop-click w-full bg-emerald-600 text-white font-bold py-2 rounded hover:bg-emerald-700 transition-all">Create Promo</button>
            </form>
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl shadow border">
          <h2 className="text-xl font-bold mb-4">Manage Orders</h2>
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-slate-100 text-slate-600 text-sm">
                  <th className="p-3">ID</th>
                  <th className="p-3">Total</th>
                  <th className="p-3">Address</th>
                  <th className="p-3">Status</th>
                  <th className="p-3">Action</th>
                </tr>
              </thead>
              <tbody>
                {orders.map(o => (
                  <tr key={o.id} className="border-b hover:bg-slate-50 transition-all">
                    <td className="p-3 font-bold">#{o.id}</td>
                    <td className="p-3">₹{o.total_amount}</td>
                    <td className="p-3 text-xs max-w-xs truncate">{o.delivery_address}</td>
                    <td className="p-3 font-bold text-orange-600">{o.status}</td>
                    <td className="p-3 flex gap-2">
                      <button onClick={() => updateOrderStatus(o.id, 'Shipped')} className="bg-blue-100 text-blue-700 px-3 py-1 rounded text-xs font-bold hover:bg-blue-200 transition-all">Ship</button>
                      <button onClick={() => updateOrderStatus(o.id, 'Delivered')} className="bg-emerald-100 text-emerald-700 px-3 py-1 rounded text-xs font-bold hover:bg-emerald-200 transition-all">Deliver</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}