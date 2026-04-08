const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 5000;
const startTime = Date.now();

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    uptime: Math.floor((Date.now() - startTime) / 1000),
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
  });
});

// Slow endpoint — simulates a delayed response for Istio timeout testing
app.get('/api/slow', (req, res) => {
  setTimeout(() => res.json({ message: 'slow response' }), 5000); // 5s delay > 3s timeout
});

// Sample API endpoint
app.get('/api/info', (req, res) => {
  res.json({
    app: 'k8s-istio-platform',
    version: '1.0.0',
    description: 'Istio Platform API - v1',
  });
});

app.listen(PORT, () => console.log(`Backend running on port ${PORT}`));
