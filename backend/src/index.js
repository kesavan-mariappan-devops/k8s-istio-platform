import express from 'express';
import cors from 'cors';

const startTime = Date.now();

export function createServer() {
  const app = express();
  app.use(cors());
  app.use(express.json());

  app.get('/health', (req, res) => {
    res.json({
      status: 'ok',
      uptime: Math.floor((Date.now() - startTime) / 1000),
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'development',
    });
  });

  app.get('/api/slow', (req, res) => {
    setTimeout(() => res.json({ message: 'slow response' }), 5000);
  });

  app.get('/api/info', (req, res) => {
    res.json({
      app: 'k8s-istio-platform',
      version: '1.0.0',
      description: 'Istio Platform API - v1',
    });
  });

  return new Promise((resolve) => {
    const server = app.listen(0, () => resolve(server));
  });
}

if (process.argv[1] === new URL(import.meta.url).pathname) {
  const PORT = process.env.PORT || 5000;
  const app = express();
  app.use(cors());
  app.use(express.json());

  app.get('/health', (req, res) => {
    res.json({
      status: 'ok',
      uptime: Math.floor((Date.now() - startTime) / 1000),
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'development',
    });
  });

  app.get('/api/slow', (req, res) => {
    setTimeout(() => res.json({ message: 'slow response' }), 5000);
  });

  app.get('/api/info', (req, res) => {
    res.json({
      app: 'k8s-istio-platform',
      version: '1.0.0',
      description: 'Istio Platform API - v1',
    });
  });

  app.listen(PORT, () => console.log(`Backend running on port ${PORT}`));
}
