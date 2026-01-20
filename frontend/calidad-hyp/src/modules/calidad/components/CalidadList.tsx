"use client";

import { CalidadResponse } from "@/modules/calidad/calidad.types";
import { CalidadCard } from "./CalidadCard";

interface CalidadListProps {
  items: CalidadResponse[];
  onIniciar: (id: number) => void;
  onAprobar: (id: number) => void;
  onRechazar: (id: number) => void;
  onComentarios: (chipId: number | null | undefined) => void;
}

export function CalidadList({
  items,
  onIniciar,
  onAprobar,
  onRechazar,
  onComentarios,
}: CalidadListProps) {
  if (!items.length) {
    return (
      <p className="text-zinc-600 dark:text-zinc-400">
        No hay resultados con los filtros aplicados.
      </p>
    );
  }

  return (
    <ul className="space-y-4 mt-4">
      {items.map((v) => (
        <CalidadCard
          key={v.id}
          item={v}
          onIniciar={onIniciar}
          onAprobar={onAprobar}
          onRechazar={onRechazar}
          onComentarios={onComentarios}
        />
      ))}
    </ul>
  );
}
