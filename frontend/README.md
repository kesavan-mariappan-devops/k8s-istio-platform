# mesh-ui — Frontend

React + Vite SPA that displays the health and metadata of the `mesh-api` backend. Served via Nginx inside a Docker container.

## Stack

- React 19 + Vite
- Nginx (production container)
- ESLint with `eslint-plugin-react-hooks` and `eslint-plugin-react-refresh`

## Development

```bash
npm install
npm run dev       # http://localhost:5173
```

## Build

```bash
npm run build     # outputs to dist/
npm run preview   # preview production build locally
```

## Lint

```bash
npm run lint
```

ESLint is also enforced via pre-commit hook (`frontend-lint`) on every `git commit` and on every PR.

## Docker

```bash
docker build -t k8s-istio-platform-frontend:latest .
docker run -p 3000:80 k8s-istio-platform-frontend:latest
```

## Nginx proxy

In production the Nginx config (`nginx.conf`) proxies `/api` and `/health` to the `mesh-api` backend service, so the frontend and backend share the same origin.

## Environment

| Variable | Default | Description |
|---|---|---|
| `NODE_ENV` | `production` | Set by Docker build |
