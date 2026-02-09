import React, { useState, useEffect } from 'react';
import { ShoppingCart, Search, TrendingDown, Clock, X, LogIn, User as UserIcon } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { Toaster, toast } from 'react-hot-toast';
import './App.css';

const App = () => {
  const [deals, setDeals] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showLogin, setShowLogin] = useState(false);
  const [isLoginMode, setIsLoginMode] = useState(true);
  const [authData, setAuthData] = useState({ username: '', password: '', email: '' });
  const [user, setUser] = useState(null);

  useEffect(() => {
    // The frontend will call /api/deals
    fetch('/api/deals')
      .then(res => res.json())
      .then(data => {
        setDeals(data);
        setLoading(false);
      })
      .catch(err => {
        console.error("Failed to fetch deals:", err);
        setLoading(false);
        toast.error("Could not load deals.");
      });
  }, []);

  const handleAuth = async (e) => {
    e.preventDefault();
    // The frontend will call /api/auth/login or /api/auth/signup
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
    <div className="app-container">
      <Toaster position="top-center" />

      <header className="navbar">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex justify-between items-center h-20">
          <div className="navbar-logo">
            <div className="icon-wrapper">
              <ShoppingCart size={24} className="text-white" />
            </div>
            <h1>Grocer<span>Save</span></h1>
          </div>
          <div className="hidden md:flex items-center gap-8">
            <a href="#" className="nav-link">Deals</a>
            <a href="#" className="nav-link">Stores</a>
            <a href="#" className="nav-link">About</a>
          </div>
          <div className="flex items-center gap-4">
            {user ? (
              <div className="flex items-center gap-2 font-semibold">
                <UserIcon size={18} /> {user}
              </div>
            ) : (
              <button onClick={() => setShowLogin(true)} className="btn btn-primary">
                <LogIn size={16} /> Sign In
              </button>
            )}
          </div>
        </div>
      </header>

      <main className="main-content">
        <section className="hero-section">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
          >
            <h1>Save Big on <span className="highlight">Every</span> Grocery Trip.</h1>
            <p>We track prices across local stores in real-time so you never miss a deal. Start saving today!</p>
            <div className="flex justify-center gap-4">
              <button className="btn btn-accent"><Search size={16} /> Find Deals</button>
              <button className="btn btn-primary">Learn More</button>
            </div>
          </motion.div>
        </section>

        <section className="deals-section">
          <div className="section-header">
            <h2>Today's Top Drops</h2>
            <p>The best deals we've found in your area in the last 24 hours.</p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
            {loading ? (
              [1,2,3,4].map(i => <div key={i} className="deal-card h-80 animate-pulse"></div>)
            ) : (
              deals.map((deal, index) => (
                <motion.div
                  key={deal.id}
                  className="deal-card"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1 }}
                >
                  <div className="deal-card-image">
                    <div className="deal-card-drop">-{deal.drop}</div>
                    <ShoppingCart size={48} />
                  </div>
                  <div className="deal-card-content">
                    <h4>{deal.item}</h4>
                    <div className="deal-card-store">
                      <Clock size={14} /> {deal.store}
                    </div>
                    <div className="price-container">
                      <span className="current-price">${deal.price}</span>
                      <span className="old-price">${deal.oldPrice}</span>
                    </div>
                  </div>
                </motion.div>
              ))
            )}
          </div>
        </section>
      </main>

      <AnimatePresence>
        {showLogin && (
          <motion.div
            className="modal-overlay"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          >
            <motion.div
              className="modal-content"
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
            >
              <button onClick={() => setShowLogin(false)} className="modal-close-btn"><X size={24} /></button>
              <h2>{isLoginMode ? 'Welcome Back' : 'Create Account'}</h2>
              <form onSubmit={handleAuth}>
                <div className="input-group">
                  <label>Username</label>
                  <input type="text" className="input-field" value={authData.username} onChange={(e) => setAuthData({...authData, username: e.target.value})} required />
                </div>
                {!isLoginMode && (
                  <div className="input-group">
                    <label>Email</label>
                    <input type="email" className="input-field" value={authData.email} onChange={(e) => setAuthData({...authData, email: e.target.value})} required />
                  </div>
                )}
                <div className="input-group">
                  <label>Password</label>
                  <input type="password" className="input-field" value={authData.password} onChange={(e) => setAuthData({...authData, password: e.target.value})} required />
                </div>
                <button type="submit" className="btn btn-accent w-full justify-center mt-4">
                  {isLoginMode ? 'Sign In' : 'Sign Up'}
                </button>
              </form>
              <p className="text-center text-sm mt-6">
                {isLoginMode ? "Don't have an account? " : "Already have an account? "}
                <button onClick={() => setIsLoginMode(!isLoginMode)} className="font-semibold text-emerald-600 hover:underline">
                  {isLoginMode ? 'Sign Up' : 'Log In'}
                </button>
              </p>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

export default App;