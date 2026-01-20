import { create } from "zustand";

import {
  CalidadResponse,
  ComentarioResponse,
  CrearComentarioRequest,
  UsuarioRequest,
} from "./calidad.types";

import {
  listarCalidad,
  obtenerPorId,
  obtenerPorIdHd,
  obtenerVehiculoPrevio,
  obtenerComentarios,
  agregarComentario,
  iniciarCalidad,
  finalizarCalidad,
} from "./calidad.api";

import { useAlert } from "@/core/alerts/useAlerts";

interface CalidadState {
  // === DATA ===
  items: CalidadResponse[];
  item: CalidadResponse | null;
  previo: CalidadResponse | null;
  comentarios: ComentarioResponse[];

  // === UI ===
  loading: boolean;

  // === ACTIONS ===
  cargar: () => Promise<void>;
  cargarItem: (id: number) => Promise<void>;
  cargarPorIdHd: (id_hd: number) => Promise<void>;
  cargarPrevio: (id_hd: number) => Promise<void>;
  cargarComentarios: (id_chip: number) => Promise<void>;

  crearComentario: (payload: CrearComentarioRequest) => Promise<void>;

  iniciar: (id: number, usuario: string) => Promise<boolean>;
  finalizar: (
    id: number,
    usuario: string,
    status_os: string,
  ) => Promise<boolean>;
}

export const useCalidadStore = create<CalidadState>((set, get) => ({
  // ============================================================
  // STATE
  // ============================================================
  items: [],
  item: null,
  previo: null,
  comentarios: [],
  loading: false,
  // ============================================================
  // 1. Listar vehículos en calidad
  // ============================================================
  cargar: async () => {
    set({ loading: true });
    try {
      const data = await listarCalidad();

      set({ items: data, loading: false });
    } catch (e) {
      set({ loading: false });
      throw e;
    }
  },

  // ============================================================
  // 2. Obtener por ID PK
  // ============================================================
  cargarItem: async (id) => {
    set({ loading: true });
    try {
      const data = await obtenerPorId(id);
      set({ item: data, loading: false });
    } catch (e) {
      set({ loading: false });
      throw e;
    }
  },

  // ============================================================
  // 3. Obtener por ID HD (dentro de la fase)
  // ============================================================
  cargarPorIdHd: async (id_hd) => {
    set({ loading: true });
    try {
      const data = await obtenerPorIdHd(id_hd);
      set({ item: data, loading: false });
    } catch (e) {
      set({ loading: false });
      throw e;
    }
  },

  // ============================================================
  // 4. Info previa
  // ============================================================
  cargarPrevio: async (id_hd) => {
    set({ loading: true });
    try {
      const data = await obtenerVehiculoPrevio(id_hd);
      set({ previo: data, loading: false });
    } catch (e) {
      set({ loading: false });
      throw e;
    }
  },

  // ============================================================
  // 5. Comentarios
  // ============================================================
  cargarComentarios: async (id_chip) => {
    set({ loading: true });
    try {
      const data = await obtenerComentarios(id_chip);
      set({ comentarios: data, loading: false });
    } catch (e) {
      set({ loading: false });
      throw e;
    }
  },

  // ============================================================
  // 6. Crear comentario
  // ============================================================
  crearComentario: async (payload) => {
    set({ loading: true });
    try {
      await agregarComentario(payload);
      // refrescar lista
      await get().cargarComentarios(payload.id_chip);
      set({ loading: false });
    } catch (e) {
      set({ loading: false });
      throw e;
    }
  },

  // ============================================================
  // 7. Iniciar calidad
  // ============================================================
  iniciar: async (id, usuario): Promise<boolean> => {
    set({ loading: true });
    try {
      const body: UsuarioRequest = { usuario, status_os: null };
      const data = await iniciarCalidad(id, body);
      set({ loading: false });
      return data;
    } catch (e) {
      set({ loading: false });
      throw e;
    }
  },

  // ============================================================
  // 8. Finalizar calidad
  // ============================================================
  finalizar: async (id, usuario, status_os): Promise<boolean> => {
    set({ loading: true });
    try {
      const body: UsuarioRequest = { usuario, status_os };
      const data = await finalizarCalidad(id, body);
      set({ loading: false });
      return data;
    } catch (e) {
      set({ loading: false });
      throw e;
    }
  },
}));
