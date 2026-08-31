'use client';
import { useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import api from '../../lib/api';

export default function LoginPage() {
  const [step, setStep] = useState('login'); 
  const [formData, setFormData] = useState({ username: '', email: '', password: '', otp_code: '' });
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const { login } = useAuth();

  const handleAuth = async (e) => {
    e.preventDefault();
    setError('');
    
    if (step === 'signup') {
      try {
        await api.post('/api/auth/signup', formData);
        setSuccess('OTP sent to your email!');
        setStep('otp');
      } catch (err) {
        setError(err.response?.data?.error || 'Signup failed.');
      }
    } else if (step === 'otp') {
      try {
        await api.post('/api/auth/verify-otp', { email: formData.email, otp_code: formData.otp_code });
        setSuccess('Account verified! Please sign in.');
        setStep('login'); 
      } catch (err) {
        setError(err.response?.data?.error || 'Invalid OTP.');
      }
    } else if (step === 'login') {
      try {
        const { data } = await api.post('/api/auth/signin', formData);
        login(data.token);
      } catch (err) {
        setError(err.response?.data?.error || 'Login failed.');
      }
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-4 bg-slate-50">
      <div className="bg-white p-8 rounded-2xl shadow-lg border border-slate-200 w-full max-w-md transition-all duration-300 hover:shadow-xl">
        <h2 className="text-3xl font-black text-emerald-700 text-center mb-6">QuickBasket</h2>
        
        {error && <div className="bg-red-50 text-red-600 p-3 rounded mb-4 text-sm font-bold animate-pulse">{error}</div>}
        {success && <div className="bg-emerald-50 text-emerald-700 p-3 rounded mb-4 text-sm font-bold">{success}</div>}

        <form onSubmit={handleAuth} className="space-y-4">
          {step === 'otp' ? (
            <input type="text" placeholder="Enter 6-digit OTP" required maxLength="6" className="w-full p-3 border rounded-lg text-center tracking-widest font-bold text-xl outline-none focus:ring-2 focus:ring-emerald-500 transition-all" onChange={(e) => setFormData({...formData, otp_code: e.target.value})} />
          ) : (
            <>
              {step === 'signup' && (
                <input type="text" placeholder="Username" required className="w-full p-3 border rounded-lg outline-none focus:ring-2 focus:ring-emerald-500 transition-all" onChange={(e) => setFormData({...formData, username: e.target.value})} />
              )}
              <input type="email" placeholder="Email Address" required className="w-full p-3 border rounded-lg outline-none focus:ring-2 focus:ring-emerald-500 transition-all" onChange={(e) => setFormData({...formData, email: e.target.value})} />
              <input type="password" placeholder="Password" required className="w-full p-3 border rounded-lg outline-none focus:ring-2 focus:ring-emerald-500 transition-all" onChange={(e) => setFormData({...formData, password: e.target.value})} />
            </>
          )}
          <button type="submit" className="pop-click w-full bg-emerald-600 text-white font-bold py-3 rounded-lg hover:bg-emerald-700 transition-all">
            {step === 'otp' ? 'Verify OTP' : step === 'login' ? 'Sign In' : 'Send OTP'}
          </button>
        </form>

        {step !== 'otp' && (
          <p className="mt-6 text-center text-sm text-slate-500">
            <button type="button" onClick={() => { setStep(step === 'login' ? 'signup' : 'login'); setError(''); setSuccess(''); }} className="text-emerald-600 font-bold hover:underline transition-all">
              {step === 'login' ? 'Create an account' : 'Sign in instead'}
            </button>
          </p>
        )}
      </div>
    </div>
  );
}