import { api } from "@/core/http/client";
import {
  CalidadResponse,
  ComentarioResponse,
  CrearComentarioRequest,
  UsuarioRequest,
} from "./calidad.types";

// Base prefix de este módulo
const BASE = "/calidad";

// ======================================================================
// 0. Auth (simple verification)
// ======================================================================
export async function calidadAuthMe() {
  const { data } = await api.get(`${BASE}/auth/me/`);
  return data;
}

// ======================================================================
// 1. Listar vehículos en fase de calidad
// GET /calidad/
// ======================================================================
export async function listarCalidad(): Promise<CalidadResponse[]> {
  const { data } = await api.get(`${BASE}/`);
  return data;
}

// ======================================================================
// 2. Obtener vehículo por idHD
// GET /calidad/vehiculo/{id_hd}/
// ======================================================================
export async function obtenerPorIdHd(id_hd: number): Promise<CalidadResponse> {
  const { data } = await api.get(`${BASE}/vehiculo/${id_hd}/`);
  return data;
}

// ======================================================================
// 3. Obtener calidad por ID (PK)
// GET /calidad/item/{id}/
// ======================================================================
export async function obtenerPorId(id: number): Promise<CalidadResponse> {
  const { data } = await api.get(`${BASE}/item/${id}/`);
  return data;
}

// ======================================================================
// 4. Obtener información previa
// GET /calidad/vehiculo-previo/{id_hd}/
// ======================================================================
export async function obtenerVehiculoPrevio(
  id_hd: number
): Promise<CalidadResponse> {
  const { data } = await api.get(`${BASE}/vehiculo-previo/${id_hd}/`);
  return data;
}

// ======================================================================
// 5. Historial de comentarios
// GET /calidad/comentarios/{id_chip}/
// ======================================================================
export async function obtenerComentarios(
  id_chip: number
): Promise<ComentarioResponse[]> {
  const { data } = await api.get(`${BASE}/comentarios/${id_chip}/`);
  return data;
}

// ======================================================================
// 6. Agregar comentario
// POST /calidad/comentarios/
// ======================================================================
export async function agregarComentario(
  payload: CrearComentarioRequest
): Promise<ComentarioResponse> {
  const { data } = await api.post(`${BASE}/comentarios/`, payload);
  return data;
}

// ======================================================================
// 7. Iniciar calidad
// POST /calidad/{id}/iniciar/
// ======================================================================
export async function iniciarCalidad(
  id: number,
  body: UsuarioRequest
): Promise<boolean> {
  const { data } = await api.post(`${BASE}/${id}/iniciar/`, body);
  return data.status === "INICIADA";
}

// ======================================================================
// 8. Finalizar calidad
// POST /calidad/{id}/finalizar/
// ======================================================================
export async function finalizarCalidad(
  id: number,
  body: UsuarioRequest
): Promise<boolean> {
  const { data } = await api.post(`${BASE}/${id}/finalizar/`, body);
  return data.status === "TERMINADO";
}
