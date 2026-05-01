import "next-auth";

declare module "next-auth" {
  interface User {
    tenantId: string;
    tenantCode: string;
    branchId: string | null;
    branchCode: string | null;
    roleCode: string | null;
  }

  interface Session {
    user: {
      id: string;
      name: string | null;
      email: string;
      tenantId: string;
      tenantCode: string;
      branchId: string | null;
      branchCode: string | null;
      roleCode: string | null;
    };
  }
}

declare module "next-auth/jwt" {
  interface JWT {
    tenantId: string;
    tenantCode: string;
    branchId: string | null;
    branchCode: string | null;
    roleCode: string | null;
  }
}
