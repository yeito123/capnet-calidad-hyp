"use client";

import { useEffect, useState, useMemo } from "react";
import { useCalidad } from "@/modules/calidad/useCalidad";

import { CalidadList } from "@/modules/calidad/components/CalidadList";
import { CalidadComments } from "@/modules/calidad/components/CalidadComments";
import { Modal } from "@/modules/calidad/components/Modal";
import { NavBar } from "@/modules/calidad/components/NavBar";
import { useAlert } from "@/core/alerts/useAlerts";

export default function Home() {
  const {
    items,
    item,
    cargar,
    loading,
    iniciar,
    finalizar,
    crearComentario,
    cargarComentarios,
    comentarios,
  } = useCalidad();

  const [filtroStatus, setFiltroStatus] = useState("Pendiente");
  const [filtroStatusOs, setFiltroStatusOs] = useState("");
  const [filtroPlacas, setFiltroPlacas] = useState("");
  const [filtroOrden, setFiltroOrden] = useState("");

  const [openModal, setOpenModal] = useState(false);
  const [comentario, setComentario] = useState("");
  const [comentarioChip, setComentarioChip] = useState<number | null>(null);

  const alert = useAlert();

  useEffect(() => {
    cargar();
  }, []);

  const abrirComentarios = (chipId: number | null | undefined) => {
    if (!chipId) return;
    setComentarioChip(chipId);
    cargarComentarios(chipId);
    setOpenModal(true);
  };

  const iniciarCalidad = async (id: number) => {
    const alertResult = await alert.confirm(
      "¿Estás seguro de iniciar el proceso de calidad?",
    );
    if (!alertResult) return;
    let result = await iniciar(id, "admin");
    if (result) {
      alert.info("El proceso de calidad ya ha sido iniciado.", "Información");
    } else {
      alert.error("No se pudo iniciar el proceso de calidad.", "Error");
    }
    await cargar();
  };

  const aprobarCalidad = async (id: number) => {
    const alertResult = await alert.confirm(
      "¿Estás seguro de aprobar el proceso de calidad?",
    );
    if (!alertResult) return;
    let result = await finalizar(id, "admin", "Aprobado");
    if (result) {
      alert.info("El proceso de calidad ha sido aprobado.", "Información");
    } else {
      alert.error("No se pudo aprobar el proceso de calidad.", "Error");
    }
    await cargar();
  };

  const rechazarCalidad = async (id: number) => {
    const alertResult = await alert.confirm(
      "¿Estás seguro de rechazar el proceso de calidad?",
    );
    if (!alertResult) return;
    let result = await finalizar(id, "admin", "Rechazado");
    if (result) {
      alert.info("El proceso de calidad ha sido rechazado.", "Información");
    } else {
      alert.error("No se pudo rechazar el proceso de calidad.", "Error");
    }
    await cargar();
  };

  const guardarComentario = async () => {
    if (!comentarioChip) return;
    await crearComentario({
      id_chip: comentarioChip,
      comentario,
      cve_usuario: "admin",
      status: "Comentario",
    });
    setComentario("");
    setComentarioChip(null);
    setOpenModal(false);
  };

  const filtrados = useMemo(() => {
    const normal = (x: string | null | undefined) => (x ?? "").toLowerCase();

    return items.filter((v) => {
      const st = normal(v.status);
      const stOs = normal(v.status_os);
      const pl = normal(v.no_placas);
      const or = normal(v.no_orden);

      return (
        (!filtroStatus || st.includes(filtroStatus.toLowerCase())) &&
        (!filtroStatusOs || stOs.includes(filtroStatusOs.toLowerCase())) &&
        (!filtroPlacas || pl.includes(filtroPlacas.toLowerCase())) &&
        (!filtroOrden || or.includes(filtroOrden.toLowerCase()))
      );
    });
  }, [items, filtroStatus, filtroStatusOs, filtroPlacas, filtroOrden]);

  return (
    <>
      <NavBar />

      <div className="min-h-screen px-6 py-10">
        <h1 className="text-3xl font-bold mb-6">Vehículos en Calidad</h1>

        {/* ================= FILTROS ================= */}
        <div className="flex flex-col sm:flex-row gap-4 mb-8">
          <select
            className="border rounded-md px-3 py-2 w-full"
            value={filtroStatus}
            onChange={(e) => {
              setFiltroStatus(e.target.value);
              if (e.target.value !== "Terminado") {
                setFiltroStatusOs("");
              }
            }}
          >
            <option value="">Todos</option>
            <option value="Pendiente">Pendiente</option>
            <option value="Iniciada">Proceso</option>
            <option value="Terminado">Terminado</option>
          </select>

          {filtroStatus === "Terminado" && (
            <select
              className="border rounded-md px-3 py-2 w-full"
              value={filtroStatusOs}
              onChange={(e) => setFiltroStatusOs(e.target.value)}
            >
              <option value="">Todos</option>
              <option value="Aprobado">Aprobado</option>
              <option value="Rechazado">Rechazado</option>
            </select>
          )}

          <input
            type="text"
            placeholder="Filtrar por placas..."
            value={filtroPlacas}
            onChange={(e) => setFiltroPlacas(e.target.value)}
            className="border rounded-md px-3 py-2 w-full"
          />

          <input
            type="text"
            placeholder="Filtrar por orden..."
            value={filtroOrden}
            onChange={(e) => setFiltroOrden(e.target.value)}
            className="border rounded-md px-3 py-2 w-full"
          />
        </div>

        {/* ================= CONTADOR ================= */}
        <div className="text-zinc-700 dark:text-zinc-300 mb-6">
          Resultados: <span className="font-semibold">{filtrados.length}</span>
        </div>

        {/* ================= LISTA ================= */}
        {loading && (
          <p className="text-zinc-600 dark:text-zinc-400">Cargando...</p>
        )}

        {!loading && (
          <CalidadList
            items={filtrados}
            onIniciar={(id) => iniciarCalidad(id)}
            onAprobar={(id) => aprobarCalidad(id)}
            onRechazar={(id) => rechazarCalidad(id)}
            onComentarios={abrirComentarios}
          />
        )}

        <Modal
          open={openModal}
          onClose={() => setOpenModal(false)}
          title="Comentarios"
        >
          <CalidadComments
            comentarios={comentarios}
            comentario={comentario}
            setComentario={setComentario}
            onSubmit={guardarComentario}
          />
        </Modal>
      </div>
    </>
  );
}
