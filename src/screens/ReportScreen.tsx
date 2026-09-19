import React, { useState } from 'react';
import { OnionBatch, OnionInspection } from '../types';
import { QRCodeSVG } from 'qrcode.react';
import {
  Printer,
  ShieldCheck,
  Award,
  ArrowLeft,
  CheckCircle,
  Download,
  FileImage,
  Loader2,
  FileText,
  AlertCircle,
} from 'lucide-react';
import { AppConfig } from '../config/appConfig';
import {
  downloadCertificatePdf,
  downloadCertificatePng,
  generateNativeVectorPdf,
} from '../utils/certificateGenerator';

interface ReportScreenProps {
  batch: OnionBatch;
  inspection: OnionInspection;
  onBack: () => void;
  onGoHome: () => void;
}

export const ReportScreen: React.FC<ReportScreenProps> = ({
  batch,
  inspection,
  onBack,
  onGoHome,
}) => {
  const [downloadingFormat, setDownloadingFormat] = useState<'pdf' | 'png' | 'vector-pdf' | null>(null);
  const [statusMessage, setStatusMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  const CERTIFICATE_ELEMENT_ID = 'onionsure-certificate-node';

  const handleDownloadPdf = async () => {
    try {
      setDownloadingFormat('pdf');
      setStatusMessage(null);
      await downloadCertificatePdf(CERTIFICATE_ELEMENT_ID, batch, inspection);
      setStatusMessage({
        type: 'success',
        text: 'Certificate downloaded successfully as PDF.',
      });
      setTimeout(() => setStatusMessage(null), 4000);
    } catch (err) {
      console.error('Error downloading PDF:', err);
      // Seamlessly fallback to direct vector PDF
      try {
        generateNativeVectorPdf(
          batch,
          inspection,
          `OnionSure_Certificate_${inspection.id}_${batch.batchNumber}.pdf`
        );
        setStatusMessage({
          type: 'success',
          text: 'Generated and downloaded high-clarity vector PDF certificate.',
        });
        setTimeout(() => setStatusMessage(null), 4000);
      } catch (fallbackErr) {
        setStatusMessage({
          type: 'error',
          text: 'Could not generate PDF. Please try the PNG download or direct Print option.',
        });
      }
    } finally {
      setDownloadingFormat(null);
    }
  };

  const handleDownloadPng = async () => {
    try {
      setDownloadingFormat('png');
      setStatusMessage(null);
      await downloadCertificatePng(CERTIFICATE_ELEMENT_ID, batch, inspection);
      setStatusMessage({
        type: 'success',
        text: 'Certificate image downloaded successfully (PNG).',
      });
      setTimeout(() => setStatusMessage(null), 4000);
    } catch (err) {
      console.error('Error downloading PNG:', err);
      setStatusMessage({
        type: 'error',
        text: 'Failed to generate PNG image. Please try downloading as PDF.',
      });
    } finally {
      setDownloadingFormat(null);
    }
  };

  const handleDownloadVectorPdf = () => {
    try {
      setDownloadingFormat('vector-pdf');
      setStatusMessage(null);
      generateNativeVectorPdf(
        batch,
        inspection,
        `OnionSure_Certificate_${inspection.id}_${batch.batchNumber}_Vector.pdf`
      );
      setStatusMessage({
        type: 'success',
        text: 'Downloaded official vector PDF certificate.',
      });
      setTimeout(() => setStatusMessage(null), 4000);
    } catch (err) {
      console.error('Error generating vector PDF:', err);
      setStatusMessage({
        type: 'error',
        text: 'Failed to generate vector PDF.',
      });
    } finally {
      setDownloadingFormat(null);
    }
  };

  const handlePrint = () => {
    try {
      window.print();
    } catch (e) {
      console.warn('Window print failed, falling back to PDF download:', e);
      handleDownloadPdf();
    }
  };

  const isGradeA = inspection.assignedGrade === 'Grade A';
  const isGradeB = inspection.assignedGrade === 'Grade B';

  const gradeColor = isGradeA
    ? 'text-emerald-700 border-emerald-600 bg-emerald-50'
    : isGradeB
    ? 'text-amber-700 border-amber-600 bg-amber-50'
    : 'text-red-700 border-red-600 bg-red-50';

  return (
    <div className="max-w-3xl mx-auto space-y-4">
      {/* Action Toolbar (Hidden in Print) */}
      <div className="no-print bg-white rounded-xl border border-slate-200 p-3 sm:p-4 shadow-xs">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div className="flex items-center gap-2">
            <button
              onClick={onBack}
              className="text-xs font-semibold text-slate-600 hover:text-slate-900 flex items-center gap-1.5 px-3 py-2 rounded-lg hover:bg-slate-100 transition-colors"
            >
              <ArrowLeft className="w-4 h-4" />
              <span>Back</span>
            </button>
            <button
              onClick={onGoHome}
              className="text-xs font-semibold text-slate-600 hover:text-slate-900 px-3 py-2 rounded-lg hover:bg-slate-100 transition-colors"
            >
              Dashboard
            </button>
          </div>

          {/* Download & Export Action Group */}
          <div className="flex flex-wrap items-center gap-2">
            {/* Download PDF Primary */}
            <button
              type="button"
              id="download-pdf-btn"
              disabled={downloadingFormat !== null}
              onClick={handleDownloadPdf}
              className="px-3.5 py-2 rounded-lg bg-[#7C2D12] text-white text-xs font-bold hover:bg-[#68250e] shadow-xs flex items-center gap-1.5 transition-colors disabled:opacity-50 cursor-pointer"
              title="Download formatted A4 PDF Certificate directly to your device"
            >
              {downloadingFormat === 'pdf' ? (
                <Loader2 className="w-4 h-4 animate-spin" />
              ) : (
                <Download className="w-4 h-4" />
              )}
              <span>{downloadingFormat === 'pdf' ? 'Generating PDF...' : 'Download PDF'}</span>
            </button>

            {/* Download PNG Image */}
            <button
              type="button"
              id="download-png-btn"
              disabled={downloadingFormat !== null}
              onClick={handleDownloadPng}
              className="px-3 py-2 rounded-lg border border-slate-300 bg-white text-slate-700 text-xs font-bold hover:bg-slate-50 shadow-2xs flex items-center gap-1.5 transition-colors disabled:opacity-50 cursor-pointer"
              title="Download certificate as high-resolution PNG image"
            >
              {downloadingFormat === 'png' ? (
                <Loader2 className="w-4 h-4 animate-spin" />
              ) : (
                <FileImage className="w-4 h-4 text-slate-600" />
              )}
              <span>{downloadingFormat === 'png' ? 'Saving Image...' : 'Download PNG'}</span>
            </button>

            {/* Direct Vector PDF */}
            <button
              type="button"
              id="download-vector-pdf-btn"
              disabled={downloadingFormat !== null}
              onClick={handleDownloadVectorPdf}
              className="hidden sm:flex px-2.5 py-2 rounded-lg border border-slate-200 text-slate-600 hover:text-slate-900 text-xs font-semibold hover:bg-slate-50 items-center gap-1.5 transition-colors"
              title="Download vector PDF (guaranteed zero-latency offline generation)"
            >
              <FileText className="w-3.5 h-3.5" />
              <span>Vector PDF</span>
            </button>

            {/* Print / Save */}
            <button
              type="button"
              id="print-certificate-btn"
              onClick={handlePrint}
              className="px-3 py-2 rounded-lg border border-slate-300 text-slate-600 hover:text-slate-900 text-xs font-medium hover:bg-slate-50 flex items-center gap-1.5 transition-colors cursor-pointer"
              title="Open browser print dialog"
            >
              <Printer className="w-4 h-4" />
              <span className="hidden sm:inline">Print</span>
            </button>
          </div>
        </div>

        {/* Feedback Status Toast */}
        {statusMessage && (
          <div
            className={`mt-3 p-2.5 rounded-lg text-xs font-medium flex items-center gap-2 ${
              statusMessage.type === 'success'
                ? 'bg-emerald-50 text-emerald-800 border border-emerald-200'
                : 'bg-red-50 text-red-800 border border-red-200'
            }`}
          >
            {statusMessage.type === 'success' ? (
              <CheckCircle className="w-4 h-4 text-emerald-600 shrink-0" />
            ) : (
              <AlertCircle className="w-4 h-4 text-red-600 shrink-0" />
            )}
            <span>{statusMessage.text}</span>
          </div>
        )}
      </div>

      {/* Official Certificate Card */}
      <div
        id={CERTIFICATE_ELEMENT_ID}
        className="bg-white border-2 border-slate-300 rounded-2xl p-6 sm:p-8 shadow-sm relative overflow-hidden text-slate-900"
      >
        {/* Certificate Decorative Border Header */}
        <div className="border-b-2 border-slate-800 pb-4 mb-6 text-center relative">
          <div className="flex items-center justify-center gap-2 text-[#7C2D12] mb-1">
            <ShieldCheck className="w-7 h-7" />
            <span className="text-xl sm:text-2xl font-black tracking-wide uppercase">
              {AppConfig.appName}
            </span>
          </div>
          <h1 className="text-base sm:text-lg font-bold tracking-tight text-slate-900 uppercase">
            Digital Mandi Quality Inspection Certificate
          </h1>
          <p className="text-xs text-slate-500 font-mono mt-0.5">
            {AppConfig.sihProblemCode} • APMC Electronic Quality Verification
          </p>

          {/* Verification Badge */}
          <div className="mt-2 inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-50 border border-emerald-300 text-emerald-800 text-[11px] font-bold">
            <CheckCircle className="w-3.5 h-3.5 text-emerald-600" />
            <span>AUTHENTICATED e-NAM READY CERTIFICATE</span>
          </div>
        </div>

        {/* Certificate Meta Details */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 bg-slate-50 p-3.5 rounded-xl border border-slate-200 mb-6 text-xs">
          <div>
            <span className="text-[10px] text-slate-500 uppercase font-bold block">
              Certificate No:
            </span>
            <span className="font-mono font-bold text-slate-900">
              {inspection.id}
            </span>
          </div>
          <div>
            <span className="text-[10px] text-slate-500 uppercase font-bold block">
              Verification Token:
            </span>
            <span className="font-mono font-bold text-[#7C2D12]">
              {inspection.verificationToken}
            </span>
          </div>
          <div>
            <span className="text-[10px] text-slate-500 uppercase font-bold block">
              Inspection Date:
            </span>
            <span className="font-medium text-slate-800">
              {new Date(inspection.timestamp).toLocaleDateString()}
            </span>
          </div>
          <div>
            <span className="text-[10px] text-slate-500 uppercase font-bold block">
              Authorized Inspector:
            </span>
            <span className="font-bold text-slate-800">
              {inspection.inspectorName} ({inspection.inspectorId})
            </span>
          </div>
        </div>

        {/* Batch & Farmer Information */}
        <div className="mb-6">
          <h2 className="text-xs font-bold uppercase tracking-wider text-slate-500 mb-2 border-b border-slate-200 pb-1">
            Lot Registration & Mandi Yard Particulars
          </h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-y-3 gap-x-4 text-xs">
            <div>
              <span className="text-slate-500 block text-[11px]">Batch Number</span>
              <span className="font-bold text-slate-900">{batch.batchNumber}</span>
            </div>
            <div>
              <span className="text-slate-500 block text-[11px]">Farmer / Lot Owner</span>
              <span className="font-semibold text-slate-900">
                {batch.farmerName} {batch.farmerPhone ? `(${batch.farmerPhone})` : ''}
              </span>
            </div>
            <div>
              <span className="text-slate-500 block text-[11px]">APMC Mandi Location</span>
              <span className="font-semibold text-slate-900">{batch.mandiLocation}</span>
            </div>
            <div>
              <span className="text-slate-500 block text-[11px]">Onion Variety</span>
              <span className="font-semibold text-slate-900">{batch.onionVariety}</span>
            </div>
            <div>
              <span className="text-slate-500 block text-[11px]">Total Lot Weight</span>
              <span className="font-bold text-slate-900">
                {batch.weightQuintals} Quintals ({batch.bagCount} bags)
              </span>
            </div>
            <div>
              <span className="text-slate-500 block text-[11px]">Physical Sample Weight</span>
              <span className="font-bold text-slate-900">{inspection.sampleWeightKg} kg</span>
            </div>
          </div>
        </div>

        {/* Quality Grade Stamp & Metrics */}
        <div className="mb-6 p-4 rounded-xl border border-slate-200 bg-white flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <div
              className={`w-20 h-20 rounded-2xl border-2 flex flex-col items-center justify-center p-2 text-center shrink-0 ${gradeColor}`}
            >
              <Award className="w-8 h-8 mb-0.5" />
              <span className="text-xs font-black uppercase tracking-wider">
                {inspection.assignedGrade}
              </span>
            </div>
            <div>
              <div className="text-xs text-slate-500 font-bold uppercase">
                Official Digital Mandi Grade
              </div>
              <div className="text-lg font-black text-slate-900">
                {inspection.assignedGrade === 'Grade A'
                  ? 'Grade A - Premium Quality (Export Suitable)'
                  : inspection.assignedGrade === 'Grade B'
                  ? 'Grade B - Fair Average Quality (Domestic Market)'
                  : 'Reject - Non-Marketable (Excessive Sprout / Rot)'}
              </div>
              <div className="text-xs text-slate-600 mt-1">
                Inference Confidence: {Math.round(inspection.analysis.overallConfidence * 100)}% •
                Surface Bulbs Analyzed: {inspection.analysis.visibleOnionCount}
              </div>
            </div>
          </div>

          <div className="text-center sm:text-right text-xs">
            <div className="text-emerald-700 font-bold">
              Grade A: {inspection.analysis.grades.gradeAPercent}%
            </div>
            <div className="text-amber-700 font-bold">
              Grade B: {inspection.analysis.grades.gradeBPercent}%
            </div>
            <div className="text-red-700 font-bold">
              Reject: {inspection.analysis.grades.rejectPercent}%
            </div>
          </div>
        </div>

        {/* Defect Classification Breakdown Grid */}
        <div className="mb-6">
          <h2 className="text-xs font-bold uppercase tracking-wider text-slate-500 mb-2 border-b border-slate-200 pb-1">
            Detected Defect Classification Counts
          </h2>
          <div className="grid grid-cols-3 sm:grid-cols-6 gap-2 text-center text-xs">
            <div className="p-2.5 rounded-lg bg-emerald-50 border border-emerald-200">
              <span className="text-[11px] text-emerald-800 font-semibold block">Healthy</span>
              <span className="text-base font-extrabold text-emerald-900">
                {inspection.analysis.defects.healthy}
              </span>
            </div>
            <div className="p-2.5 rounded-lg bg-orange-50 border border-orange-200">
              <span className="text-[11px] text-orange-800 font-semibold block">Damaged</span>
              <span className="text-base font-extrabold text-orange-900">
                {inspection.analysis.defects.damaged}
              </span>
            </div>
            <div className="p-2.5 rounded-lg bg-red-50 border border-red-200">
              <span className="text-[11px] text-red-800 font-semibold block">Rotten</span>
              <span className="text-base font-extrabold text-red-900">
                {inspection.analysis.defects.rotten}
              </span>
            </div>
            <div className="p-2.5 rounded-lg bg-yellow-50 border border-yellow-200">
              <span className="text-[11px] text-yellow-800 font-semibold block">Sprouted</span>
              <span className="text-base font-extrabold text-yellow-900">
                {inspection.analysis.defects.sprouted}
              </span>
            </div>
            <div className="p-2.5 rounded-lg bg-purple-50 border border-purple-200">
              <span className="text-[11px] text-purple-800 font-semibold block">Undersized</span>
              <span className="text-base font-extrabold text-purple-900">
                {inspection.analysis.defects.undersized}
              </span>
            </div>
            <div className="p-2.5 rounded-lg bg-slate-100 border border-slate-200">
              <span className="text-[11px] text-slate-700 font-semibold block">Total Scanned</span>
              <span className="text-base font-extrabold text-slate-900">
                {inspection.analysis.defects.total}
              </span>
            </div>
          </div>
        </div>

        {/* Mandatory Estimation Boundary Disclaimer */}
        <div className="mb-6 bg-amber-50/70 border border-amber-300/80 rounded-lg p-3 text-[11px] text-amber-950 leading-relaxed">
          <span className="font-bold">Estimation Boundary Note: </span>
          {inspection.analysis.disclaimer}
        </div>

        {/* Signature & QR Verification Footer */}
        <div className="pt-4 border-t-2 border-slate-800 flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-white rounded-lg border border-slate-300 shadow-2xs shrink-0">
              <QRCodeSVG
                value={`https://onionsure.gov.in/verify?token=${inspection.verificationToken}`}
                size={72}
                level="M"
              />
            </div>
            <div className="text-[11px] text-slate-600">
              <div className="font-bold text-slate-900">Tamper-Proof Digital Verification</div>
              <div>Scan QR or verify token on e-NAM APMC portal:</div>
              <div className="font-mono font-bold text-[#7C2D12]">
                {inspection.verificationToken}
              </div>
            </div>
          </div>

          <div className="text-center sm:text-right text-xs">
            <div className="font-bold text-slate-900">
              {inspection.inspectorName}
            </div>
            <div className="text-[11px] text-slate-500">
              Authorized Mandi Quality Grader ({inspection.inspectorId})
            </div>
            <div className="text-[10px] text-slate-400 mt-1 font-mono">
              Signed: {new Date(inspection.timestamp).toISOString()}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
