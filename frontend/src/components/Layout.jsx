import { useState } from 'react'
import { Link, useLocation } from 'react-router-dom'

export function Header(){
  const [open,setOpen]=useState(false); const location=useLocation(); const authPage=['/login','/registro'].includes(location.pathname)
  return <header className="site-header">
    <Link className="brand" to="/" aria-label="Avinova inicio"><img src="/assets/img/logo/logo-avinova.png" alt="Avinova"/></Link>
    <button className="menu-toggle" aria-label={open?'Cerrar menú':'Abrir menú'} onClick={()=>setOpen(!open)}>{open?'×':'☰'}</button>
    <nav className={open?'nav open':'nav'}><Link to="/" onClick={()=>setOpen(false)}>Inicio</Link><Link to="/conocenos" onClick={()=>setOpen(false)}>Conócenos</Link>{!authPage&&<Link to="/reserva" onClick={()=>setOpen(false)}>Reserva</Link>}<Link to="/#contacto" onClick={()=>setOpen(false)}>Contacto</Link></nav>
    {!authPage && <Link className="button button-small" to="/login">Iniciar sesión</Link>}
  </header>
}
export function Footer(){return <footer><div className="footer-brand"><Link className="brand" to="/"><img src="/assets/img/logo/logo-avinova.png" alt="Avinova"/></Link></div><nav className="footer-nav"><Link to="/">Inicio</Link><Link to="/#nosotros">Conócenos</Link><Link to="/#servicios">Servicios</Link><Link to="/reserva">Reserva</Link><Link to="/#contacto">Contacto</Link></nav><div className="footer-contact"><span>(57) 320 513 5667</span><span>avinova@correo.com</span><span>Ibagué, Tolima, Colombia</span></div><div className="socials"><a href="https://facebook.com" target="_blank" rel="noreferrer"><img src="/assets/img/social/facebook.png" alt="Facebook"/></a><a href="https://wa.me/573205135667" target="_blank" rel="noreferrer"><img src="/assets/img/social/whatsapp.png" alt="WhatsApp"/></a><a href="https://instagram.com" target="_blank" rel="noreferrer"><img src="/assets/img/social/instagram.png" alt="Instagram"/></a></div><div className="footer-bottom">© 2026 Avinova. Todos los derechos reservados.</div></footer>}
export function Layout({children}){return <><Header/>{children}<Footer/></>}
