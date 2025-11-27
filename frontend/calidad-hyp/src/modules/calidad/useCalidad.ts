import { useCalidadStore } from "./calidad.store";

export function useCalidad() {
  // === STATE ===
  const items = useCalidadStore((s) => s.items);
  const item = useCalidadStore((s) => s.item);
  const previo = useCalidadStore((s) => s.previo);
  const comentarios = useCalidadStore((s) => s.comentarios);
  const loading = useCalidadStore((s) => s.loading);

  // === ACTIONS ===
  const cargar = useCalidadStore((s) => s.cargar);
  const cargarItem = useCalidadStore((s) => s.cargarItem);
  const cargarPorIdHd = useCalidadStore((s) => s.cargarPorIdHd);
  const cargarPrevio = useCalidadStore((s) => s.cargarPrevio);
  const cargarComentarios = useCalidadStore((s) => s.cargarComentarios);

  const crearComentario = useCalidadStore((s) => s.crearComentario);

  const iniciar = useCalidadStore((s) => s.iniciar);
  const finalizar = useCalidadStore((s) => s.finalizar);

  return {
    // === DATA ===
    items,
    item,
    previo,
    comentarios,
    loading,

    // === ACTIONS ===
    cargar,
    cargarItem,
    cargarPorIdHd,
    cargarPrevio,
    cargarComentarios,
    crearComentario,
    iniciar,
    finalizar,
  };
}
