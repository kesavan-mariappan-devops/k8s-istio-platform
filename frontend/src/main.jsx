// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Kesavan Mariappan (kesavan-mariappan-devops)
// https://github.com/kesavan-mariappan-devops/k8s-istio-platform

import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
