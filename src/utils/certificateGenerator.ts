import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';
import { OnionBatch, OnionInspection } from '../types';
import { AppConfig } from '../config/appConfig';

/**
 * Downloads the certificate DOM element as a crisp, formatted A4 PDF.
 * If HTML canvas rendering encounters any issue, falls back seamlessly
 * to a vector-drawn native PDF so the user's download NEVER fails.
 */
export async function downloadCertificatePdf(
  elementId: string,
  batch: OnionBatch,
  inspection: OnionInspection
): Promise<boolean> {
  const filename = `OnionSure_Certificate_${inspection.id}_${batch.batchNumber}.pdf`;

  try {
    const element = document.getElementById(elementId);
    if (!element) {
      throw new Error(`Element with id "${elementId}" not found.`);
    }

    // Scroll to top to ensure complete render
    window.scrollTo(0, 0);

    // Render DOM node to canvas at high resolution
    const canvas = await html2canvas(element, {
      scale: 2,
      useCORS: true,
      allowTaint: true,
      backgroundColor: '#ffffff',
      logging: false,
      windowWidth: 1024, // Consistent desktop-grade rendering regardless of mobile screen
      onclone: (clonedDoc) => {
        const clonedEl = clonedDoc.getElementById(elementId);
        if (clonedEl) {
          clonedEl.style.margin = '0';
          clonedEl.style.boxShadow = 'none';
          clonedEl.style.maxWidth = '850px';
          clonedEl.style.width = '850px';
        }
      },
    });

    const imgData = canvas.toDataURL('image/png', 1.0);
    const pdf = new jsPDF({
      orientation: 'portrait',
      unit: 'mm',
      format: 'a4',
      compress: true,
    });

    const pageWidth = pdf.internal.pageSize.getWidth(); // 210mm
    const pageHeight = pdf.internal.pageSize.getHeight(); // 297mm
    const margin = 10; // 10mm margins
    const printableWidth = pageWidth - margin * 2; // 190mm

    const imgWidth = printableWidth;
    const imgHeight = (canvas.height * imgWidth) / canvas.width;

    if (imgHeight <= pageHeight - margin * 2) {
      // Fits on a single A4 page with top & bottom breathing room
      const yOffset = margin + Math.max(0, (pageHeight - margin * 2 - imgHeight) / 4);
      pdf.addImage(imgData, 'PNG', margin, yOffset, imgWidth, imgHeight, undefined, 'FAST');
    } else {
      // Multi-page handling if certificate is taller than one A4 sheet
      let heightLeft = imgHeight;
      let position = margin;

      pdf.addImage(imgData, 'PNG', margin, position, imgWidth, imgHeight, undefined, 'FAST');
      heightLeft -= pageHeight - margin * 2;

      while (heightLeft > 0) {
        position = heightLeft - imgHeight + margin;
        pdf.addPage();
        pdf.addImage(imgData, 'PNG', margin, position, imgWidth, imgHeight, undefined, 'FAST');
        heightLeft -= pageHeight - margin * 2;
      }
    }

    pdf.save(filename);
    return true;
  } catch (err) {
    console.warn('Canvas PDF generation encountered an issue, generating vector PDF fallback...', err);
    // Reliable vector fallback: Draw clean APMC Certificate with jsPDF vector engine
    generateNativeVectorPdf(batch, inspection, filename);
    return true;
  }
}

/**
 * Downloads the certificate as a high-resolution PNG image.
 */
export async function downloadCertificatePng(
  elementId: string,
  batch: OnionBatch,
  inspection: OnionInspection
): Promise<boolean> {
  const filename = `OnionSure_Certificate_${inspection.id}_${batch.batchNumber}.png`;

  try {
    const element = document.getElementById(elementId);
    if (!element) {
      throw new Error(`Element with id "${elementId}" not found.`);
    }

    const canvas = await html2canvas(element, {
      scale: 2.5,
      useCORS: true,
      allowTaint: true,
      backgroundColor: '#ffffff',
      logging: false,
      windowWidth: 1024,
      onclone: (clonedDoc) => {
        const clonedEl = clonedDoc.getElementById(elementId);
        if (clonedEl) {
          clonedEl.style.margin = '0';
          clonedEl.style.boxShadow = 'none';
          clonedEl.style.maxWidth = '850px';
          clonedEl.style.width = '850px';
        }
      },
    });

    const dataUrl = canvas.toDataURL('image/png', 1.0);
    const link = document.createElement('a');
    link.href = dataUrl;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    return true;
  } catch (err) {
    console.error('Failed to download PNG certificate:', err);
    throw err;
  }
}

