import { requireAuth } from "@/lib/permissions";

export default async function DealerLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  await requireAuth();

  return (
    <div className="flex min-h-screen bg-gray-100">
      <aside className="w-64 bg-white border-r flex flex-col">
        <div className="p-4 border-b">
          <h1 className="font-bold text-lg">DMS</h1>
        </div>
        <nav className="p-4 space-y-1 flex-1">
          <a href="/dashboard" className="block px-3 py-2 rounded text-sm hover:bg-gray-100">Dashboard</a>
          <a href="/showroom" className="block px-3 py-2 rounded text-sm hover:bg-gray-100">Showroom</a>
          <a href="/crm" className="block px-3 py-2 rounded text-sm hover:bg-gray-100">CRM / Prospek</a>
          <a href="/spk" className="block px-3 py-2 rounded text-sm hover:bg-gray-100">SPK</a>
          <a href="/finance" className="block px-3 py-2 rounded text-sm hover:bg-gray-100">Finance</a>
          <a href="/service" className="block px-3 py-2 rounded text-sm hover:bg-gray-100">Service</a>
          <a href="/inventory" className="block px-3 py-2 rounded text-sm hover:bg-gray-100">Inventory</a>
          <a href="/hr" className="block px-3 py-2 rounded text-sm hover:bg-gray-100">HR</a>
        </nav>
      </aside>
      <main className="flex-1 overflow-auto">
        {children}
      </main>
    </div>
  );
}
