// src/app/profile/page.jsx
'use client';
import { useState } from 'react';
import api from '../../lib/api';
import { useRouter } from 'next/navigation';

export default function ProfilePage() {
  const [passwordData, setPasswordData] = useState({ old_password: '', new_password: '' });
  const [emailData, setEmailData] = useState({ new_email: '', password: '' });
  const [pwdStatus, setPwdStatus] = useState('');
  const [emailStatus, setEmailStatus] = useState('');
  const router = useRouter();

  const changePassword = async (e) => {
    e.preventDefault();
    try {
      await api.post('/api/auth/change-password', passwordData);
      setPwdStatus('Password changed successfully! Redirecting...');
      setTimeout(() => router.push('/'), 1500);
    } catch(err) {
      setPwdStatus(err.response?.data?.error || 'Failed to change password.');
    }
  };

  const changeEmail = async (e) => {
    e.preventDefault();
    try {
      await api.put('/api/auth/change-email', emailData);
      setEmailStatus('Email updated successfully!');
    } catch(err) {
      setEmailStatus(err.response?.data?.error || 'Failed to update email.');
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 py-10 px-4 sm:px-6 lg:px-8">
      <div className="max-w-4xl mx-auto w-full">
        
        {/* Header with Back Button */}
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-3xl font-black text-slate-900">My Profile</h1>
          <button onClick={() => router.push('/')} className="text-emerald-600 font-bold hover:underline transition-all">
            &larr; Back to Store
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {/* Email Update Card */}
          <div className="p-8 bg-white rounded-xl shadow-lg border hover:shadow-xl transition-all">
            <h2 className="text-2xl font-black mb-6 text-slate-800">Update Email</h2>
            <form onSubmit={changeEmail} className="space-y-4">
              <input type="email" placeholder="New Email Address" required className="w-full p-3 border rounded focus:ring-2 outline-none focus:ring-emerald-500 transition-all" onChange={e => setEmailData({...emailData, new_email: e.target.value})} />
              <input type="password" placeholder="Current Password" required className="w-full p-3 border rounded focus:ring-2 outline-none focus:ring-emerald-500 transition-all" onChange={e => setEmailData({...emailData, password: e.target.value})} />
              <button className="pop-click w-full bg-blue-600 text-white font-bold py-3 rounded hover:bg-blue-700 transition-all">Update Email</button>
            </form>
            <p className="mt-4 font-bold text-blue-700 text-center">{emailStatus}</p>
          </div>

          {/* Password Update Card */}
          <div className="p-8 bg-white rounded-xl shadow-lg border hover:shadow-xl transition-all">
            <h2 className="text-2xl font-black mb-6 text-slate-800">Change Password</h2>
            <form onSubmit={changePassword} className="space-y-4">
              <input type="password" placeholder="Old Password" required className="w-full p-3 border rounded focus:ring-2 outline-none focus:ring-emerald-500 transition-all" onChange={e => setPasswordData({...passwordData, old_password: e.target.value})} />
              <input type="password" placeholder="New Password" required className="w-full p-3 border rounded focus:ring-2 outline-none focus:ring-emerald-500 transition-all" onChange={e => setPasswordData({...passwordData, new_password: e.target.value})} />
              <button className="pop-click w-full bg-emerald-600 text-white font-bold py-3 rounded hover:bg-emerald-700 transition-all">Update Password</button>
            </form>
            <p className="mt-4 font-bold text-emerald-700 text-center">{pwdStatus}</p>
          </div>
        </div>

      </div>
    </div>
  );
}