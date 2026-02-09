import React, { useState, useEffect } from 'react';
import { ShoppingCart, Search, TrendingDown, Clock, Menu, User, LogIn, X, ChevronRight, Star, ArrowRight } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { Toaster, toast } from 'react-hot-toast';

const App = () => {
  const [deals, setDeals] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showLogin, setShowLogin] = useState(false);
  const [isLoginMode, setIsLoginMode] = useState(true);
  const [authData, setAuthData] = useState({ username: '', password: '', email: '' });
  const [user, setUser] = useState(null);

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
        toast.error("Could not load deals. Please try again later.");
      });
  }, []);

  const handleAuth = async (e) => {
    e.preventDefault();
    const endpoint = isLoginMode ? '/api/auth/login' : '/api/auth/signup';
    const loadingToast = toast.loading(isLoginMode ? 'Signing in...' : 'Creating account...');

    try {
      const res = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(authData),
      });

      const data = await res.json();

      if (!res.ok) throw new Error(data.error || 'Authentication failed');

      toast.dismiss(loadingToast);

      if (isLoginMode) {
        setUser(data.uid);
        localStorage.setItem('token', data.token);
        setShowLogin(false);
        toast.success(`Welcome back, ${data.uid}!`);
      } else {
        setIsLoginMode(true);
        toast.success('Account created! Please login.');
      }
    } catch (err) {
      toast.dismiss(loadingToast);
      toast.error(err.message);
    }
  };

  return (
    <div className="min-h-screen flex flex-col bg-[#F8FAFC] font-sans text-slate-800">
      <Toaster position="top-center" reverseOrder={false} />

      {/* Navbar */}
      <nav className="bg-white/90 backdrop-blur-xl border-b border-slate-100 sticky top-0 z-40 transition-all duration-300">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-20">
            {/* Logo */}
            <motion.div
              whileHover={{ scale: 1.02 }}
              className="flex items-center gap-3 cursor-pointer"
            >
              <div className="bg-gradient-to-br from-emerald-500 to-teal-600 p-2.5 rounded-xl shadow-lg shadow-emerald-200">
                <ShoppingCart className="text-white" size={24} strokeWidth={2.5} />
              </div>
              <span className="text-2xl font-bold tracking-tight text-slate-900">
                Grocer<span className="text-emerald-600">Save</span>
              </span>
            </motion.div>

            {/* Search Bar (Desktop) */}
            <div className="hidden md:flex flex-1 max-w-xl mx-12 relative group">
              <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                <Search className="text-slate-400 group-focus-within:text-emerald-500 transition-colors" size={20} />
              </div>
              <input
                type="text"
                placeholder="Search for milk, eggs, bread..."
                className="block w-full pl-12 pr-4 py-3 border border-slate-200 rounded-2xl leading-5 bg-slate-50 placeholder-slate-400 focus:outline-none focus:bg-white focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 transition-all duration-300 shadow-sm"
              />
            </div>

            {/* Right Actions */}
            <div className="flex items-center gap-4">
              {user ? (
                <motion.div
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  className="flex items-center gap-3 bg-white pl-2 pr-4 py-1.5 rounded-full border border-slate-200 shadow-sm"
                >
                  <div className="bg-emerald-100 p-2 rounded-full">
                    <User size={18} className="text-emerald-700" />
                  </div>
                  <div className="flex flex-col">
                    <span className="text-xs text-slate-500 font-medium leading-none">Hello,</span>
                    <span className="text-sm font-bold text-slate-800 leading-none">{user}</span>
                  </div>
                  <button
                    onClick={() => { setUser(null); localStorage.removeItem('token'); toast.success('Logged out successfully'); }}
                    className="ml-2 p-1.5 hover:bg-red-50 text-slate-400 hover:text-red-500 rounded-full transition-colors"
                    title="Logout"
                  >
                    <LogOutIcon size={16} />
                  </button>
                </motion.div>
              ) : (
                <motion.button
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  onClick={() => setShowLogin(true)}
                  className="bg-slate-900 text-white px-6 py-2.5 rounded-full font-semibold shadow-lg shadow-slate-200 hover:bg-slate-800 transition-all flex items-center gap-2"
                >
                  <LogIn size={18} /> <span>Sign In</span>
                </motion.button>
              )}
              <Menu className="md:hidden text-slate-600 cursor-pointer hover:text-slate-900" />
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <div className="relative bg-white overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-r from-emerald-50 to-teal-50/50"></div>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-20 pb-24 relative z-10">
          <div className="text-center max-w-3xl mx-auto">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
            >
              <span className="inline-block py-1 px-3 rounded-full bg-emerald-100 text-emerald-700 text-xs font-bold tracking-wide uppercase mb-6">
                New: Price History Tracking
              </span>
              <h1 className="text-5xl md:text-7xl font-extrabold text-slate-900 mb-8 leading-tight tracking-tight">
                Smart Savings on <br/>
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-600 to-teal-500">Every Grocery Run.</span>
              </h1>
              <p className="text-xl text-slate-600 mb-10 leading-relaxed">
                Compare real-time prices across local stores, track price history, and never overpay for your staples again.
              </p>
              <div className="flex flex-col sm:flex-row justify-center gap-4">
                <motion.button
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  className="bg-emerald-600 text-white text-lg px-8 py-4 rounded-full font-bold shadow-xl shadow-emerald-200 hover:bg-emerald-700 transition-all flex items-center justify-center gap-2"
                >
                  Start Saving Now <ArrowRight size={20} />
                </motion.button>
                <motion.button
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  className="bg-white text-slate-700 border border-slate-200 text-lg px-8 py-4 rounded-full font-bold hover:bg-slate-50 transition-all shadow-sm"
                >
                  How it Works
                </motion.button>
              </div>
            </motion.div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <main className="flex-grow max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 w-full">
        {/* Deals Grid */}
        <div className="mb-20">
          <div className="flex justify-between items-end mb-10">
            <div>
              <h3 className="text-3xl font-bold text-slate-900 flex items-center gap-3">
                <div className="bg-red-100 p-2 rounded-lg">
                  <TrendingDown className="text-red-600" size={24} />
                </div>
                Today's Top Drops
              </h3>
              <p className="text-slate-500 mt-2 text-lg">Best deals found in your area within the last 24 hours.</p>
            </div>
            <button className="text-emerald-600 font-bold hover:text-emerald-700 flex items-center gap-1 group">
              View all deals <ChevronRight size={20} className="group-hover:translate-x-1 transition-transform" />
            </button>
          </div>

          {loading ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
              {[1, 2, 3, 4].map((i) => (
                <div key={i} className="bg-white rounded-3xl h-96 animate-pulse border border-slate-100"></div>
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
              {deals.map((deal, index) => (
                <motion.div
                  key={deal.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1 }}
                  whileHover={{ y: -8 }}
                  className="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden hover:shadow-xl hover:shadow-slate-200/50 transition-all duration-300 group cursor-pointer"
                >
                  <div className="relative h-56 bg-slate-50 overflow-hidden">
                    <div className="absolute top-4 right-4 bg-white/90 backdrop-blur-md text-red-600 text-sm font-bold px-3 py-1.5 rounded-full shadow-sm z-10 border border-red-100">
                      -{deal.drop}
                    </div>
                    <div className="w-full h-full flex items-center justify-center text-slate-300 group-hover:scale-110 transition-transform duration-700">
                      <ShoppingCart size={64} strokeWidth={1} />
                    </div>
                  </div>

                  <div className="p-6">
                    <div className="mb-4">
                      <h4 className="font-bold text-lg text-slate-900 line-clamp-1 mb-1">{deal.item}</h4>
                      <div className="flex items-center gap-2 text-sm text-slate-500">
                        <Clock size={14} />
                        <span>Found at <span className="font-semibold text-slate-700">{deal.store}</span></span>
                      </div>
                    </div>

                    <div className="flex items-end justify-between pt-4 border-t border-slate-50">
                      <div>
                        <span className="text-sm text-slate-400 line-through font-medium">${deal.oldPrice}</span>
                        <div className="text-3xl font-extrabold text-slate-900 tracking-tight">${deal.price}</div>
                      </div>
                      <button className="bg-emerald-50 text-emerald-600 p-3 rounded-2xl hover:bg-emerald-600 hover:text-white transition-all duration-300">
                        <ArrowRight size={20} />
                      </button>
                    </div>
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </div>

        {/* Features Section */}
        <div className="grid md:grid-cols-3 gap-8">
          {[
            { icon: <Search size={28} />, title: "Real-Time Scraping", desc: "Our bots check prices daily so you don't have to.", color: "bg-blue-50 text-blue-600" },
            { icon: <Clock size={28} />, title: "Price History", desc: "See if a 'sale' is actually a good deal using historical data.", color: "bg-purple-50 text-purple-600" },
            { icon: <Star size={28} />, title: "Smart Alerts", desc: "Get notified when your staples drop below your target price.", color: "bg-orange-50 text-orange-600" }
          ].map((feature, i) => (
            <motion.div
              key={i}
              whileHover={{ y: -5 }}
              className="bg-white p-10 rounded-3xl shadow-sm border border-slate-100 text-center hover:shadow-xl hover:shadow-slate-200/40 transition-all duration-300"
            >
              <div className={`w-20 h-20 mx-auto rounded-3xl flex items-center justify-center mb-8 ${feature.color}`}>
                {feature.icon}
              </div>
              <h4 className="text-2xl font-bold mb-4 text-slate-900">{feature.title}</h4>
              <p className="text-slate-500 leading-relaxed text-lg">{feature.desc}</p>
            </motion.div>
          ))}
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-white border-t border-slate-100 py-16 mt-auto">
        <div className="max-w-7xl mx-auto px-4 text-center">
          <div className="flex items-center justify-center gap-2 mb-6 opacity-50">
            <ShoppingCart size={24} />
            <span className="text-xl font-bold">GrocerSave</span>
          </div>
          <p className="text-slate-400 text-sm">&copy; 2023 GrocerSave. Built for smart shoppers.</p>
        </div>
      </footer>

      {/* Login Modal */}
      <AnimatePresence>
        {showLogin && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-50 p-4"
          >
            <motion.div
              initial={{ scale: 0.95, opacity: 0, y: 20 }}
              animate={{ scale: 1, opacity: 1, y: 0 }}
              exit={{ scale: 0.95, opacity: 0, y: 20 }}
              className="bg-white rounded-3xl shadow-2xl w-full max-w-md overflow-hidden relative"
            >
              <button
                onClick={() => setShowLogin(false)}
                className="absolute top-6 right-6 text-slate-400 hover:text-slate-600 p-2 rounded-full hover:bg-slate-50 transition-colors"
              >
                <X size={24} />
              </button>

              <div className="p-10">
                <div className="text-center mb-10">
                  <div className="bg-emerald-50 w-20 h-20 rounded-3xl flex items-center justify-center mx-auto mb-6 text-emerald-600 shadow-inner">
                    {isLoginMode ? <LogIn size={32} /> : <User size={32} />}
                  </div>
                  <h2 className="text-3xl font-bold text-slate-900 mb-2">
                    {isLoginMode ? 'Welcome Back' : 'Join GrocerSave'}
                  </h2>
                  <p className="text-slate-500">
                    {isLoginMode ? 'Enter your details to access your account' : 'Start saving money on your groceries today'}
                  </p>
                </div>

                <form onSubmit={handleAuth} className="space-y-5">
                  <div>
                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2 ml-1">Username</label>
                    <input
                      type="text"
                      className="w-full px-5 py-4 rounded-2xl bg-slate-50 border-2 border-transparent focus:bg-white focus:border-emerald-500 focus:ring-0 outline-none transition-all font-medium text-slate-900 placeholder-slate-400"
                      placeholder="johndoe"
                      value={authData.username}
                      onChange={(e) => setAuthData({...authData, username: e.target.value})}
                      required
                    />
                  </div>

                  {!isLoginMode && (
                    <motion.div initial={{ height: 0, opacity: 0 }} animate={{ height: 'auto', opacity: 1 }}>
                      <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2 ml-1">Email</label>
                      <input
                        type="email"
                        className="w-full px-5 py-4 rounded-2xl bg-slate-50 border-2 border-transparent focus:bg-white focus:border-emerald-500 focus:ring-0 outline-none transition-all font-medium text-slate-900 placeholder-slate-400"
                        placeholder="john@example.com"
                        value={authData.email}
                        onChange={(e) => setAuthData({...authData, email: e.target.value})}
                        required
                      />
                    </motion.div>
                  )}

                  <div>
                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2 ml-1">Password</label>
                    <input
                      type="password"
                      className="w-full px-5 py-4 rounded-2xl bg-slate-50 border-2 border-transparent focus:bg-white focus:border-emerald-500 focus:ring-0 outline-none transition-all font-medium text-slate-900 placeholder-slate-400"
                      placeholder="••••••••"
                      value={authData.password}
                      onChange={(e) => setAuthData({...authData, password: e.target.value})}
                      required
                    />
                  </div>

                  <motion.button
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                    type="submit"
                    className="w-full bg-emerald-600 text-white py-4 rounded-2xl font-bold text-lg shadow-lg shadow-emerald-200 hover:bg-emerald-700 transition-all mt-4"
                  >
                    {isLoginMode ? 'Sign In' : 'Create Account'}
                  </motion.button>
                </form>

                <div className="mt-8 text-center">
                  <p className="text-slate-500 font-medium">
                    {isLoginMode ? "Don't have an account? " : "Already have an account? "}
                    <button
                      onClick={() => { setIsLoginMode(!isLoginMode); }}
                      className="text-emerald-600 font-bold hover:underline ml-1"
                    >
                      {isLoginMode ? 'Sign Up' : 'Log In'}
                    </button>
                  </p>
                </div>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

// Helper Icon for Logout
const LogOutIcon = ({ size }) => (
  <svg xmlns="http://www.w3.org/2000/svg" width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
    <polyline points="16 17 21 12 16 7"></polyline>
    <line x1="21" y1="12" x2="9" y2="12"></line>
  </svg>
);

export default App;