import { auth } from "@/lib/auth";
import { db } from "@/lib/db/drizzle";
import { sql } from "drizzle-orm";
import { redirect } from "next/navigation";

export type ActionType = "CREATE" | "READ" | "UPDATE" | "DELETE" | "EXPORT" | "APPROVE";

export async function checkPermission(resource: string, action: ActionType): Promise<boolean> {
  const session = await auth();
  if (!session?.user) return false;

  const result = await db.execute(
    sql`SELECT auth.user_has_permission(
          ${session.user.id}::uuid,
          ${session.user.branchId}::uuid,
          ${resource}::varchar,
          ${action}::auth.action_enum
        ) AS has_perm`
  );
  const row = (result as unknown as { rows: Array<{ has_perm: boolean }> }).rows[0];
  return row?.has_perm ?? false;
}

export async function requirePermission(resource: string, action: ActionType) {
  const allowed = await checkPermission(resource, action);
  if (!allowed) redirect("/unauthorized");
}

export async function requireAuth() {
  const session = await auth();
  if (!session?.user) redirect("/login");
  return session;
}

export function isRole(roleCode: string | null, ...roles: string[]): boolean {
  return !!roleCode && roles.includes(roleCode);
}

export const ROLES = {
  SUPER_ADMIN:   "SUPER_ADMIN",
  ADMIN:         "ADMIN",
  SALES_MANAGER: "SALES_MANAGER",
  SALES:         "SALES",
  FINANCE:       "FINANCE",
  SERVICE_MGR:   "SERVICE_MGR",
  MEKANIK:       "MEKANIK",
  GUDANG:        "GUDANG",
  HR:            "HR",
  VIEWER:        "VIEWER",
} as const;
