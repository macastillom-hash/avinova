import express from 'express';import cors from 'cors';import dotenv from 'dotenv';import {query} from './db.js';import authRoutes from './routes/auth.js';import availabilityRoutes from './routes/availability.js';import reservationRoutes from './routes/reservations.js';import adminRoutes from './routes/admin.js';dotenv.config();
const app=express();app.use(cors({origin:process.env.FRONTEND_URL?.split(',').map(x=>x.trim())||'http://localhost:5173'}));app.use(express.json({limit:'1mb'}));
app.get('/api/health',async(req,res)=>{try{await query('SELECT 1');res.json({ok:true,service:'avinova-api',database:'connected'})}catch(e){res.status(503).json({ok:false,service:'avinova-api',database:'disconnected'})}});
app.use('/api/auth',authRoutes);app.use('/api/availability',availabilityRoutes);app.use('/api/reservations',reservationRoutes);app.use('/api/admin',adminRoutes);
app.use((err,req,res,next)=>{console.error(err);res.status(500).json({message:'Error interno del servidor.'})});
const port=Number(process.env.PORT||4000);app.listen(port,()=>console.log(`Avinova API ejecutándose en http://localhost:${port}`));
