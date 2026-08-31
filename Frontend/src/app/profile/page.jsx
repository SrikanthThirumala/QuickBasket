'use client';
import { useState } from 'react';
import api from '../../lib/api';
import { useRouter } from 'next/navigation';

export default function ProfilePage() {
  const [oldPassword, setOldPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [status, setStatus] = useState('');
  const router = useRouter();

  const changePassword = async (e) => {
    e.preventDefault();
    try {
      await api.post('/api/auth/change-password', { old_password: oldPassword, new_password: newPassword });
      setStatus('Password changed successfully! Redirecting...');
      setTimeout(() => router.push('/'), 1500);
    } catch(err) {
      setStatus(err.response?.data?.error || 'Failed to change password.');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-slate-50">
      <div className="p-10 max-w-md w-full bg-white rounded-xl shadow-lg border hover:shadow-xl transition-all">
        <h2 className="text-2xl font-black mb-6 text-slate-800">Change Password</h2>
        <form onSubmit={changePassword} className="space-y-4">
          <input type="password" placeholder="Old Password" required className="w-full p-3 border rounded focus:ring-2 outline-none focus:ring-emerald-500 transition-all" onChange={e => setOldPassword(e.target.value)} />
          <input type="password" placeholder="New Password" required className="w-full p-3 border rounded focus:ring-2 outline-none focus:ring-emerald-500 transition-all" onChange={e => setNewPassword(e.target.value)} />
          <button className="pop-click w-full bg-emerald-600 text-white font-bold py-3 rounded hover:bg-emerald-700 transition-all">Update Password</button>
        </form>
        <p className="mt-4 font-bold text-emerald-700 text-center">{status}</p>
      </div>
    </div>
  );
}