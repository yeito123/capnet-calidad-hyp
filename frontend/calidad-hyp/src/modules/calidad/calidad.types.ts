export interface CalidadResponse {
  id: number;
  id_chip?: number | null;
  id_hd?: number | null;
  fecha?: string | null; // datetime → string ISO
  color: string | null;
  status?: string | null;
  vehiculo?: string | null;
  no_orden?: string | null;
  no_placas?: string | null;
  id_tecnico?: number | null;
  id_asesor?: number | null;
  fecha_hora_ini_oper?: string | null;
  fecha_hora_fin_oper?: string | null;
  status_os?: string | null;
  kilometraje?: number | null;
  contacto_nombre?: string | null;
  contacto_telefono?: string | null;
  tmp_real?: number | null;
  tmp_original?: number | null;
  servicio?: string | null;
  servicio_capturado?: string | null;
  id_fase?: number | null;
  tecnico: string | null;
  asesor: string | null;
}

export interface ComentarioResponse {
  id_chip: number;
  fecha: string; // datetime
  status: string;
  cve_usuario: string;
  id_linea: number;
  comentario: string;
}

export interface CrearComentarioRequest {
  id_chip: number;
  status: string;
  cve_usuario: string;
  comentario: string;
}

export interface UsuarioRequest {
  usuario: string;
}

export interface CalidadListResponse {
  items: CalidadResponse[];
  total: number;
}
