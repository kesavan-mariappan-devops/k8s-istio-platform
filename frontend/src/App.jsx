import { useEffect, useState } from 'react';
import './App.css';

const POLL_INTERVAL = 15000;

function StatusBadge({ status }) {
  const color = status === 'ok' ? '#22c55e' : status === 'loading' ? '#f59e0b' : '#ef4444';
  const label = status === 'ok' ? 'Healthy' : status === 'loading' ? 'Checking...' : 'Unreachable';
  return (
    <span style={{ background: color, color: '#fff', padding: '2px 12px', borderRadius: 12, fontWeight: 600 }}>
      {label}
    </span>
  );
}

export default function App() {
  const [health, setHealth] = useState(null);
  const [info, setInfo] = useState(null);
  const [status, setStatus] = useState('loading');
  const [lastChecked, setLastChecked] = useState(null);

  useEffect(() => {
    let cancelled = false;

    async function fetchHealth() {
      setStatus('loading');
      try {
        const [healthRes, infoRes] = await Promise.all([
          fetch('/health'),
          fetch('/api/info'),
        ]);
        if (cancelled) return;
        setHealth(await healthRes.json());
        setInfo(await infoRes.json());
        setStatus('ok');
      } catch {
        if (cancelled) return;
        setStatus('error');
        setHealth(null);
        setInfo(null);
      }
      if (!cancelled) setLastChecked(new Date().toLocaleTimeString());
    }

    fetchHealth();
    const interval = setInterval(fetchHealth, POLL_INTERVAL);
    return () => {
      cancelled = true;
      clearInterval(interval);
    };
  }, []);

  function handleRefresh() {
    setStatus('loading');
    fetch('/health')
      .then(r => r.json())
      .then(data => { setHealth(data); setStatus('ok'); setLastChecked(new Date().toLocaleTimeString()); })
      .catch(() => { setStatus('error'); setHealth(null); });
    fetch('/api/info')
      .then(r => r.json())
      .then(data => setInfo(data))
      .catch(() => setInfo(null));
  }

  return (
    <div className="container">
      <h1>DevOps Portfolio — k8s-istio-platform</h1>

      <section className="card">
        <div className="card-header">
          <h2>Backend Health</h2>
          <StatusBadge status={status} />
        </div>
        {health ? (
          <ul>
            <li><b>Uptime:</b> {health.uptime}s</li>
            <li><b>Environment:</b> {health.environment}</li>
            <li><b>Timestamp:</b> {health.timestamp}</li>
          </ul>
        ) : (
          <p className="error">Backend not reachable</p>
        )}
        <small>Last checked: {lastChecked}</small>
      </section>

      {info && (
        <section className="card">
          <h2>App Info</h2>
          <ul>
            <li><b>Name:</b> {info.app}</li>
            <li><b>Version:</b> {info.version}</li>
            <li><b>Description:</b> {info.description}</li>
          </ul>
        </section>
      )}

      <button onClick={handleRefresh}>Refresh</button>
    </div>
  );
}
