export type ApiResponse<T = null> = {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
};

export type PaginatedResponse<T> = ApiResponse<{
  items: T[];
  total: number;
  page: number;
  perPage: number;
  totalPages: number;
}>;

export type UnitStatus = "INDENT" | "TRANSIT" | "READY" | "RESERVED" | "SOLD" | "WIP" | "DEMO" | "RETUR";
export type SpkStatus = "DRAFT" | "WAITING_APPROVAL" | "APPROVED" | "DP_PAID" | "PROSES_DOK" | "SIAP_SERAH" | "SELESAI" | "BATAL";
export type WoStatus = "BOOKING" | "ANTRIAN" | "PROSES" | "QC" | "SELESAI" | "INVOICE" | "BATAL";
export type TrackingStage =
  | "SPK_DIBUAT" | "DP_DITERIMA" | "PO_DIKIRIM_ATPM" | "KONFIRMASI_ATPM"
  | "PROSES_PRODUKSI" | "PENGIRIMAN_KE_DEALER" | "UNIT_TIBA_DEALER"
  | "PERSIAPAN_PDI" | "PROSES_DOKUMEN" | "SIAP_SERAH" | "SERAH_TERIMA" | "SELESAI";
export type FinancingStatus = "DRAFT" | "SUBMITTED" | "SURVEY" | "APPROVED" | "REJECTED" | "CAIR" | "BATAL";
export type ProspectStage = "COLD" | "WARM" | "HOT" | "SPK" | "SERAH" | "LOST";
export type PaymentMethod = "CASH" | "KREDIT" | "TUNAI_BERTAHAP";
export type RoleCode = "SUPER_ADMIN" | "ADMIN" | "SALES_MANAGER" | "SALES" | "FINANCE" | "SERVICE_MGR" | "MEKANIK" | "GUDANG" | "HR" | "VIEWER";
