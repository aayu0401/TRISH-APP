import React from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'

console.log("TRISH_PRODUCTION: BOOTING ENGINE");

const rootElement = document.getElementById('root');
if (rootElement) {
  createRoot(rootElement).render(<App />);
} else {
  console.error("FATAL: ROOT ELEMENT MISSING");
}
