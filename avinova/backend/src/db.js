import pg from 'pg';import dotenv from 'dotenv';dotenv.config();
const {Pool}=pg;
if(!process.env.DATABASE_URL) console.warn('DATABASE_URL no está configurada.');
export const pool=new Pool({connectionString:process.env.DATABASE_URL,ssl:process.env.NODE_ENV==='production'?{rejectUnauthorized:false}:false,max:10});
export async function query(text,params){return pool.query(text,params)}