/**
 * Native jsPDF vector certificate generator.
 * Zero-dependency on DOM or canvas, works guaranteed in any sandbox or iframe.
 */
export function generateNativeVectorPdf(
  batch: OnionBatch,
  inspection: OnionInspection,
  filename: string
): void {
  const doc = new jsPDF({
    orientation: 'portrait',
    unit: 'mm',
    format: 'a4',
  });

  const pageWidth = 210;
  const pageHeight = 297;
  const margin = 12;

  // Outer decorative border
  doc.setDrawColor(124, 45, 18); // #7C2D12 (Rust/Onion primary)
  doc.setLineWidth(1.2);
  doc.rect(margin, margin, pageWidth - margin * 2, pageHeight - margin * 2);

  // Inner thin border
  doc.setDrawColor(203, 213, 225); // slate-300
  doc.setLineWidth(0.3);
  doc.rect(margin + 2, margin + 2, pageWidth - margin * 2 - 4, pageHeight - margin * 2 - 4);

  // Header Banner
  doc.setFillColor(254, 243, 199); // amber-100
  doc.rect(margin + 2.5, margin + 2.5, pageWidth - margin * 2 - 5, 26, 'F');

  doc.setFont('helvetica', 'bold');
  doc.setFontSize(18);
  doc.setTextColor(124, 45, 18);
  doc.text(AppConfig.appName.toUpperCase(), pageWidth / 2, margin + 11, { align: 'center' });

  doc.setFontSize(11);
  doc.setTextColor(15, 23, 42); // slate-900
  doc.text('DIGITAL MANDI QUALITY INSPECTION CERTIFICATE', pageWidth / 2, margin + 17, {
    align: 'center',
  });

  doc.setFontSize(8.5);
  doc.setTextColor(100, 116, 139); // slate-500
  doc.text(
    `${AppConfig.sihProblemCode} • APMC Electronic Quality Verification • e-NAM Standard`,
    pageWidth / 2,
    margin + 23,
    { align: 'center' }
  );

  let y = margin + 34;

  // Metadata Box (Certificate No, Token, Date, Inspector)
  doc.setFillColor(248, 250, 252); // slate-50
  doc.setDrawColor(226, 232, 240); // slate-200
  doc.setLineWidth(0.3);
  doc.roundedRect(margin + 4, y, pageWidth - margin * 2 - 8, 20, 2, 2, 'FD');

  doc.setFontSize(7.5);
  doc.setTextColor(100, 116, 139);
  doc.text('CERTIFICATE NO', margin + 7, y + 6);
  doc.text('VERIFICATION TOKEN', margin + 50, y + 6);
  doc.text('INSPECTION DATE', margin + 105, y + 6);
  doc.text('AUTHORIZED INSPECTOR', margin + 145, y + 6);

  doc.setFontSize(9);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(15, 23, 42);
  doc.text(inspection.id, margin + 7, y + 13);
  doc.setTextColor(124, 45, 18);
  doc.text(inspection.verificationToken, margin + 50, y + 13);
  doc.setTextColor(15, 23, 42);
  doc.text(new Date(inspection.timestamp).toLocaleDateString(), margin + 105, y + 13);
  doc.text(`${inspection.inspectorName} (${inspection.inspectorId})`, margin + 145, y + 13);

  y += 26;

  // Section 1: Lot Registration Particulars
  doc.setFont('helvetica', 'bold');
  doc.setFontSize(9.5);
  doc.setTextColor(71, 85, 105);
  doc.text('LOT REGISTRATION & MANDI YARD PARTICULARS', margin + 4, y);
  doc.setDrawColor(226, 232, 240);
  doc.line(margin + 4, y + 1.5, pageWidth - margin - 4, y + 1.5);

  y += 6;
  const colW = (pageWidth - margin * 2 - 8) / 3;

  const lotFields = [
    { label: 'Batch Number', value: batch.batchNumber },
    { label: 'Farmer / Lot Owner', value: `${batch.farmerName} ${batch.farmerPhone ? `(${batch.farmerPhone})` : ''}` },
    { label: 'APMC Mandi Yard', value: batch.mandiLocation },
    { label: 'Onion Variety', value: batch.onionVariety },
    { label: 'Total Lot Weight', value: `${batch.weightQuintals} Quintals (${batch.bagCount} bags)` },
    { label: 'Sample Tested Weight', value: `${inspection.sampleWeightKg} kg` },
  ];

  doc.setFontSize(7.5);
  lotFields.forEach((field, i) => {
    const col = i % 3;
    const row = Math.floor(i / 3);
    const posX = margin + 4 + col * colW;
    const posY = y + row * 12;

    doc.setFont('helvetica', 'normal');
    doc.setTextColor(100, 116, 139);
    doc.text(field.label, posX, posY);

    doc.setFont('helvetica', 'bold');
    doc.setTextColor(15, 23, 42);
    doc.text(field.value, posX, posY + 5);
  });

  y += 28;

  // Section 2: Quality Grade & AI Inference Box
  doc.setFont('helvetica', 'bold');
  doc.setFontSize(9.5);
  doc.setTextColor(71, 85, 105);
  doc.text('OFFICIAL MANDI QUALITY GRADE & LOT DISTRIBUTION', margin + 4, y);
  doc.line(margin + 4, y + 1.5, pageWidth - margin - 4, y + 1.5);

  y += 5;

  const isGradeA = inspection.assignedGrade === 'Grade A';
  const isGradeB = inspection.assignedGrade === 'Grade B';

  doc.setFillColor(isGradeA ? 240 : isGradeB ? 254 : 254, isGradeA ? 253 : isGradeB ? 249 : 242, isGradeA ? 244 : isGradeB ? 195 : 242);
  doc.setDrawColor(isGradeA ? 22 : isGradeB ? 202 : 220, isGradeA ? 163 : isGradeB ? 138 : 38, isGradeA ? 74 : isGradeB ? 4 : 38);
  doc.roundedRect(margin + 4, y, pageWidth - margin * 2 - 8, 30, 2, 2, 'FD');

  // Grade badge stamp
  doc.setFillColor(isGradeA ? 220 : isGradeB ? 254 : 254, isGradeA ? 252 : isGradeB ? 240 : 226, isGradeA ? 231 : isGradeB ? 138 : 226);
  doc.roundedRect(margin + 8, y + 4, 34, 22, 2, 2, 'FD');

  doc.setFont('helvetica', 'bold');
  doc.setFontSize(12);
  doc.setTextColor(isGradeA ? 22 : isGradeB ? 161 : 185, isGradeA ? 101 : isGradeB ? 98 : 28, isGradeA ? 52 : isGradeB ? 7 : 28);
  doc.text(inspection.assignedGrade.toUpperCase(), margin + 25, y + 16, { align: 'center' });

  // Grade details
  doc.setFontSize(11);
  doc.setTextColor(15, 23, 42);
  const gradeTitle = isGradeA
    ? 'Grade A - Premium Quality (Export Suitable)'
    : isGradeB
    ? 'Grade B - Fair Average Quality (Domestic Market)'
    : 'Reject - Non-Marketable (Excessive Sprout / Rot)';
  doc.text(gradeTitle, margin + 46, y + 11);

  doc.setFont('helvetica', 'normal');
  doc.setFontSize(8);
  doc.setTextColor(71, 85, 105);
  doc.text(
    `AI Confidence: ${Math.round(inspection.analysis.overallConfidence * 100)}%   |   Bulbs Analyzed: ${inspection.analysis.visibleOnionCount}`,
    margin + 46,
    y + 17
  );

  // Grade breakdown on the right
  doc.setFont('helvetica', 'bold');
  doc.setFontSize(8.5);
  doc.setTextColor(22, 101, 52);
  doc.text(`Grade A: ${inspection.analysis.grades.gradeAPercent}%`, pageWidth - margin - 8, y + 10, { align: 'right' });
  doc.setTextColor(161, 98, 7);
  doc.text(`Grade B: ${inspection.analysis.grades.gradeBPercent}%`, pageWidth - margin - 8, y + 16, { align: 'right' });
  doc.setTextColor(185, 28, 28);
  doc.text(`Reject: ${inspection.analysis.grades.rejectPercent}%`, pageWidth - margin - 8, y + 22, { align: 'right' });

  y += 36;

  // Section 3: Defect Counts Grid
  doc.setFont('helvetica', 'bold');
  doc.setFontSize(9.5);
  doc.setTextColor(71, 85, 105);
  doc.text('DETECTED DEFECT CLASSIFICATION COUNTS', margin + 4, y);
  doc.line(margin + 4, y + 1.5, pageWidth - margin - 4, y + 1.5);

  y += 5;

  const defectBoxes = [
    { label: 'Healthy', count: inspection.analysis.defects.healthy, color: [22, 101, 52], bg: [240, 253, 244] },
    { label: 'Damaged', count: inspection.analysis.defects.damaged, color: [194, 65, 12], bg: [255, 247, 237] },
    { label: 'Rotten', count: inspection.analysis.defects.rotten, color: [185, 28, 28], bg: [254, 242, 242] },
    { label: 'Sprouted', count: inspection.analysis.defects.sprouted, color: [161, 98, 7], bg: [254, 252, 232] },
    { label: 'Undersized', count: inspection.analysis.defects.undersized, color: [126, 34, 206], bg: [250, 245, 255] },
    { label: 'Total Scanned', count: inspection.analysis.defects.total, color: [15, 23, 42], bg: [241, 245, 249] },
  ];

  const dBoxW = (pageWidth - margin * 2 - 8 - 10) / 6;
  defectBoxes.forEach((item, i) => {
    const bX = margin + 4 + i * (dBoxW + 2);
    doc.setFillColor(item.bg[0], item.bg[1], item.bg[2]);
    doc.setDrawColor(203, 213, 225);
    doc.roundedRect(bX, y, dBoxW, 16, 1.5, 1.5, 'FD');

    doc.setFont('helvetica', 'normal');
    doc.setFontSize(6.5);
    doc.setTextColor(item.color[0], item.color[1], item.color[2]);
    doc.text(item.label, bX + dBoxW / 2, y + 5.5, { align: 'center' });

    doc.setFont('helvetica', 'bold');
    doc.setFontSize(10);
    doc.text(String(item.count), bX + dBoxW / 2, y + 12.5, { align: 'center' });
  });

  y += 22;

  // Section 4: Estimation Boundary Note
  doc.setFillColor(254, 252, 232); // yellow-50
  doc.setDrawColor(253, 224, 71); // yellow-300
  doc.roundedRect(margin + 4, y, pageWidth - margin * 2 - 8, 16, 1.5, 1.5, 'FD');

  doc.setFont('helvetica', 'bold');
  doc.setFontSize(7.5);
  doc.setTextColor(113, 63, 18); // yellow-900
  doc.text('ESTIMATION BOUNDARY DISCLAIMER:', margin + 7, y + 5);

  doc.setFont('helvetica', 'normal');
  doc.setFontSize(7);
  const splitDisclaimer = doc.splitTextToSize(
    inspection.analysis.disclaimer ||
      'This certificate provides statistical quality estimation based on computer vision analysis of the visible surface layer of the onion heap. Internal core breakdown or hidden sub-surface defects require secondary cross-sectional sample verification.',
    pageWidth - margin * 2 - 16
  );
  doc.text(splitDisclaimer, margin + 7, y + 9);

  y += 21;

  // Section 5: Verification & Signature Footer
  doc.setDrawColor(71, 85, 105);
  doc.setLineWidth(0.5);
  doc.line(margin + 4, y, pageWidth - margin - 4, y);

  y += 6;

  // Verification Portal text
  doc.setFont('helvetica', 'bold');
  doc.setFontSize(8.5);
  doc.setTextColor(15, 23, 42);
  doc.text('TAMPER-PROOF DIGITAL VERIFICATION', margin + 6, y + 3);

  doc.setFont('helvetica', 'normal');
  doc.setFontSize(7.5);
  doc.setTextColor(100, 116, 139);
  doc.text('Verify integrity online on APMC e-NAM Mandi portal using verification hash:', margin + 6, y + 8);

  doc.setFont('helvetica', 'bold');
  doc.setFontSize(8.5);
  doc.setTextColor(124, 45, 18);
  doc.text(inspection.verificationToken, margin + 6, y + 14);

  // Inspector Signature Block on right
  doc.setFont('helvetica', 'bold');
  doc.setFontSize(9);
  doc.setTextColor(15, 23, 42);
  doc.text(inspection.inspectorName, pageWidth - margin - 6, y + 3, { align: 'right' });

  doc.setFont('helvetica', 'normal');
  doc.setFontSize(7.5);
  doc.setTextColor(100, 116, 139);
  doc.text(`Authorized Mandi Quality Grader (${inspection.inspectorId})`, pageWidth - margin - 6, y + 8, {
    align: 'right',
  });

  doc.setFontSize(6.5);
  doc.text(`Signed: ${new Date(inspection.timestamp).toISOString()}`, pageWidth - margin - 6, y + 13, {
    align: 'right',
  });

  // Save the document
  doc.save(filename);
}
