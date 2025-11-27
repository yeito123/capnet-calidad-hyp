"use client";

export function NavBar() {
  const goBack = () => {
    if (typeof window !== "undefined") {
      window.history.back();
    }
  };

  return (
    <nav className="w-full bg-zinc-900 text-white px-6 py-4 flex items-center gap-4 shadow-md">
      {/* Botón Back */}
      <button
        onClick={goBack}
        className="px-3 py-1 rounded-md bg-zinc-700 hover:bg-zinc-600 transition text-sm"
      >
        ← Back
      </button>

      {/* Título */}
      <h1 className="text-xl font-semibold">Módulo Calidad HYP</h1>
    </nav>
  );
}
