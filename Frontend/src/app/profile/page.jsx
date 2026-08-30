'use client';
import { useState } from 'react';
import api from '../../lib/api';

export default function ProfilePage() {
  const [oldPassword, setOldPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [status, setStatus] = useState('');

  const changePassword = async (e) => {
    e.preventDefault();
    try {
      await api.post('/api/auth/change-password', { old_password: oldPassword, new_password: newPassword });
      setStatus('Password changed successfully!');
    } catch(err) {
      setStatus(err.response?.data?.error || 'Failed to change password.');
    }
  };

  return (
    <div className="p-10 max-w-md mx-auto">
      <h2 className="text-2xl font-black mb-6">Change Password</h2>
      <form onSubmit={changePassword} className="space-y-4">
        <input type="password" placeholder="Old Password" required className="w-full p-3 border rounded" onChange={e => setOldPassword(e.target.value)} />
        <input type="password" placeholder="New Password" required className="w-full p-3 border rounded" onChange={e => setNewPassword(e.target.value)} />
        <button className="w-full bg-emerald-600 text-white font-bold py-3 rounded hover:bg-emerald-700">Update Password</button>
      </form>
      <p className="mt-4 font-bold text-emerald-700">{status}</p>
    </div>
  );
}