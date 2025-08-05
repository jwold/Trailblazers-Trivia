/**
 * Environment detection utilities
 */

export const isLocalhost = (): boolean => {
  if (typeof window === 'undefined') return false;
  
  const hostname = window.location.hostname;
  return hostname === 'localhost' || 
         hostname === '127.0.0.1' || 
         hostname === '0.0.0.0' ||
         hostname.startsWith('192.168.') || // Local network
         hostname.endsWith('.local'); // Local development domains
};

export const isProduction = (): boolean => {
  return !isLocalhost();
};

export const isDevelopment = (): boolean => {
  return isLocalhost();
};