import Swal from "sweetalert2";
import withReactContent from "sweetalert2-react-content";

const MySwal = withReactContent(Swal);

export const alert = {
  success: (text: string, title = "Éxito") => {
    return MySwal.fire({
      title,
      text,
      icon: "success",
      confirmButtonColor: "#2563EB", // azul tailwind
    });
  },

  error: (text: string, title = "Error") => {
    return MySwal.fire({
      title,
      text,
      icon: "error",
      confirmButtonColor: "#DC2626", // rojo tailwind
    });
  },

  info: (text: string, title = "Información") => {
    return MySwal.fire({
      title,
      text,
      icon: "info",
      confirmButtonColor: "#2563EB",
    });
  },

  confirm: async (text: string, title = "Confirmar") => {
    const result = await MySwal.fire({
      title,
      text,
      icon: "question",
      showCancelButton: true,
      confirmButtonText: "Sí",
      cancelButtonText: "No",
      confirmButtonColor: "#16A34A", // verde
      cancelButtonColor: "#DC2626",
    });

    return result.isConfirmed;
  },
};
