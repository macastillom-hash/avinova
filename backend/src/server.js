
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

import { query } from './db.js';
import authRoutes from './routes/auth.js';
import availabilityRoutes from './routes/availability.js';
import reservationRoutes from './routes/reservations.js';
import adminRoutes from './routes/admin.js';

// Cargar variables de entorno
dotenv.config();

// Crear aplicación Express
const app = express();

// Configurar acceso desde el frontend
const frontendOrigins = process.env.FRONTEND_URL
  ?.split(',')
  .map(origin => origin.trim()) || ['http://localhost:5173'];

app.use(cors({ origin: frontendOrigins }));

// Permitir recibir información JSON
app.use(express.json({ limit: '1mb' }));

// Ruta para comprobar la API y PostgreSQL
app.get('/api/health', async (req, res) => {
  try {
    await query('SELECT 1');

    res.json({
      ok: true,
      service: 'avinova-api',
      database: 'connected'
    });
  } catch (error) {
    console.error('Error de conexión PostgreSQL:', error.message);

    res.status(503).json({
      ok: false,
      service: 'avinova-api',
      database: 'disconnected'
    });
  }
});

// Rutas del sistema AVINOVA
app.use('/api/auth', authRoutes);
app.use('/api/availability', availabilityRoutes);
app.use('/api/reservations', reservationRoutes);
app.use('/api/admin', adminRoutes);

// Manejo general de errores
app.use((err, req, res, next) => {
  console.error('Error interno:', err);

  res.status(500).json({
    message: 'Error interno del servidor.'
  });
});

// Puerto proporcionado por Render
const port = Number(process.env.PORT || 4000);

// Dirección para aceptar conexiones externas
const host = '0.0.0.0';

// Iniciar servidor
app.listen(port, host, () => {
  console.log('Servidor AVINOVA iniciado correctamente');
  console.log(`Puerto: ${port}`);
  console.log(`Escuchando en: ${host}:${port}`);
});

