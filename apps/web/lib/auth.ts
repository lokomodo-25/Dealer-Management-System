import NextAuth from "next-auth";
import Credentials from "next-auth/providers/credentials";
import { db } from "@/lib/db/drizzle";
import { sql } from "drizzle-orm";

export const { handlers, auth, signIn, signOut } = NextAuth({
  providers: [
    Credentials({
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Password", type: "password" },
        tenantCode: { label: "Kode Dealer", type: "text" },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password || !credentials?.tenantCode) {
          return null;
        }

        // Resolve tenant by kode_dealer
        const tenantResult = await db.execute(
          sql`SELECT id FROM auth.tenants
              WHERE kode_dealer = ${credentials.tenantCode}
                AND is_active = TRUE AND deleted_at IS NULL
              LIMIT 1`
        );
        const tenant = (tenantResult as unknown as { rows: Array<{ id: string }> }).rows[0];
        if (!tenant) return null;

        // Validate login via DB function
        const result = await db.execute(
          sql`SELECT * FROM auth.validate_login(
                ${tenant.id}::uuid,
                ${credentials.email}::varchar,
                ${credentials.password}::text
              )`
        );
        const row = (result as unknown as { rows: Array<{ user_id: string; full_name: string; is_locked: boolean; error_code: string | null }> }).rows[0];

        if (!row?.user_id || row.error_code) return null;

        // Fetch user's branch and role for JWT
        const roleResult = await db.execute(
          sql`SELECT ubr.branch_id, b.kode_cabang, r.role_code
              FROM auth.user_branch_roles ubr
              JOIN auth.roles r ON r.id = ubr.role_id
              LEFT JOIN auth.branches b ON b.id = ubr.branch_id
              WHERE ubr.user_id = ${row.user_id}::uuid
              ORDER BY ubr.branch_id NULLS LAST
              LIMIT 1`
        );
        const roleRow = (roleResult as unknown as { rows: Array<{ branch_id: string; kode_cabang: string; role_code: string }> }).rows[0];

        return {
          id: row.user_id,
          name: row.full_name,
          email: credentials.email as string,
          tenantId: tenant.id,
          tenantCode: credentials.tenantCode as string,
          branchId: roleRow?.branch_id ?? null,
          branchCode: roleRow?.kode_cabang ?? null,
          roleCode: roleRow?.role_code ?? null,
        };
      },
    }),
  ],
  session: { strategy: "jwt" },
  callbacks: {
    jwt({ token, user }) {
      if (user) {
        token.tenantId   = (user as { tenantId: string }).tenantId;
        token.tenantCode = (user as { tenantCode: string }).tenantCode;
        token.branchId   = (user as { branchId: string | null }).branchId;
        token.branchCode = (user as { branchCode: string | null }).branchCode;
        token.roleCode   = (user as { roleCode: string | null }).roleCode;
      }
      return token;
    },
    session({ session, token }) {
      session.user.id          = token.sub!;
      session.user.tenantId    = token.tenantId as string;
      session.user.tenantCode  = token.tenantCode as string;
      session.user.branchId    = token.branchId as string | null;
      session.user.branchCode  = token.branchCode as string | null;
      session.user.roleCode    = token.roleCode as string | null;
      return session;
    },
  },
  pages: {
    signIn: "/login",
    error: "/login",
  },
});
