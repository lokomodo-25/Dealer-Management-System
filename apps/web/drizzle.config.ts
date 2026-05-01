import type { Config } from "drizzle-kit";

export default {
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
  schemaFilter: ["public", "auth", "dealer"],
  out: "./drizzle",
} satisfies Config;
