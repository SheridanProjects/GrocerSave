import React, { useState, useEffect } from 'react';
import { ShoppingCart, Search, TrendingDown, Clock, Menu, User, LogIn } from 'lucide-react';

const App = () => {
  const [deals, setDeals] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showLogin, setShowLogin] = useState(false);
  const [isLoginMode, setIsLoginMode] = useState(true);
  const [authData, setAuthData] = useState({ username: '', password: '', email: '' });
  const [user, setUser] = useState(null);
  const [error, setError] = useState('');

  // Fetch deals from BFF
  useEffect(() => {
    fetch('/api/deals')
      .then(res => res.json())
      .then(data => {
        setDeals(data);
        setLoading(false);
      })
      .catch(err => {
        console.error("Failed to fetch deals:", err);
        setLoading(false);
      });
  }, []);

  const handleAuth = async (e) => {
    e.preventDefault();
    setError('');
    const endpoint = isLoginMode ? '/api/auth/login' : '/api/auth/signup';

    try {
      const res = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(authData),
      });

      const data = await res.json();

      if (!res.ok) throw new Error(data.error || 'Authentication failed');

      if (isLoginMode) {
        setUser(data.uid);
        localStorage.setItem('token', data.token);
        setShowLogin(false);
      } else {
        setIsLoginMode(true);
        setError('Account created! Please login.');
      }
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 font-sans text-gray-800 relative">
      {/* Header */}
      <header className="bg-green-600 text-white p-4 shadow-lg sticky top-0 z-50">
        <div className="max-w-6xl mx-auto flex justify-between items-center">
          <div className="flex items-center gap-2">
            <ShoppingCart size={28} />
            <h1 className="text-2xl font-bold tracking-tight">GrocerSave</h1>
          </div>

          <div className="hidden md:flex bg-green-700 rounded-lg p-2 items-center w-96 border border-green-500">
            <Search size={20} className="text-green-200 mr-2" />
            <input
              type="text"
              placeholder="Search for milk, eggs, bread..."
              className="bg-transparent border-none outline-none text-white placeholder-green-200 w-full"
            />
          </div>

          <div className="flex items-center gap-4">
            {user ? (
              <div className="flex items-center gap-2">
                <User size={20} />
                <span className="font-medium">{user}</span>
                <button onClick={() => { setUser(null); localStorage.removeItem('token'); }} className="text-xs bg-green-800 px-2 py-1 rounded">Logout</button>
              </div>
            ) : (
              <button onClick={() => setShowLogin(true)} className="flex items-center gap-1 hover:text-green-100">
                <LogIn size={20} /> Login
              </button>
            )}
            <Menu className="md:hidden cursor-pointer" />
          </div>
        </div>
      </header>

      {/* Login Modal */}
      {showLogin && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-2xl p-8 w-full max-w-md">
            <h2 className="text-2xl font-bold mb-6 text-center text-green-700">
              {isLoginMode ? 'Welcome Back' : 'Create Account'}
            </h2>

            {error && <div className="bg-red-100 text-red-700 p-2 rounded mb-4 text-sm text-center">{error}</div>}

            <form onSubmit={handleAuth} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Username</label>
                <input
                  type="text"
                  className="w-full border border-gray-300 rounded p-2 mt-1 focus:ring-2 focus:ring-green-500 outline-none"
                  value={authData.username}
                  onChange={(e) => setAuthData({...authData, username: e.target.value})}
                  required
                />
              </div>

              {!isLoginMode && (
                <div>
                  <label className="block text-sm font-medium text-gray-700">Email</label>
                  <input
                    type="email"
                    className="w-full border border-gray-300 rounded p-2 mt-1 focus:ring-2 focus:ring-green-500 outline-none"
                    value={authData.email}
                    onChange={(e) => setAuthData({...authData, email: e.target.value})}
                    required
                  />
                </div>
              )}

              <div>
                <label className="block text-sm font-medium text-gray-700">Password</label>
                <input
                  type="password"
                  className="w-full border border-gray-300 rounded p-2 mt-1 focus:ring-2 focus:ring-green-500 outline-none"
                  value={authData.password}
                  onChange={(e) => setAuthData({...authData, password: e.target.value})}
                  required
                />
              </div>

              <button type="submit" className="w-full bg-green-600 text-white py-2 rounded font-bold hover:bg-green-700 transition">
                {isLoginMode ? 'Login' : 'Sign Up'}
              </button>
            </form>

            <p className="mt-4 text-center text-sm text-gray-600">
              {isLoginMode ? "Don't have an account? " : "Already have an account? "}
              <button
                onClick={() => { setIsLoginMode(!isLoginMode); setError(''); }}
                className="text-green-600 font-bold hover:underline"
              >
                {isLoginMode ? 'Sign Up' : 'Login'}
              </button>
            </p>

            <button onClick={() => setShowLogin(false)} className="absolute top-4 right-4 text-gray-400 hover:text-gray-600">
              ✕
            </button>
          </div>
        </div>
      )}

      {/* Hero Section */}
      <div className="bg-green-600 text-white pb-16 pt-8 px-4 text-center">
        <h2 className="text-4xl font-bold mb-4">Stop Overspending on Groceries.</h2>
        <p className="text-lg opacity-90 mb-8">Compare real-time prices across local stores and track history.</p>
      </div>

      {/* Main Content */}
      <main className="max-w-6xl mx-auto -mt-10 px-4 pb-12">
        <div className="bg-white rounded-xl shadow-xl p-6 mb-8">
          <h3 className="text-xl font-bold mb-6 flex items-center gap-2">
            <TrendingDown className="text-green-600" /> Today's Top Drops
          </h3>

          {loading ? (
            <div className="text-center py-10 text-gray-400">Loading best deals...</div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {deals.map((deal) => (
                <div key={deal.id} className="border border-gray-100 rounded-lg p-4 hover:shadow-md transition-shadow bg-white">
                  <div className="h-32 bg-gray-100 rounded-md mb-4 flex items-center justify-center text-gray-400">
                    Image
                  </div>
                  <div className="flex justify-between items-start">
                    <div>
                      <h4 className="font-bold text-lg">{deal.item}</h4>
                      <p className="text-sm text-gray-500 flex items-center gap-1">
                        <Clock size={12} /> {deal.store}
                      </p>
                    </div>
                    <span className="bg-red-100 text-red-700 text-xs font-bold px-2 py-1 rounded">
                      -{deal.drop}
                    </span>
                  </div>
                  <div className="mt-3 flex items-end gap-2">
                    <span className="text-2xl font-bold text-green-700">${deal.price}</span>
                    <span className="text-sm text-gray-400 line-through mb-1">${deal.oldPrice}</span>
                  </div>
                  <button className="w-full mt-4 bg-green-50 text-green-700 py-2 rounded-md font-medium hover:bg-green-100 transition-colors">
                    View History
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Features Section */}
        <div className="grid md:grid-cols-3 gap-6 text-center">
          <div className="p-6">
            <div className="bg-blue-100 w-12 h-12 rounded-full flex items-center justify-center mx-auto mb-4 text-blue-600 font-bold">1</div>
            <h4 className="font-bold mb-2">Real-Time Scraping</h4>
            <p className="text-sm text-gray-500">Our bots check prices daily so you don't have to.</p>
          </div>
          <div className="p-6">
            <div className="bg-purple-100 w-12 h-12 rounded-full flex items-center justify-center mx-auto mb-4 text-purple-600 font-bold">2</div>
            <h4 className="font-bold mb-2">Price History</h4>
            <p className="text-sm text-gray-500">See if a "sale" is actually a good deal using historical data.</p>
          </div>
          <div className="p-6">
            <div className="bg-orange-100 w-12 h-12 rounded-full flex items-center justify-center mx-auto mb-4 text-orange-600 font-bold">3</div>
            <h4 className="font-bold mb-2">Smart Alerts</h4>
            <p className="text-sm text-gray-500">Get notified when your staples drop below your target price.</p>
          </div>
        </div>
      </main>
    </div>
  );
};

export default App;