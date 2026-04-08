const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 5000;
const startTime = Date.now();

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    uptime: Math.floor((Date.now() - startTime) / 1000),
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    version: '2.0.0',
  });
});

app.get('/api/slow', (req, res) => {
  setTimeout(() => res.json({ message: 'slow response', version: '2.0.0' }), 5000);
});

app.get('/api/info', (req, res) => {
  res.json({
    app: 'k8s-istio-platform',
    version: '2.0.0',
    description: 'Istio Platform API - v2',
  });
});

app.listen(PORT, () => console.log(`Backend v2 running on port ${PORT}`));
