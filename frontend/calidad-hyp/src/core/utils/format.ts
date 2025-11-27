// core/utils/format.ts
import { ENV } from "../config/env";

export const format = {
  currency(value: number, currency: string = ENV.DEFAULT_CURRENCY) {
    return new Intl.NumberFormat(ENV.DEFAULT_LOCALE, {
      style: "currency",
      currency,
    }).format(value);
  },

  number(value: number) {
    return new Intl.NumberFormat(ENV.DEFAULT_LOCALE).format(value);
  },

  date(value: string | Date) {
    return new Date(value).toLocaleDateString(ENV.DEFAULT_LOCALE);
  },

  datetime(value: string | Date) {
    return new Date(value).toLocaleString(ENV.DEFAULT_LOCALE);
  },
};
