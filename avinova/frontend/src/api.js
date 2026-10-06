const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:4000/api'

export async function api(path, options = {}) {
  const token = localStorage.getItem('avinova_token')
  const headers = { 'Content-Type': 'application/json', ...(options.headers || {}) }
  if (token) headers.Authorization = `Bearer ${token}`
  const response = await fetch(`${API_URL}${path}`, { ...options, headers })
  const data = await response.json().catch(() => ({}))
  if (!response.ok) throw new Error(data.message || 'No fue posible completar la solicitud.')
  return data
}

export function saveSession(data) { localStorage.setItem('avinova_token', data.token); localStorage.setItem('avinova_user', JSON.stringify(data.user)) }
export function clearSession() { localStorage.removeItem('avinova_token'); localStorage.removeItem('avinova_user') }
export function getUser() { try { return JSON.parse(localStorage.getItem('avinova_user') || 'null') } catch { return null } }
