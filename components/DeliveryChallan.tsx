'use client';

import { formatDate } from '@/lib/format';

export interface ChallanItem {
  product_name: string;
  product_sku?: string;
  quantity: number;
  delivered_quantity?: number;
  unit_name?: string;
}

export interface DeliveryChallanProps {
  challanNumber: string;
  deliveryDate?: string;
  invoiceNumber?: string;
  company: {
    name: string;
    address?: string;
    phone?: string;
    email?: string;
    logo_url?: string;
  };
  customer: {
    name: string;
    phone?: string;
    address?: string;
    city?: string;
  };
  items: ChallanItem[];
  vehicleNumber?: string;
  driverName?: string;
  notes?: string;
}

const cellBorder = '1px solid #ccc';

export default function DeliveryChallan({
  challanNumber,
  deliveryDate,
  invoiceNumber,
  company,
  customer,
  items,
  vehicleNumber,
  driverName,
  notes,
}: DeliveryChallanProps) {
  const totalQty = items.reduce((s, i) => s + Math.abs(i.delivered_quantity ?? i.quantity), 0);

  return (
    <div className="print-document" style={{ fontFamily: "'Helvetica Neue', Arial, sans-serif", color: '#111', maxWidth: '800px', margin: '0 auto' }}>
      {/* ===== Title ===== */}
      <h1 style={{ textAlign: 'center', fontSize: '26px', fontWeight: 800, letterSpacing: '3px', margin: '0 0 20px 0' }}>DELIVERY CHALLAN</h1>

      {/* ===== Company Header ===== */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '24px' }}>
        <div>
          {company.logo_url && (
            <img src={company.logo_url} alt="logo" style={{ height: '56px', maxWidth: '120px', objectFit: 'contain', marginBottom: '8px' }} />
          )}
        </div>
        <div style={{ textAlign: 'right' }}>
          <p style={{ fontSize: '16px', fontWeight: 700, margin: 0 }}>{company.name || 'Your Company'}</p>
          {company.address && <p style={{ fontSize: '11px', color: '#555', margin: '3px 0 0 0', maxWidth: '300px', lineHeight: 1.5 }}>{company.address}</p>}
          <div style={{ display: 'flex', gap: '14px', justifyContent: 'flex-end', marginTop: '3px' }}>
            {company.phone && <p style={{ fontSize: '11px', color: '#555', margin: 0 }}>Tel: {company.phone}</p>}
            {company.email && <p style={{ fontSize: '11px', color: '#555', margin: 0 }}>{company.email}</p>}
          </div>
        </div>
      </div>

      {/* ===== Document Details — plain key:value rows ===== */}
      <div style={{ marginBottom: '20px', fontSize: '12px', lineHeight: 1.9 }}>
        {invoiceNumber && (
          <div style={{ display: 'flex' }}>
            <span style={{ width: '160px', fontWeight: 600, color: '#444' }}>Invoice/Order No:</span>
            <span>{invoiceNumber}</span>
          </div>
        )}
        <div style={{ display: 'flex' }}>
          <span style={{ width: '160px', fontWeight: 600, color: '#444' }}>Delivery Challan No:</span>
          <span>{challanNumber}</span>
        </div>
        {deliveryDate && (
          <div style={{ display: 'flex' }}>
            <span style={{ width: '160px', fontWeight: 600, color: '#444' }}>Date:</span>
            <span>{formatDate(deliveryDate)}</span>
          </div>
        )}
        <div style={{ display: 'flex' }}>
          <span style={{ width: '160px', fontWeight: 600, color: '#444' }}>Customer Name:</span>
          <span>{customer.name}</span>
        </div>
        {customer.address && (
          <div style={{ display: 'flex' }}>
            <span style={{ width: '160px', fontWeight: 600, color: '#444' }}>Address:</span>
            <span>{customer.address}{customer.city ? `, ${customer.city}` : ''}</span>
          </div>
        )}
        {customer.phone && (
          <div style={{ display: 'flex' }}>
            <span style={{ width: '160px', fontWeight: 600, color: '#444' }}>Phone:</span>
            <span>{customer.phone}</span>
          </div>
        )}
        {vehicleNumber && (
          <div style={{ display: 'flex' }}>
            <span style={{ width: '160px', fontWeight: 600, color: '#444' }}>Vehicle Details:</span>
            <span>{vehicleNumber}</span>
          </div>
        )}
        {driverName && (
          <div style={{ display: 'flex' }}>
            <span style={{ width: '160px', fontWeight: 600, color: '#444' }}>Driver:</span>
            <span>{driverName}</span>
          </div>
        )}
      </div>

      {/* ===== Items Table ===== */}
      <table style={{ width: '100%', borderCollapse: 'collapse', marginBottom: '16px' }}>
        <thead>
          <tr style={{ background: '#f5f5f5' }}>
            <th style={{ border: cellBorder, padding: '7px 8px', fontSize: '9px', fontWeight: 700, textTransform: 'uppercase', textAlign: 'center', width: '50px' }}>SL No</th>
            <th style={{ border: cellBorder, padding: '7px 8px', fontSize: '9px', fontWeight: 700, textTransform: 'uppercase', textAlign: 'left' }}>Item Code</th>
            <th style={{ border: cellBorder, padding: '7px 8px', fontSize: '9px', fontWeight: 700, textTransform: 'uppercase', textAlign: 'left' }}>Item Name</th>
            <th style={{ border: cellBorder, padding: '7px 8px', fontSize: '9px', fontWeight: 700, textTransform: 'uppercase', textAlign: 'right', width: '120px' }}>Delivered Qty</th>
          </tr>
        </thead>
        <tbody>
          {items.length === 0 ? (
            <tr><td colSpan={4} style={{ border: cellBorder, textAlign: 'center', padding: '16px', fontSize: '12px', color: '#999' }}>No items</td></tr>
          ) : items.map((item, idx) => {
            const qty = item.delivered_quantity ?? item.quantity;
            return (
              <tr key={idx}>
                <td style={{ border: cellBorder, padding: '6px 8px', fontSize: '11px', color: '#666', textAlign: 'center' }}>{idx + 1}</td>
                <td style={{ border: cellBorder, padding: '6px 8px', fontSize: '11px', fontFamily: 'monospace', color: '#666' }}>{item.product_sku || '—'}</td>
                <td style={{ border: cellBorder, padding: '6px 8px', fontSize: '11px', fontWeight: 500 }}>{item.product_name}</td>
                <td style={{ border: cellBorder, padding: '6px 8px', fontSize: '11px', textAlign: 'right', fontWeight: 600 }}>{qty}{item.unit_name ? ` ${item.unit_name}` : ''}</td>
              </tr>
            );
          })}
          {/* Total row inside table */}
          <tr style={{ background: '#e8e8e8' }}>
            <td colSpan={3} style={{ border: cellBorder, padding: '8px 8px', fontSize: '12px', fontWeight: 800, textAlign: 'right' }}>Total</td>
            <td style={{ border: cellBorder, padding: '8px 8px', fontSize: '12px', fontWeight: 800, textAlign: 'right' }}>{totalQty}</td>
          </tr>
        </tbody>
      </table>

      {/* ===== Remarks ===== */}
      {notes && (
        <div style={{ marginBottom: '28px' }}>
          <p style={{ fontSize: '9px', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '1.5px', color: '#888', margin: '0 0 4px 0' }}>Remarks</p>
          <p style={{ fontSize: '11px', color: '#555', margin: 0, lineHeight: 1.6 }}>{notes}</p>
        </div>
      )}

      {/* ===== Signature Lines ===== */}
      <div style={{ marginTop: '40px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '32px 48px' }}>
        {['Receiver', 'Factory / Store Officer', 'Security Officer', 'Driver'].map((label) => (
          <div key={label}>
            <div style={{ borderTop: '1px solid #999', paddingTop: '4px' }}>
              <p style={{ fontSize: '10px', color: '#666', margin: 0 }}>{label}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
