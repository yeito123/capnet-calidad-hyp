"use client";

import dayjs from "dayjs";
import {
  PlayIcon,
  CheckIcon,
  ChatBubbleLeftRightIcon,
} from "@heroicons/react/24/solid";

import { CalidadResponse } from "@/modules/calidad/calidad.types";

interface CalidadCardProps {
  item: CalidadResponse;
  onIniciar: (id: number) => void;
  onFinalizar: (id: number) => void;
  onComentarios: (chipId: number | null | undefined) => void;
}

export function CalidadCard({
  item,
  onIniciar,
  onFinalizar,
  onComentarios,
}: CalidadCardProps) {
  const formatTime = (date: string | null | undefined) => {
    if (!date) return "N/A";
    return dayjs(date).format("HH:mm A");
  };

  return (
    <li className="rounded-lg p-4 border border-zinc-200 bg-white dark:bg-zinc-900 dark:border-zinc-700 shadow-sm">
      <div className="font-semibold text-lg">
        {item.color ?? "Sin color"} {item.vehiculo ?? "Vehículo sin nombre"}
      </div>

      <div className="text-sm text-zinc-600 dark:text-zinc-400">
        <span className="font-semibold">Orden:</span> {item.no_orden ?? "N/A"} —{" "}
        <span className="font-semibold">Placas:</span> {item.no_placas ?? "N/A"}
      </div>
      <div className="text-sm text-zinc-600 dark:text-zinc-400 mt-1">
        <span className="font-semibold">Asesor:</span> {item.asesor ?? "N/A"}
      </div>
      <div className="text-sm text-zinc-600 dark:text-zinc-400 mt-1">
        <span className="font-semibold">Técnico:</span> {item.tecnico ?? "N/A"}
      </div>
      <div className="text-sm text-zinc-600 dark:text-zinc-400 mt-1">
        <span className="font-semibold">Hora Inicio:</span>{" "}
        {formatTime(item.fecha_hora_ini_oper)}
      </div>
      {item.fecha_hora_fin_oper && (
        <div className="text-sm text-zinc-600 dark:text-zinc-400 mt-1">
          <span className="font-semibold">Hora Fin:</span>{" "}
          {formatTime(item.fecha_hora_fin_oper)}
        </div>
      )}
      <div className="text-sm mt-2 mb-3">
        <span className="font-semibold">Estado:</span>{" "}
        <span className="font-medium text-blue-600 dark:text-blue-400">
          {item.status ?? "Sin estado"}
        </span>
      </div>

      {/* ================== ACCIONES ================== */}
      <div className="flex gap-3">
        {/* INICIAR */}
        {!item.fecha_hora_ini_oper && (
          <button
            onClick={() => onIniciar(item.id)}
            className="px-3 py-2 bg-blue-600 text-white rounded-md flex items-center gap-2 hover:bg-blue-700 transition"
          >
            <PlayIcon className="w-5 h-5" />
            <span>Iniciar</span>
          </button>
        )}

        {/* FINALIZAR */}
        {item.fecha_hora_ini_oper && !item.fecha_hora_fin_oper && (
          <button
            onClick={() => onFinalizar(item.id)}
            className="px-3 py-2 bg-green-600 text-white rounded-md flex items-center gap-2 hover:bg-green-700 transition"
          >
            <CheckIcon className="w-5 h-5" />
            <span>Finalizar</span>
          </button>
        )}

        {/* COMENTARIOS */}
        <button
          onClick={() => onComentarios(item.id_chip)}
          className="px-3 py-2 bg-zinc-700 text-white rounded-md flex items-center gap-2 hover:bg-zinc-800 transition"
        >
          <ChatBubbleLeftRightIcon className="w-5 h-5" />
          <span>Comentarios</span>
        </button>
      </div>
    </li>
  );
}
