import axios from "axios";
import { ENV } from "@/core/config/env";

const api = axios.create({
  baseURL: ENV.API_URL ?? "",
  withCredentials: true,
});

export { api };
