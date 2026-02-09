import React, { useState, useEffect } from 'react';
import { ShoppingCart, Search, TrendingDown, Clock, Menu, User, LogIn, X, ChevronRight, Star, ArrowRight, ShieldCheck, Zap } from 'lucide-react';
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
    <div className="min-h-screen flex flex-col bg-slate-50 font-sans text-slate-900 selection:bg-emerald-100 selection:text-emerald-900 relative overflow-x-hidden">
      <Toaster position="top-center" toastOptions={{ className: 'font-medium text-sm' }} />

      {/* Background Elements */}
      <div className="fixed inset-0 z-0 pointer-events-none">
        <div className="absolute inset-0 bg-[linear-gradient(to_right,#80808012_1px,transparent_1px),linear-gradient(to_bottom,#80808012_1px,transparent_1px)] bg-[size:24px_24px]"></div>
        <div className="absolute top-0 right-0 w-[800px] h-[800px] bg-emerald-200/20 rounded-full blur-[120px] -translate-y-1/2 translate-x-1/3"></div>
        <div className="absolute bottom-0 left-0 w-[600px] h-[600px] bg-teal-200/20 rounded-full blur-[100px] translate-y-1/3 -translate-x-1/4"></div>
      </div>

      {/* Navbar */}
      <nav className="sticky top-0 z-50 w-full backdrop-blur-md bg-white/70 border-b border-slate-200/60 supports-[backdrop-filter]:bg-white/60">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-20">
            {/* Logo */}
            <motion.div
              whileHover={{ scale: 1.02 }}
              className="flex items-center gap-3 cursor-pointer"
            >
              <div className="bg-emerald-600 p-2.5 rounded-xl shadow-lg shadow-emerald-200/50">
                <ShoppingCart className="text-white" size={22} strokeWidth={2.5} />
              </div>
              <span className="text-2xl font-bold tracking-tight text-slate-900">
                Grocer<span className="text-emerald-600">Save</span>
              </span>
            </motion.div>

            {/* Desktop Nav Links */}
            <div className="hidden md:flex items-center gap-8 text-sm font-medium text-slate-600">
              <a href="#" className="hover:text-emerald-600 transition-colors">Deals</a>
              <a href="#" className="hover:text-emerald-600 transition-colors">Stores</a>
              <a href="#" className="hover:text-emerald-600 transition-colors">History</a>
            </div>

            {/* Right Actions */}
            <div className="flex items-center gap-4">
              <div className="hidden md:flex relative group">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4 group-focus-within:text-emerald-500 transition-colors" />
                <input
                  type="text"
                  placeholder="Search items..."
                  className="bg-slate-100/50 border border-slate-200 rounded-full pl-10 pr-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 w-64 transition-all"
                />
              </div>

              {user ? (
                <motion.div
                  initial={{ opacity: 0, scale: 0.9 }}
                  animate={{ opacity: 1, scale: 1 }}
                  className="flex items-center gap-3 bg-white pl-1.5 pr-4 py-1.5 rounded-full border border-slate-200 shadow-sm"
                >
                  <div className="bg-emerald-100 p-2 rounded-full">
                    <User size={16} className="text-emerald-700" />
                  </div>
                  <span className="text-sm font-semibold text-slate-700">{user}</span>
                  <button
                    onClick={() => { setUser(null); localStorage.removeItem('token'); toast.success('Logged out'); }}
                    className="ml-2 text-slate-400 hover:text-red-500 transition-colors"
                  >
                    <LogOutIcon size={16} />
                  </button>
                </motion.div>
              ) : (
                <motion.button
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  onClick={() => setShowLogin(true)}
                  className="bg-slate-900 text-white px-5 py-2.5 rounded-full text-sm font-semibold shadow-lg shadow-slate-200 hover:bg-slate-800 transition-all flex items-center gap-2"
                >
                  <LogIn size={16} /> Sign In
                </motion.button>
              )}
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <div className="relative z-10 pt-16 pb-24 lg:pt-32 lg:pb-40">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid lg:grid-cols-2 gap-16 items-center">
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.6 }}
            >
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-50 border border-emerald-100 text-emerald-700 text-xs font-bold uppercase tracking-wide mb-6">
                <Zap size={14} className="fill-emerald-700" /> Live Price Tracking
              </div>
              <h1 className="text-5xl lg:text-7xl font-extrabold text-slate-900 mb-6 leading-[1.1] tracking-tight">
                Stop Overpaying for <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-600 to-teal-500">Groceries.</span>
              </h1>
              <p className="text-xl text-slate-600 mb-8 leading-relaxed max-w-lg">
                We track prices across every local store in real-time so you never miss a deal. Save an average of <span className="font-bold text-slate-900">$200/month</span>.
              </p>
              <div className="flex flex-col sm:flex-row gap-4">
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  className="bg-emerald-600 text-white text-lg px-8 py-4 rounded-2xl font-bold shadow-xl shadow-emerald-200 hover:bg-emerald-700 transition-all flex items-center justify-center gap-2"
                >
                  Browse Deals <ArrowRight size={20} />
                </motion.button>
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  className="bg-white text-slate-700 border border-slate-200 text-lg px-8 py-4 rounded-2xl font-bold hover:bg-slate-50 transition-all shadow-sm flex items-center justify-center gap-2"
                >
                  <Clock size={20} /> Price History
                </motion.button>
              </div>

              <div className="mt-10 flex items-center gap-4 text-sm text-slate-500">
                <div className="flex -space-x-2">
                  {[1,2,3,4].map(i => (
                    <div key={i} className="w-8 h-8 rounded-full bg-slate-200 border-2 border-white flex items-center justify-center text-xs font-bold text-slate-400">
                      {String.fromCharCode(64+i)}
                    </div>
                  ))}
                </div>
                <p>Trusted by 10,000+ shoppers</p>
              </div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, scale: 0.9, rotate: 5 }}
              animate={{ opacity: 1, scale: 1, rotate: 0 }}
              transition={{ duration: 0.8, delay: 0.2 }}
              className="relative hidden lg:block"
            >
              <div className="absolute inset-0 bg-gradient-to-tr from-emerald-500 to-teal-400 rounded-[40px] rotate-6 opacity-20 blur-2xl"></div>
              <div className="relative bg-white rounded-[32px] shadow-2xl border border-slate-100 p-6 rotate-3 hover:rotate-0 transition-transform duration-500">
                <div className="flex justify-between items-center mb-6">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 bg-orange-100 rounded-2xl flex items-center justify-center text-orange-600">
                      <ShoppingCart size={24} />
                    </div>
                    <div>
                      <h4 className="font-bold text-slate-900">Weekly Haul</h4>
                      <p className="text-sm text-slate-500">Saved $42.50 today</p>
                    </div>
                  </div>
                  <span className="bg-emerald-100 text-emerald-700 text-sm font-bold px-3 py-1 rounded-full">-25%</span>
                </div>
                <div className="space-y-4">
                  {[1, 2, 3].map((i) => (
                    <div key={i} className="flex items-center justify-between p-3 bg-slate-50 rounded-xl">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-white rounded-lg shadow-sm"></div>
                        <div className="w-24 h-2 bg-slate-200 rounded-full"></div>
                      </div>
                      <div className="w-12 h-2 bg-emerald-200 rounded-full"></div>
                    </div>
                  ))}
                </div>
              </div>
            </motion.div>
          </div>
        </div>
      </div>

      {/* Deals Section */}
      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-24">
        <div className="flex flex-col md:flex-row justify-between items-end mb-10 gap-4">
          <div>
            <h2 className="text-3xl font-bold text-slate-900">Trending Deals</h2>
            <p className="text-slate-500 mt-2">Fresh drops from stores near you.</p>
          </div>
          <div className="flex gap-2">
            {['All', 'Dairy', 'Produce', 'Bakery'].map((cat) => (
              <button key={cat} className={`px-4 py-2 rounded-full text-sm font-medium transition-all ${cat === 'All' ? 'bg-slate-900 text-white' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}`}>
                {cat}
              </button>
            ))}
          </div>
        </div>

        {loading ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {[1, 2, 3, 4].map((i) => (
              <div key={i} className="bg-white rounded-3xl h-80 animate-pulse border border-slate-100 shadow-sm"></div>
            ))}
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {deals.map((deal, index) => (
              <motion.div
                key={deal.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1 }}
                whileHover={{ y: -5 }}
                className="group bg-white rounded-3xl border border-slate-100 overflow-hidden hover:shadow-xl hover:shadow-slate-200/50 transition-all duration-300"
              >
                <div className="relative h-48 bg-slate-50 p-6 flex items-center justify-center group-hover:bg-emerald-50/30 transition-colors">
                  <div className="absolute top-4 left-4 bg-white/80 backdrop-blur text-slate-900 text-xs font-bold px-2.5 py-1 rounded-lg border border-slate-100 flex items-center gap-1">
                    <Clock size={12} /> 2h ago
                  </div>
                  <div className="absolute top-4 right-4 bg-red-50 text-red-600 text-xs font-bold px-2.5 py-1 rounded-lg border border-red-100">
                    -{deal.drop}
                  </div>
                  <ShoppingCart size={56} className="text-slate-300 group-hover:text-emerald-500/50 group-hover:scale-110 transition-all duration-500" strokeWidth={1.5} />
                </div>

                <div className="p-5">
                  <div className="mb-4">
                    <h3 className="font-bold text-lg text-slate-900 line-clamp-1">{deal.item}</h3>
                    <p className="text-sm text-slate-500 flex items-center gap-1 mt-1">
                      <span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                      {deal.store}
                    </p>
                  </div>

                  <div className="flex items-end justify-between">
                    <div>
                      <p className="text-xs text-slate-400 font-medium line-through mb-0.5">${deal.oldPrice}</p>
                      <p className="text-2xl font-extrabold text-slate-900">${deal.price}</p>
                    </div>
                    <button className="w-10 h-10 rounded-full bg-slate-900 text-white flex items-center justify-center hover:bg-emerald-600 transition-colors shadow-lg shadow-slate-200">
                      <ArrowRight size={18} />
                    </button>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        )}
      </div>

      {/* Features Grid */}
      <div className="bg-white border-t border-slate-100 py-24 relative z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-2xl mx-auto mb-16">
            <h2 className="text-3xl font-bold text-slate-900 mb-4">Why Shoppers Love Us</h2>
            <p className="text-slate-500 text-lg">We don't just show you prices. We give you the data to make smarter decisions.</p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {[
              { icon: <Search size={24} />, title: "Real-Time Scraping", desc: "Our bots check prices daily so you don't have to.", color: "blue" },
              { icon: <ShieldCheck size={24} />, title: "Verified Prices", desc: "We cross-reference data to ensure accuracy.", color: "emerald" },
              { icon: <TrendingDown size={24} />, title: "Price History", desc: "See if a 'sale' is actually a good deal.", color: "purple" }
            ].map((feature, i) => (
              <div key={i} className="p-8 rounded-3xl bg-slate-50 border border-slate-100 hover:bg-white hover:shadow-xl hover:shadow-slate-200/50 transition-all duration-300">
                <div className={`w-12 h-12 rounded-2xl bg-${feature.color}-100 text-${feature.color}-600 flex items-center justify-center mb-6`}>
                  {feature.icon}
                </div>
                <h3 className="text-xl font-bold text-slate-900 mb-3">{feature.title}</h3>
                <p className="text-slate-500 leading-relaxed">{feature.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Login Modal */}
      <AnimatePresence>
        {showLogin && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center z-50 p-4"
          >
            <motion.div
              initial={{ scale: 0.95, opacity: 0, y: 20 }}
              animate={{ scale: 1, opacity: 1, y: 0 }}
              exit={{ scale: 0.95, opacity: 0, y: 20 }}
              className="bg-white rounded-[32px] shadow-2xl w-full max-w-md overflow-hidden relative border border-white/20"
            >
              <button
                onClick={() => setShowLogin(false)}
                className="absolute top-6 right-6 text-slate-400 hover:text-slate-600 p-2 rounded-full hover:bg-slate-50 transition-colors z-10"
              >
                <X size={24} />
              </button>

              <div className="p-10">
                <div className="mb-8">
                  <div className="w-14 h-14 bg-emerald-100 rounded-2xl flex items-center justify-center text-emerald-600 mb-6">
                    {isLoginMode ? <LogIn size={24} /> : <User size={24} />}
                  </div>
                  <h2 className="text-3xl font-bold text-slate-900 mb-2">
                    {isLoginMode ? 'Welcome back' : 'Create account'}
                  </h2>
                  <p className="text-slate-500">
                    {isLoginMode ? 'Please enter your details.' : 'Start your savings journey today.'}
                  </p>
                </div>

                <form onSubmit={handleAuth} className="space-y-4">
                  <div>
                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Username</label>
                    <input
                      type="text"
                      className="w-full px-4 py-3.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 outline-none transition-all font-medium text-slate-900 placeholder-slate-400"
                      placeholder="johndoe"
                      value={authData.username}
                      onChange={(e) => setAuthData({...authData, username: e.target.value})}
                      required
                    />
                  </div>

                  {!isLoginMode && (
                    <motion.div initial={{ height: 0, opacity: 0 }} animate={{ height: 'auto', opacity: 1 }}>
                      <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Email</label>
                      <input
                        type="email"
                        className="w-full px-4 py-3.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 outline-none transition-all font-medium text-slate-900 placeholder-slate-400"
                        placeholder="john@example.com"
                        value={authData.email}
                        onChange={(e) => setAuthData({...authData, email: e.target.value})}
                        required
                      />
                    </motion.div>
                  )}

                  <div>
                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Password</label>
                    <input
                      type="password"
                      className="w-full px-4 py-3.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 outline-none transition-all font-medium text-slate-900 placeholder-slate-400"
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
                    className="w-full bg-slate-900 text-white py-4 rounded-xl font-bold text-lg shadow-lg shadow-slate-200 hover:bg-emerald-600 hover:shadow-emerald-200 transition-all mt-2"
                  >
                    {isLoginMode ? 'Sign In' : 'Sign Up'}
                  </motion.button>
                </form>

                <div className="mt-8 text-center">
                  <p className="text-slate-500 font-medium text-sm">
                    {isLoginMode ? "New here? " : "Already have an account? "}
                    <button
                      onClick={() => { setIsLoginMode(!isLoginMode); }}
                      className="text-emerald-600 font-bold hover:underline ml-1"
                    >
                      {isLoginMode ? 'Create account' : 'Log in'}
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