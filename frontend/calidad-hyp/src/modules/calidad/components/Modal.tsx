"use client";

interface ModalProps {
  open: boolean;
  onClose: () => void;
  children: React.ReactNode;
  title?: string;
}

export function Modal({ open, onClose, children, title }: ModalProps) {
  if (!open) return null;

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
      <div className="bg-white dark:bg-zinc-900 p-6 rounded-lg shadow-lg w-full max-w-md">
        {title && <h2 className="text-xl font-bold mb-4">{title}</h2>}

        {children}

        <div className="text-right mt-4">
          <button
            onClick={onClose}
            className="px-4 py-2 rounded-md bg-zinc-200 dark:bg-zinc-700 hover:bg-zinc-300 dark:hover:bg-zinc-600"
          >
            Cerrar
          </button>
        </div>
      </div>
    </div>
  );
}
