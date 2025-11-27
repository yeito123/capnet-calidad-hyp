"use client";

import React from "react";
import { ComentarioResponse } from "@/modules/calidad/calidad.types";

interface CalidadCommentsProps {
  comentarios: ComentarioResponse[];
  comentario: string;
  setComentario: (value: string) => void;
  onSubmit: () => void;
}

export function CalidadComments({
  comentarios,
  comentario,
  setComentario,
  onSubmit,
}: CalidadCommentsProps) {
  return (
    <div className="w-full">
      {/* === LISTA DE COMENTARIOS === */}
      <div className="space-y-3 max-h-64 overflow-y-auto mb-4 pr-1">
        {comentarios.length === 0 && (
          <p className="text-sm text-zinc-500">
            No hay comentarios para este vehículo.
          </p>
        )}

        {comentarios.map((c) => (
          <div
            key={`${c.id_chip}-${c.fecha}-${c.id_linea}`}
            className="p-3 rounded-md bg-zinc-100 dark:bg-zinc-800
                       border border-zinc-300 dark:border-zinc-700"
          >
            <div className="text-xs text-zinc-500 dark:text-zinc-400">
              {new Date(c.fecha).toLocaleString()} — {c.cve_usuario}
            </div>
            <div className="mt-1 text-sm text-zinc-800 dark:text-zinc-200">
              {c.comentario}
            </div>
          </div>
        ))}
      </div>

      {/* === INPUT PARA NUEVO COMENTARIO === */}
      <textarea
        placeholder="Escribe un comentario..."
        className="w-full border rounded-md px-3 py-2 bg-white dark:bg-zinc-800"
        rows={3}
        value={comentario}
        onChange={(e) => setComentario(e.target.value)}
      />

      {/* === BOTÓN === */}
      <button
        onClick={onSubmit}
        className="mt-4 px-4 py-2 bg-blue-600 text-white rounded-md w-full"
      >
        Guardar comentario
      </button>
    </div>
  );
}
