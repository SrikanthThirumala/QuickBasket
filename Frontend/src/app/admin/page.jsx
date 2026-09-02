// src/app/admin/page.jsx
'use client';
import { useEffect, useState } from 'react';
import api from '../../lib/api';
import { useRouter } from 'next/navigation';

export default function AdminDashboard() {
  const [activeTab, setActiveTab] = useState('orders'); 
  
  const [orders, setOrders] = useState([]);
  const [products, setProducts] = useState([]);
  const [promos, setPromos] = useState([]);
  
  const [newPromo, setNewPromo] = useState({ code: '', discount_percent: 10 });
  
  const defaultProductState = { name: '', price: '', image_url: '', image_file: null, category: 'Produce', unit: 'each', stock_quantity: 100, calories: 0 };
  const [newProduct, setNewProduct] = useState(defaultProductState);
  const [editingProduct, setEditingProduct] = useState(null); 
  
  const [status, setStatus] = useState('');
  
  const router = useRouter();

  useEffect(() => {
    fetchData();
  }, [activeTab]);

  const fetchData = async () => {
    try {
      if (activeTab === 'orders') {
        const { data } = await api.get('/api/admin/orders');
        setOrders(data.orders);
      } else if (activeTab === 'products') {
        const { data } = await api.get('/api/admin/products');
        setProducts(data.products);
      } else if (activeTab === 'promos') {
        const { data } = await api.get('/api/admin/promocodes');
        setPromos(data.promocodes);
      }
    } catch (err) {
      if (err.response?.status === 403 || err.response?.status === 401) {
        router.push('/');
      }
    }
  };

  const updateOrderStatus = async (id, newStatus) => {
    await api.put(`/api/admin/orders/${id}/status`, { status: newStatus });
    fetchData();
  };

  const createPromo = async (e) => {
    e.preventDefault();
    try {
      await api.post('/api/admin/promocodes', newPromo);
      setStatus('Promo created successfully!');
      fetchData();
    } catch (err) {
      setStatus('Failed to create promo');
    }
  };

  const deletePromo = async (id) => {
    await api.delete(`/api/admin/promocodes/${id}`);
    fetchData();
  };

  const handleProductSubmit = async (e) => {
    e.preventDefault();
    const currentState = editingProduct || newProduct;
    
    const formData = new FormData();
    formData.append('name', currentState.name);
    formData.append('price', currentState.price);
    formData.append('category', currentState.category);
    formData.append('unit', currentState.unit);
    formData.append('stock_quantity', currentState.stock_quantity);
    formData.append('calories', currentState.calories);
    
    if (currentState.image_file) {
      formData.append('image', currentState.image_file);
    } else if (currentState.image_url) {
      formData.append('image_url', currentState.image_url);
    }

    try {
      if (editingProduct) {
        await api.put(`/api/admin/products/${editingProduct.id}`, formData, {
            headers: { 'Content-Type': 'multipart/form-data' }
        });
        setStatus('Product updated successfully!');
        setEditingProduct(null);
      } else {
        await api.post('/api/admin/products', formData, {
            headers: { 'Content-Type': 'multipart/form-data' }
        });
        setStatus('Product added successfully!');
        setNewProduct(defaultProductState);
      }
      fetchData();
    } catch (err) {
      setStatus(editingProduct ? 'Failed to update product' : 'Failed to add product');
    }
  };

  const handleProductChange = (field, value) => {
    if (editingProduct) {
      setEditingProduct({ ...editingProduct, [field]: value });
    } else {
      setNewProduct({ ...newProduct, [field]: value });
    }
  };

  const startEditing = (product) => {
    setEditingProduct({ ...product, image_file: null });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const deleteProduct = async (id) => {
    if (confirm('Are you sure you want to delete this product?')) {
      await api.delete(`/api/admin/products/${id}`);
      fetchData();
    }
  };

  const currentFormState = editingProduct || newProduct;

  return (
    <div className="min-h-screen bg-slate-50 p-8">
      <div className="max-w-7xl mx-auto space-y-6">
        
        <div className="flex justify-between items-center bg-slate-800 text-white p-6 rounded-xl shadow-lg">
          <h1 className="text-3xl font-black">Admin Dashboard</h1>
          <button onClick={() => router.push('/')} className="bg-slate-600 px-4 py-2 rounded font-bold hover:bg-slate-500 transition-all">Back to Store</button>
        </div>

        <div className="flex gap-4 border-b pb-2">
          {['orders', 'products', 'promos'].map(tab => (
            <button 
              key={tab} 
              onClick={() => { setActiveTab(tab); setStatus(''); setEditingProduct(null); }}
              className={`px-6 py-2 font-black rounded-t-lg transition-all capitalize ${activeTab === tab ? 'bg-emerald-600 text-white' : 'bg-white text-slate-500 hover:bg-slate-100'}`}
            >
              {tab}
            </button>
          ))}
        </div>

        {status && <div className="bg-blue-100 text-blue-800 p-3 rounded font-bold">{status}</div>}

        {activeTab === 'orders' && (
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
                        <button onClick={() => updateOrderStatus(o.id, 'Shipped')} className="bg-blue-100 text-blue-700 px-3 py-1 rounded text-xs font-bold hover:bg-blue-200">Ship</button>
                        <button onClick={() => updateOrderStatus(o.id, 'Delivered')} className="bg-emerald-100 text-emerald-700 px-3 py-1 rounded text-xs font-bold hover:bg-emerald-200">Deliver</button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {activeTab === 'products' && (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div className={`lg:col-span-1 bg-white p-6 rounded-xl shadow border h-fit sticky top-6 ${editingProduct ? 'ring-2 ring-emerald-500' : ''}`}>
              <div className="flex justify-between items-center mb-4">
                <h2 className="text-xl font-bold text-slate-800">
                  {editingProduct ? 'Update Product' : 'Add New Product'}
                </h2>
                {editingProduct && (
                  <button onClick={() => setEditingProduct(null)} className="text-xs font-bold text-slate-400 hover:text-slate-700">Cancel</button>
                )}
              </div>
              <form onSubmit={handleProductSubmit} className="space-y-3">
                <input type="text" placeholder="Product Name" className="w-full p-2 border rounded" value={currentFormState.name} onChange={e => handleProductChange('name', e.target.value)} required/>
                <input type="number" placeholder="Price (₹)" className="w-full p-2 border rounded" value={currentFormState.price} onChange={e => handleProductChange('price', e.target.value)} required/>
                
                <div className="w-full p-2 border rounded bg-slate-50">
                  <span className="text-xs text-slate-500 font-bold block mb-1">Upload Image (Replaces current if editing)</span>
                  <input type="file" accept="image/*" className="w-full text-sm" onChange={e => handleProductChange('image_file', e.target.files[0])} required={!editingProduct && !currentFormState.image_url} />
                </div>

                <input type="text" placeholder="Category" className="w-full p-2 border rounded" value={currentFormState.category} onChange={e => handleProductChange('category', e.target.value)} required/>
                <input type="text" placeholder="Unit (e.g. 1 kg, each)" className="w-full p-2 border rounded" value={currentFormState.unit} onChange={e => handleProductChange('unit', e.target.value)} required/>
                <div className="flex gap-2">
                  <input type="number" placeholder="Stock Qty" className="w-1/2 p-2 border rounded" value={currentFormState.stock_quantity} onChange={e => handleProductChange('stock_quantity', e.target.value)} required/>
                  <input type="number" placeholder="Calories" className="w-1/2 p-2 border rounded" value={currentFormState.calories} onChange={e => handleProductChange('calories', e.target.value)} required/>
                </div>
                <button className="pop-click w-full bg-emerald-600 text-white font-bold py-2 rounded hover:bg-emerald-700 transition-all">
                  {editingProduct ? 'Save Changes' : 'Add Product'}
                </button>
              </form>
            </div>
            
            <div className="lg:col-span-2 bg-white p-6 rounded-xl shadow border">
              <h2 className="text-xl font-bold mb-4">Product Catalog</h2>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                {products.map(p => (
                  <div key={p.id} className={`border rounded-lg p-3 hover:shadow-md flex flex-col justify-between transition-all ${editingProduct?.id === p.id ? 'border-emerald-500 bg-emerald-50' : ''}`}>
                    <div>
                      <div className="h-24 bg-slate-100 rounded mb-2 flex items-center justify-center overflow-hidden">
                        <img src={p.image_url} alt={p.name} className="h-full object-contain mix-blend-multiply" />
                      </div>
                      <h4 className="font-bold text-sm leading-tight mb-1">{p.name}</h4>
                      <div className="flex justify-between text-xs text-slate-500 mb-2">
                        <span className="font-bold text-emerald-700">₹{p.price}</span>
                        <span>{p.category}</span>
                      </div>
                    </div>
                    <div className="flex gap-2 mt-2">
                      <button onClick={() => startEditing(p)} className="flex-1 bg-slate-100 text-slate-700 font-bold py-1 rounded text-xs hover:bg-slate-200 transition-colors">
                        Edit
                      </button>
                      <button onClick={() => deleteProduct(p.id)} className="flex-1 bg-red-50 text-red-600 font-bold py-1 rounded text-xs hover:bg-red-600 hover:text-white transition-colors">
                        Remove
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {activeTab === 'promos' && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div className="bg-white p-6 rounded-xl shadow border h-fit">
              <h2 className="text-xl font-bold mb-4">Generate Promo Code</h2>
              <form onSubmit={createPromo} className="space-y-4">
                <input type="text" placeholder="CODE (e.g. SUMMER20)" className="w-full p-2 border rounded uppercase" onChange={e => setNewPromo({...newPromo, code: e.target.value})} required/>
                <input type="number" placeholder="Discount %" className="w-full p-2 border rounded" onChange={e => setNewPromo({...newPromo, discount_percent: parseInt(e.target.value)})} required/>
                <button className="pop-click w-full bg-emerald-600 text-white font-bold py-2 rounded hover:bg-emerald-700">Create Promo</button>
              </form>
            </div>
            
            <div className="bg-white p-6 rounded-xl shadow border">
              <h2 className="text-xl font-bold mb-4">Active Promo Codes</h2>
              <div className="space-y-3">
                {promos.map(promo => (
                  <div key={promo.id} className="flex justify-between items-center p-3 bg-slate-50 border rounded-lg">
                    <div>
                      <p className="font-black text-lg text-emerald-700 tracking-wider">{promo.code}</p>
                      <p className="text-xs text-slate-500 font-bold">{promo.discount_percent}% OFF</p>
                    </div>
                    <button onClick={() => deletePromo(promo.id)} className="text-red-500 font-bold text-sm hover:underline">Revoke</button>
                  </div>
                ))}
                {promos.length === 0 && <p className="text-slate-500 text-sm">No active promo codes.</p>}
              </div>
            </div>
          </div>
        )}

      </div>
    </div>
  );
}