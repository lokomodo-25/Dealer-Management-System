import { auth } from "@/lib/auth";

export default async function DashboardPage() {
  const session = await auth();

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-2">Dashboard</h1>
      <p className="text-muted-foreground">
        Selamat datang, {session?.user?.name}
        {session?.user?.branchCode ? ` — ${session.user.branchCode}` : ""}
      </p>
      <div className="mt-6 grid grid-cols-1 md:grid-cols-4 gap-4">
        {["Unit Ready", "Prospek Aktif", "SPK Bulan Ini", "WO Berjalan"].map((label) => (
          <div key={label} className="bg-white rounded-lg border p-6">
            <p className="text-sm text-muted-foreground">{label}</p>
            <p className="text-3xl font-bold mt-1">—</p>
          </div>
        ))}
      </div>
    </div>
  );
}
