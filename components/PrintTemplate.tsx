'use client';

import { formatCurrency, formatDate } from '@/lib/format';

export interface PrintItem {
  product_name: string;
  product_sku?: string;
  quantity: number;
  unit_price: number;
  discount_percent?: number;
  subtotal: number;
  unit_name?: string;
}

export interface PrintMetaField {
  label: string;
  value: string;
}

export interface PrintPayment {
  payment_number: string;
  payment_date: string;
  amount: number;
  payment_method: string;
}

export interface PrintTemplateProps {
  docType: 'INVOICE' | 'QUOTATION' | 'SALES ORDER';
  docNumber: string;
  docDate: string;
  dueDate?: string;
  expiryDate?: string;
  status?: string;
  company: {
    name: string;
    address?: string;
    phone?: string;
    email?: string;
    logo_url?: string;
  };
  customer: {
    name: string;
    code?: string;
    phone?: string;
    address?: string;
  };
  items: PrintItem[];
  subtotal: number;
  discountTotal?: number;
  totalAmount: number;
  amountPaid?: number;
  balanceDue?: number;
  notes?: string;
  payments?: PrintPayment[];
  metaFields?: PrintMetaField[];
}

const cellBorder = '1px solid #ccc';

export default function PrintTemplate({
  docType,
  docNumber,
  docDate,
  dueDate,
  expiryDate,
  status,
  company,
  customer,
  items,
  subtotal,
  discountTotal = 0,
  totalAmount,
  amountPaid = 0,
  balanceDue = 0,
  notes,
  payments,
  metaFields,
}: PrintTemplateProps) {
  const grossTotal = subtotal + discountTotal;
  const showPayments = payments && payments.length > 0;
  const isQuote = docType === 'QUOTATION';

  return (
    <div className="print-document" style={{ fontFamily: "'Helvetica Neue', Arial, sans-serif", color: '#111', maxWidth: '800px', margin: '0 auto' }}>
      {/* ===== Title ===== */}
      <h1 style={{ textAlign: 'center', fontSize: '26px', fontWeight: 800, letterSpacing: '3px', margin: '0 0 6px 0' }}>{docType}</h1>
      {status && (
        <p style={{ textAlign: 'center', fontSize: '10px', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '2px', color: '#777', margin: '0 0 20px 0' }}>{status}</p>
      )}

      {/* ===== Company Header: logo left, address right ===== */}
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
        <div style={{ display: 'flex' }}>
          <span style={{ width: '140px', fontWeight: 600, color: '#444' }}>{isQuote ? 'Quotation No:' : 'Invoice No:'}</span>
          <span>{docNumber}</span>
        </div>
        <div style={{ display: 'flex' }}>
          <span style={{ width: '140px', fontWeight: 600, color: '#444' }}>Date:</span>
          <span>{formatDate(docDate)}</span>
        </div>
        {dueDate && !isQuote && (
          <div style={{ display: 'flex' }}>
            <span style={{ width: '140px', fontWeight: 600, color: '#444' }}>Due Date:</span>
            <span>{formatDate(dueDate)}</span>
          </div>
        )}
        {expiryDate && isQuote && (
          <div style={{ display: 'flex' }}>
            <span style={{ width: '140px', fontWeight: 600, color: '#444' }}>Valid Until:</span>
            <span>{formatDate(expiryDate)}</span>
          </div>
        )}
        <div style={{ display: 'flex' }}>
          <span style={{ width: '140px', fontWeight: 600, color: '#444' }}>{isQuote ? 'Quotation For:' : 'Customer Name:'}</span>
          <span>{customer.name}{customer.code ? ` (${customer.code})` : ''}</span>
        </div>
        {customer.address && (
          <div style={{ display: 'flex' }}>
            <span style={{ width: '140px', fontWeight: 600, color: '#444' }}>Address:</span>
            <span>{customer.address}</span>
          </div>
        )}
        {customer.phone && (
          <div style={{ display: 'flex' }}>
            <span style={{ width: '140px', fontWeight: 600, color: '#444' }}>Phone:</span>
            <span>{customer.phone}</span>
          </div>
        )}
        {metaFields?.map((f, i) => (
          <div key={i} style={{ display: 'flex' }}>
            <span style={{ width: '140px', fontWeight: 600, color: '#444' }}>{f.label}:</span>
            <span>{f.value}</span>
          </div>
        ))}

        {/* Payments inside Details for invoices */}
        {!isQuote && showPayments && (
          <div style={{ marginTop: '10px', borderTop: '1px solid #ddd', paddingTop: '8px' }}>
            <p style={{ fontWeight: 700, fontSize: '11px', margin: '0 0 4px 0' }}>Payments Received:</p>
            {payments!.map((p, i) => (
              <div key={i} style={{ display: 'flex', fontSize: '11px' }}>
                <span style={{ width: '140px', color: '#666' }}>{formatDate(p.payment_date)}</span>
                <span style={{ flex: 1 }}>{p.payment_number} ({p.payment_method?.replace(/_/g, ' ')})</span>
                <span style={{ fontWeight: 600, color: '#16a34a' }}>{formatCurrency(p.amount)}</span>
              </div>
            ))}
          </div>
        )}

        {/* Balance Due inside Details for invoices */}
        {!isQuote && amountPaid > 0 && (
          <div style={{ display: 'flex', marginTop: '8px', borderTop: '1px solid #ddd', paddingTop: '8px' }}>
            <span style={{ width: '140px', fontWeight: 700, color: '#444' }}>Balance Due:</span>
            <span style={{ fontWeight: 700, color: balanceDue > 0 ? '#dc2626' : '#16a34a' }}>{formatCurrency(balanceDue)}</span>
          </div>
        )}
      </div>

      {/* ===== Items Table with totals inside ===== */}
      <table style={{ width: '100%', borderCollapse: 'collapse', marginBottom: '16px' }}>
        <thead>
          <tr style={{ background: '#f5f5f5' }}>
            <th style={{ border: cellBorder, padding: '7px 8px', fontSize: '9px', fontWeight: 700, textTransform: 'uppercase', textAlign: 'left' }}>SL No</th>
            <th style={{ border: cellBorder, padding: '7px 8px', fontSize: '9px', fontWeight: 700, textTransform: 'uppercase', textAlign: 'left' }}>Item Code</th>
            <th style={{ border: cellBorder, padding: '7px 8px', fontSize: '9px', fontWeight: 700, textTransform: 'uppercase', textAlign: 'left' }}>Item Details</th>
            <th style={{ border: cellBorder, padding: '7px 8px', fontSize: '9px', fontWeight: 700, textTransform: 'uppercase', textAlign: 'right' }}>Qty</th>
            <th style={{ border: cellBorder, padding: '7px 8px', fontSize: '9px', fontWeight: 700, textTransform: 'uppercase', textAlign: 'right' }}>Rate</th>
            <th style={{ border: cellBorder, padding: '7px 8px', fontSize: '9px', fontWeight: 700, textTransform: 'uppercase', textAlign: 'right' }}>Disc %</th>
            <th style={{ border: cellBorder, padding: '7px 8px', fontSize: '9px', fontWeight: 700, textTransform: 'uppercase', textAlign: 'right' }}>Amount</th>
          </tr>
        </thead>
        <tbody>
          {items.length === 0 ? (
            <tr><td colSpan={7} style={{ border: cellBorder, textAlign: 'center', padding: '16px', fontSize: '12px', color: '#999' }}>No items</td></tr>
          ) : items.map((item, idx) => (
            <tr key={idx}>
              <td style={{ border: cellBorder, padding: '6px 8px', fontSize: '11px', color: '#666', textAlign: 'center' }}>{idx + 1}</td>
              <td style={{ border: cellBorder, padding: '6px 8px', fontSize: '11px', fontFamily: 'monospace', color: '#666' }}>{item.product_sku || '—'}</td>
              <td style={{ border: cellBorder, padding: '6px 8px', fontSize: '11px', fontWeight: 500 }}>
                {item.product_name}
                {item.unit_name && <span style={{ fontSize: '10px', color: '#999', display: 'block' }}>{item.unit_name}</span>}
              </td>
              <td style={{ border: cellBorder, padding: '6px 8px', fontSize: '11px', textAlign: 'right' }}>{item.quantity}{item.unit_name ? ` ${item.unit_name}` : ''}</td>
              <td style={{ border: cellBorder, padding: '6px 8px', fontSize: '11px', textAlign: 'right' }}>{formatCurrency(item.unit_price)}</td>
              <td style={{ border: cellBorder, padding: '6px 8px', fontSize: '11px', textAlign: 'right', color: '#666' }}>{(item.discount_percent || 0) > 0 ? `${item.discount_percent}%` : '—'}</td>
              <td style={{ border: cellBorder, padding: '6px 8px', fontSize: '11px', textAlign: 'right', fontWeight: 600 }}>{formatCurrency(item.subtotal)}</td>
            </tr>
          ))}
          {/* Totals rows inside table */}
          <tr>
            <td colSpan={4} style={{ border: cellBorder, padding: '6px 8px' }}></td>
            <td colSpan={2} style={{ border: cellBorder, padding: '6px 8px', fontSize: '11px', fontWeight: 600, textAlign: 'right', background: '#fafafa' }}>Total</td>
            <td style={{ border: cellBorder, padding: '6px 8px', fontSize: '11px', fontWeight: 700, textAlign: 'right', background: '#fafafa' }}>{formatCurrency(grossTotal)}</td>
          </tr>
          {discountTotal > 0 && (
            <tr>
              <td colSpan={4} style={{ border: cellBorder, padding: '6px 8px' }}></td>
              <td colSpan={2} style={{ border: cellBorder, padding: '6px 8px', fontSize: '11px', fontWeight: 600, textAlign: 'right', background: '#fafafa' }}>Discount</td>
              <td style={{ border: cellBorder, padding: '6px 8px', fontSize: '11px', fontWeight: 700, textAlign: 'right', color: '#dc2626', background: '#fafafa' }}>-{formatCurrency(discountTotal)}</td>
            </tr>
          )}
          {!isQuote && amountPaid > 0 && (
            <tr>
              <td colSpan={4} style={{ border: cellBorder, padding: '6px 8px' }}></td>
              <td colSpan={2} style={{ border: cellBorder, padding: '6px 8px', fontSize: '11px', fontWeight: 600, textAlign: 'right', background: '#fafafa' }}>Amount Paid</td>
              <td style={{ border: cellBorder, padding: '6px 8px', fontSize: '11px', fontWeight: 700, textAlign: 'right', color: '#16a34a', background: '#fafafa' }}>-{formatCurrency(amountPaid)}</td>
            </tr>
          )}
          {/* Net Value row — bold, dark background */}
          <tr style={{ background: '#e8e8e8' }}>
            <td colSpan={4} style={{ border: cellBorder, padding: '8px 8px' }}></td>
            <td colSpan={2} style={{ border: cellBorder, padding: '8px 8px', fontSize: '12px', fontWeight: 800, textAlign: 'right' }}>{isQuote ? 'Total' : 'Balance Due'}</td>
            <td style={{ border: cellBorder, padding: '8px 8px', fontSize: '13px', fontWeight: 800, textAlign: 'right' }}>
              {formatCurrency(isQuote ? totalAmount : balanceDue)}
            </td>
          </tr>
        </tbody>
      </table>

      {/* ===== Overall Remarks ===== */}
      {notes && (
        <div style={{ marginBottom: '20px' }}>
          <p style={{ fontSize: '9px', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '1.5px', color: '#888', margin: '0 0 4px 0' }}>Overall Remarks</p>
          <p style={{ fontSize: '11px', color: '#555', margin: 0, lineHeight: 1.6 }}>{notes}</p>
        </div>
      )}

      {/* ===== Footer ===== */}
      <div style={{ marginTop: '32px', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end' }}>
        <div>
          <p style={{ fontSize: '9px', color: '#999', margin: 0 }}>This is a computer-generated document and does not require a signature.</p>
          <p style={{ fontSize: '10px', fontWeight: 600, color: '#555', margin: '4px 0 0 0' }}>Thank you for your business!</p>
        </div>
        <div style={{ borderTop: '1px solid #999', width: '140px', paddingTop: '4px', textAlign: 'center' }}>
          <p style={{ fontSize: '9px', color: '#999', margin: 0 }}>Authorized Signature</p>
        </div>
      </div>
    </div>
  );
}
