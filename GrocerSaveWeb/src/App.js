import React, { useState, useEffect } from 'react';
import { ShoppingCart, Search, TrendingDown, Clock, Menu } from 'lucide-react';

const App = () => {
  const [deals, setDeals] = useState([]);
  const [loading, setLoading] = useState(true);

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
        // Fallback mock data for dev/demo if backend is unreachable
        const mockDeals = [
          { id: 1, item: "Organic Milk 2L", store: "SuperStore", price: 4.99, oldPrice: 6.50, drop: "23%" },
          { id: 2, item: "Free Range Eggs (12)", store: "FreshMart", price: 3.49, oldPrice: 5.00, drop: "30%" },
          { id: 3, item: "Avocados (Bag of 5)", store: "VeggieCity", price: 2.99, oldPrice: 4.99, drop: "40%" },
          { id: 4, item: "Sourdough Bread", store: "BakeryBarn", price: 3.25, oldPrice: 4.50, drop: "27%" },
        ];
        setDeals(mockDeals);
        setLoading(false);
      });
  }, []);

  return (
    <div className="min-h-screen bg-gray-50 font-sans text-gray-800">
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
          <Menu className="md:hidden cursor-pointer" />
        </div>
      </header>

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