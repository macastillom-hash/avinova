# AVINOVA — React + Node.js + Express + PostgreSQL

Versión corregida del proyecto original. Se mantiene la interfaz y los recursos visuales, pero se separa la aplicación en frontend React y backend Node.js/Express.

## Arquitectura
React + Vite → HTTP/JSON → Node.js + Express → PostgreSQL (Render)

## 1. Base de datos Render
1. En Render abre PostgreSQL → Connect.
2. Copia **External Database URL** para una aplicación que corre fuera de Render.
3. Ejecuta `database/schema.sql` en la base de datos.
4. Configura `backend/.env` usando esa URL.
5. Ejecuta `npm run seed` una sola vez.

## 2. Backend
```bash
cd backend
npm install
copy .env.example .env
npm run seed
npm run dev
```
Health: `http://localhost:4000/api/health`

## 3. Frontend
```bash
cd frontend
npm install
copy .env.example .env
npm run dev
```
Frontend: `http://localhost:5173`

## Credenciales de prueba
- Admin: `admin@avinova.com` / `CambiaEstaClave123!`
- Cliente: `cliente@avinova.com` / `Cliente123!`

Cambiar estas claves antes de producción.

## Flujo real implementado
Registro → Login/JWT → Disponibilidad PostgreSQL → Reserva transaccional → Entrega → Auditoría → Dashboard.

El backend bloquea la fila de disponibilidad durante la reserva (`FOR UPDATE`) para evitar sobreventas concurrentes.
