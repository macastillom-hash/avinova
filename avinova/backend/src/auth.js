import jwt from 'jsonwebtoken';import bcrypt from 'bcryptjs';
const secret=()=>{if(!process.env.JWT_SECRET) throw new Error('JWT_SECRET no está configurada.');return process.env.JWT_SECRET}
export async function hashPassword(password){return bcrypt.hash(password,12)}
export async function comparePassword(password,hash){return bcrypt.compare(password,hash)}
export function signToken(user){return jwt.sign({sub:user.id,rol:user.rol},secret(),{expiresIn:'7d'})}
export function verifyToken(token){return jwt.verify(token,secret())}
