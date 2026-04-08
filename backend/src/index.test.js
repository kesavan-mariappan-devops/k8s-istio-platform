// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Kesavan Mariappan (kesavan-mariappan-devops)
// https://github.com/kesavan-mariappan-devops/k8s-istio-platform

import { describe, it, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { createServer } from './index.js';

describe('mesh-api', () => {
  let server;
  let baseUrl;

  before(async () => {
    server = await createServer();
    const { port } = server.address();
    baseUrl = `http://localhost:${port}`;
  });

  after(() => server.close());

  it('GET /health returns status ok', async () => {
    const res = await fetch(`${baseUrl}/health`);
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.equal(body.status, 'ok');
    assert.ok(typeof body.uptime === 'number');
    assert.ok(typeof body.timestamp === 'string');
  });

  it('GET /api/info returns app metadata', async () => {
    const res = await fetch(`${baseUrl}/api/info`);
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.equal(body.app, 'k8s-istio-platform');
    assert.equal(body.version, '1.0.0');
    assert.ok(typeof body.description === 'string');
  });
});
