import React from 'react';
import { createRoot } from 'react-dom/client';
import { AppProvider } from './utils/provider';
import App from './App'; // Uppercase 'App'

const root = createRoot(document.getElementById('root')!);
root.render(
  <AppProvider>
    <App />
  </AppProvider>
);
