import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5174,
    proxy: {
      // Used only during local development (npm run dev)
      // In production, React is served from Spring Boot on port 9090
      '/api': {
        target: 'http://localhost:9090',
        changeOrigin: true,
      },
      '/admin': {
        target: 'http://localhost:9090',
        changeOrigin: true,
      },
    },
  },
  build: {
    outDir: 'dist',
  },
});
