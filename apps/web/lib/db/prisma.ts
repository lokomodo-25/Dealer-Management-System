// Prisma client — run `prisma db pull && prisma generate` after migrations
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type PrismaClient = any;
// eslint-disable-next-line @typescript-eslint/no-require-imports
const { PrismaClient: PC } = require("@prisma/client");

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };

export const prisma =
  globalForPrisma.prisma ??
  new PC({
    log:
      process.env.NODE_ENV === "development"
        ? ["query", "error", "warn"]
        : ["error"],
  });

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
