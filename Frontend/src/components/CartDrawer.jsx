/* src/app/components/CartDrawer.jsx */
'use client';
import { useState } from 'react';
import { useCart } from '../context/CartContext';
import { useAuth } from '../context/AuthContext';
import { useRouter } from 'next/navigation';
import api from '../lib/api';

export default function CartDrawer() {
  const { cart, removeFromCart, clearCart, cartTotal, isCartOpen, setIsCartOpen } = useCart();
  const { user } = useAuth();
  const router = useRouter();

  const [address, setAddress] = useState({ street: '', city: '', state: '', zip: '' });
  const [paymentMethod, setPaymentMethod] = useState('Card');
  const [cardNumber, setCardNumber] = useState('');
  const [promoCode, setPromoCode] = useState('');
  const [discountPercent, setDiscountPercent] = useState(0);
  const [status, setStatus] = useState('');

  if (!isCartOpen) return null;

  const generateMockCard = () => {
    const randomCard = '4' + Math.floor(100000000000000 + Math.random() * 900000000000000).toString();
    setCardNumber(randomCard.match(/.{1,4}/g).join(' '));
  };

  const applyPromo = async () => {
    try {
      const { data } = await api.post('/api/orders/validate-promo', { code: promoCode });
      setDiscountPercent(data.discount_percent);
      setStatus(`Promo applied! ${data.discount_percent}% off.`);
    } catch (err) {
      setStatus('Invalid promo code.');
      setDiscountPercent(0);
    }
  };

  const handleCheckout = async () => {
    if (!user) { setIsCartOpen(false); return router.push('/login'); }
    if (!address.street || !address.city || !address.state || !address.zip) {
      return setStatus('Please complete all address fields.');
    }
    if (paymentMethod === 'Card' && !cardNumber) {
      return setStatus('Please generate or enter a card number.');
    }

    try {
      await api.post('/api/orders/checkout', {
        cart,
        address,
        payment_method: paymentMethod,
        promo_code: discountPercent > 0 ? promoCode : null
      });
      setStatus('Success! Check your email for confirmation.');
      setTimeout(() => { clearCart(); setIsCartOpen(false); router.push('/orders'); }, 2000);
    } catch (err) {
      setStatus('Checkout failed.');
    }
  };

  const finalTotal = cartTotal * (1 - discountPercent / 100);

  return (
    <div className="fixed inset-0 z-50 flex justify-end">
      <div className="absolute inset-0 bg-black/40" onClick={() => setIsCartOpen(false)}></div>
      <div className="relative w-full max-w-md bg-white h-full shadow-2xl flex flex-col overflow-y-auto">
        <div className="p-4 border-b flex justify-between bg-slate-50">
          <h2 className="text-xl font-bold">Your Basket</h2>
          <button onClick={() => setIsCartOpen(false)} className="text-2xl font-bold">&times;</button>
        </div>

        <div className="p-4 space-y-3">
          {cart.map((item) => (
            <div key={item.product_id} className="flex justify-between items-center p-3 border rounded-lg">
              <div>
                <h4 className="font-bold text-sm">{item.name}</h4>
                <p className="text-xs text-slate-500">Qty: {item.quantity} x ₹{item.price}</p>
              </div>
              <span className="font-bold text-emerald-700">₹{item.quantity * item.price}</span>
            </div>
          ))}
        </div>

        {cart.length > 0 && user && (
          <div className="p-4 border-t space-y-4 bg-slate-50">
            <h3 className="font-bold text-sm">Delivery Address</h3>
            <input type="text" placeholder="Street Address" className="w-full p-2 border rounded" onChange={(e) => setAddress({...address, street: e.target.value})} />
            <div className="flex gap-2">
              <input type="text" placeholder="City" className="w-1/2 p-2 border rounded" onChange={(e) => setAddress({...address, city: e.target.value})} />
              <input type="text" placeholder="State" className="w-1/4 p-2 border rounded" onChange={(e) => setAddress({...address, state: e.target.value})} />
              <input type="text" placeholder="Zip" className="w-1/4 p-2 border rounded" onChange={(e) => setAddress({...address, zip: e.target.value})} />
            </div>

            <h3 className="font-bold text-sm mt-4">Payment Method</h3>
            <div className="flex gap-4">
              <label><input type="radio" name="payment" checked={paymentMethod==='Card'} onChange={()=>setPaymentMethod('Card')} /> Card</label>
              <label><input type="radio" name="payment" checked={paymentMethod==='UPI'} onChange={()=>setPaymentMethod('UPI')} /> UPI</label>
              <label><input type="radio" name="payment" checked={paymentMethod==='COD'} onChange={()=>setPaymentMethod('COD')} /> COD</label>
            </div>
            
            {paymentMethod === 'Card' && (
              <div className="flex gap-2">
                <input type="text" readOnly value={cardNumber} placeholder="XXXX XXXX XXXX XXXX" className="w-full p-2 border rounded font-mono text-sm" />
                <button onClick={generateMockCard} className="bg-slate-200 px-3 rounded text-xs font-bold">Generate</button>
              </div>
            )}

            <div className="flex gap-2">
              <input type="text" placeholder="Promo Code" className="w-full p-2 border rounded uppercase" onChange={(e) => setPromoCode(e.target.value)} />
              <button onClick={applyPromo} className="bg-emerald-100 text-emerald-700 px-3 rounded font-bold">Apply</button>
            </div>

            <div className="flex justify-between font-bold text-lg">
              <span>Total:</span>
              <span>₹{finalTotal.toFixed(2)}</span>
            </div>
            
            <button onClick={handleCheckout} className="w-full bg-emerald-600 text-white font-bold py-3 rounded-xl hover:bg-emerald-700">
              Confirm Order
            </button>
            <p className="text-center text-xs text-red-500 font-bold">{status}</p>
          </div>
        )}
      </div>
    </div>
  );
}