import React, { useState, useEffect } from 'react';
import { ShoppingCart, Search, TrendingDown, Clock, Menu, User, LogIn, X, ChevronRight, Star } from 'lucide-react';

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
    <div className="min-h-screen flex flex-col">
      {/* Navbar */}
      <nav className="bg-white/80 backdrop-blur-md border-b border-gray-100 sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            {/* Logo */}
            <div className="flex items-center gap-2 cursor-pointer group">
              <div className="bg-emerald-100 p-2 rounded-lg group-hover:bg-emerald-200 transition-colors">
                <ShoppingCart className="text-emerald-600" size={24} />
              </div>
              <span className="text-xl font-bold text-gray-800 tracking-tight">Grocer<span className="text-emerald-600">Save</span></span>
            </div>

            {/* Search Bar (Desktop) */}
            <div className="hidden md:flex flex-1 max-w-lg mx-8 relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Search className="text-gray-400" size={18} />
              </div>
              <input
                type="text"
                placeholder="Search for milk, eggs, bread..."
                className="block w-full pl-10 pr-3 py-2 border border-gray-200 rounded-full leading-5 bg-gray-50 placeholder-gray-400 focus:outline-none focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-transparent transition-all duration-200"
              />
            </div>

            {/* Right Actions */}
            <div className="flex items-center gap-4">
              {user ? (
                <div className="flex items-center gap-3 bg-gray-50 px-3 py-1.5 rounded-full border border-gray-200">
                  <div className="bg-emerald-100 p-1 rounded-full">
                    <User size={16} className="text-emerald-700" />
                  </div>
                  <span className="text-sm font-medium text-gray-700">{user}</span>
                  <button
                    onClick={() => { setUser(null); localStorage.removeItem('token'); }}
                    className="text-xs text-gray-500 hover:text-red-600 font-medium ml-1 transition-colors"
                  >
                    Sign out
                  </button>
                </div>
              ) : (
                <button onClick={() => setShowLogin(true)} className="btn-primary flex items-center gap-2 text-sm">
                  <LogIn size={18} /> <span>Sign In</span>
                </button>
              )}
              <Menu className="md:hidden text-gray-600 cursor-pointer" />
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <div className="relative bg-emerald-900 overflow-hidden">
        <div className="absolute inset-0 opacity-20 bg-[url('https://images.unsplash.com/photo-1542838132-92c53300491e?ixlib=rb-4.0.3&auto=format&fit=crop&w=2000&q=80')] bg-cover bg-center mix-blend-overlay"></div>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24 relative z-10 text-center">
          <h1 className="text-4xl md:text-6xl font-extrabold text-white mb-6 leading-tight animate-fade-in">
            Smart Savings on <br/><span className="text-emerald-300">Every Grocery Run.</span>
          </h1>
          <p className="text-lg md:text-xl text-emerald-100 mb-10 max-w-2xl mx-auto animate-fade-in" style={{animationDelay: '0.1s'}}>
            Compare real-time prices across local stores, track price history, and never overpay for your staples again.
          </p>
          <div className="flex justify-center gap-4 animate-fade-in" style={{animationDelay: '0.2s'}}>
            <button className="btn-primary bg-white text-emerald-900 hover:bg-gray-100 border-none text-lg px-8 py-3">
              Start Saving
            </button>
            <button className="btn-secondary bg-transparent text-white border-white hover:bg-white/10 text-lg px-8 py-3">
              Learn More
            </button>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <main className="flex-grow max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 w-full -mt-16 relative z-20">
        {/* Deals Grid */}
        <div className="bg-white rounded-3xl shadow-xl border border-gray-100 p-8 mb-12">
          <div className="flex justify-between items-end mb-8">
            <div>
              <h3 className="text-2xl font-bold text-gray-900 flex items-center gap-2">
                <TrendingDown className="text-emerald-500" /> Today's Top Drops
              </h3>
              <p className="text-gray-500 mt-1">Best deals found in your area within the last 24 hours.</p>
            </div>
            <button className="text-emerald-600 font-semibold hover:text-emerald-700 flex items-center gap-1 text-sm">
              View all <ChevronRight size={16} />
            </button>
          </div>

          {loading ? (
            <div className="flex justify-center py-20">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-emerald-600"></div>
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
              {deals.map((deal, index) => (
                <div key={deal.id} className="card group animate-fade-in" style={{animationDelay: `${index * 0.1}s`}}>
                  <div className="relative h-48 bg-gray-100 overflow-hidden">
                    <div className="absolute top-3 right-3 bg-red-500 text-white text-xs font-bold px-2 py-1 rounded-md shadow-sm z-10">
                      -{deal.drop}
                    </div>
                    {/* Placeholder for actual image */}
                    <div className="w-full h-full flex items-center justify-center text-gray-300 bg-gray-50 group-hover:scale-105 transition-transform duration-500">
                      <ShoppingCart size={48} opacity={0.2} />
                    </div>
                  </div>

                  <div className="p-5">
                    <div className="flex justify-between items-start mb-2">
                      <h4 className="font-bold text-gray-900 line-clamp-1" title={deal.item}>{deal.item}</h4>
                    </div>

                    <div className="flex items-center gap-2 text-sm text-gray-500 mb-4">
                      <Clock size={14} />
                      <span>{deal.store}</span>
                    </div>

                    <div className="flex items-end justify-between mt-4">
                      <div>
                        <span className="text-xs text-gray-400 line-through block">${deal.oldPrice}</span>
                        <span className="text-2xl font-bold text-emerald-700">${deal.price}</span>
                      </div>
                      <button className="bg-emerald-50 text-emerald-700 p-2 rounded-lg hover:bg-emerald-100 transition-colors">
                        <TrendingDown size={20} />
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Features Section */}
        <div className="grid md:grid-cols-3 gap-8 mb-12">
          {[
            { icon: <Search size={24} />, title: "Real-Time Scraping", desc: "Our bots check prices daily so you don't have to.", color: "blue" },
            { icon: <Clock size={24} />, title: "Price History", desc: "See if a 'sale' is actually a good deal using historical data.", color: "purple" },
            { icon: <Star size={24} />, title: "Smart Alerts", desc: "Get notified when your staples drop below your target price.", color: "orange" }
          ].map((feature, i) => (
            <div key={i} className="bg-white p-8 rounded-2xl shadow-sm border border-gray-100 text-center hover:shadow-md transition-all duration-300">
              <div className={`w-14 h-14 mx-auto rounded-2xl flex items-center justify-center mb-6 bg-${feature.color}-50 text-${feature.color}-600`}>
                {feature.icon}
              </div>
              <h4 className="text-xl font-bold mb-3 text-gray-900">{feature.title}</h4>
              <p className="text-gray-500 leading-relaxed">{feature.desc}</p>
            </div>
          ))}
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-white border-t border-gray-100 py-12">
        <div className="max-w-7xl mx-auto px-4 text-center text-gray-400 text-sm">
          <p>&copy; 2023 GrocerSave. All rights reserved.</p>
        </div>
      </footer>

      {/* Login Modal */}
      {showLogin && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-fade-in">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden relative">
            <button
              onClick={() => setShowLogin(false)}
              className="absolute top-4 right-4 text-gray-400 hover:text-gray-600 p-1 rounded-full hover:bg-gray-100 transition-colors"
            >
              <X size={20} />
            </button>

            <div className="p-8 pt-10">
              <div className="text-center mb-8">
                <div className="bg-emerald-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4 text-emerald-600">
                  {isLoginMode ? <LogIn size={28} /> : <User size={28} />}
                </div>
                <h2 className="text-2xl font-bold text-gray-900">
                  {isLoginMode ? 'Welcome Back' : 'Create Account'}
                </h2>
                <p className="text-gray-500 mt-2 text-sm">
                  {isLoginMode ? 'Enter your details to access your account' : 'Join us to start saving today'}
                </p>
              </div>

              {error && (
                <div className="bg-red-50 text-red-600 p-3 rounded-lg mb-6 text-sm text-center border border-red-100">
                  {error}
                </div>
              )}

              <form onSubmit={handleAuth} className="space-y-5">
                <div>
                  <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1.5">Username</label>
                  <input
                    type="text"
                    className="input-field"
                    placeholder="johndoe"
                    value={authData.username}
                    onChange={(e) => setAuthData({...authData, username: e.target.value})}
                    required
                  />
                </div>

                {!isLoginMode && (
                  <div className="animate-fade-in">
                    <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1.5">Email</label>
                    <input
                      type="email"
                      className="input-field"
                      placeholder="john@example.com"
                      value={authData.email}
                      onChange={(e) => setAuthData({...authData, email: e.target.value})}
                      required
                    />
                  </div>
                )}

                <div>
                  <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1.5">Password</label>
                  <input
                    type="password"
                    className="input-field"
                    placeholder="••••••••"
                    value={authData.password}
                    onChange={(e) => setAuthData({...authData, password: e.target.value})}
                    required
                  />
                </div>

                <button type="submit" className="btn-primary w-full py-3 mt-2">
                  {isLoginMode ? 'Sign In' : 'Create Account'}
                </button>
              </form>

              <div className="mt-8 text-center pt-6 border-t border-gray-100">
                <p className="text-sm text-gray-600">
                  {isLoginMode ? "Don't have an account? " : "Already have an account? "}
                  <button
                    onClick={() => { setIsLoginMode(!isLoginMode); setError(''); }}
                    className="text-emerald-600 font-bold hover:text-emerald-700 transition-colors"
                  >
                    {isLoginMode ? 'Sign Up' : 'Log In'}
                  </button>
                </p>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default App;