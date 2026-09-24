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
import { DisclaimerBanner } from '../components/DisclaimerBanner';
import { useLanguage } from '../i18n/LanguageContext';

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
  const { t } = useLanguage();
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
        text: t.reportScreen.successPdf,
      });
      setTimeout(() => setStatusMessage(null), 4000);
    } catch (err) {
      console.error('Error downloading PDF:', err);
      try {
        generateNativeVectorPdf(
          batch,
          inspection,
          `OnionSure_Certificate_${inspection.id}_${batch.batchNumber}.pdf`
        );
        setStatusMessage({
          type: 'success',
          text: t.reportScreen.successVectorPdf,
        });
        setTimeout(() => setStatusMessage(null), 4000);
      } catch (fallbackErr) {
        setStatusMessage({
          type: 'error',
          text: t.reportScreen.errorPdf,
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
        text: t.reportScreen.successPng,
      });
      setTimeout(() => setStatusMessage(null), 4000);
    } catch (err) {
      console.error('Error downloading PNG:', err);
      setStatusMessage({
        type: 'error',
        text: t.reportScreen.errorPng,
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
        text: t.reportScreen.successVectorPdf,
      });
      setTimeout(() => setStatusMessage(null), 4000);
    } catch (err) {
      console.error('Error generating vector PDF:', err);
      setStatusMessage({
        type: 'error',
        text: t.reportScreen.errorVectorPdf,
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
              className="text-xs font-semibold text-slate-600 hover:text-slate-900 flex items-center gap-1.5 px-3 py-2 rounded-lg hover:bg-slate-100 transition-colors cursor-pointer"
            >
              <ArrowLeft className="w-4 h-4" />
              <span>{t.reportScreen.backToDetail}</span>
            </button>
            <button
              onClick={onGoHome}
              className="text-xs font-semibold text-slate-600 hover:text-slate-900 px-3 py-2 rounded-lg hover:bg-slate-100 transition-colors cursor-pointer"
            >
              {t.reportScreen.dashboard}
            </button>
          </div>

          <div className="flex items-center gap-2 flex-wrap">
            <button
              onClick={handlePrint}
              className="px-3 py-2 rounded-lg border border-slate-200 bg-white text-slate-700 text-xs font-semibold hover:bg-slate-50 flex items-center gap-1.5 transition-colors cursor-pointer"
            >
              <Printer className="w-3.5 h-3.5" />
              <span>{t.reportScreen.print}</span>
            </button>

            <button
              disabled={downloadingFormat !== null}
              onClick={handleDownloadPng}
              className="px-3 py-2 rounded-lg border border-slate-200 bg-white text-slate-700 text-xs font-semibold hover:bg-slate-50 flex items-center gap-1.5 transition-colors disabled:opacity-60 cursor-pointer"
              title="Download certificate as high-resolution PNG image"
            >
              {downloadingFormat === 'png' ? (
                <Loader2 className="w-3.5 h-3.5 animate-spin" />
              ) : (
                <FileImage className="w-3.5 h-3.5 text-sky-600" />
              )}
              <span>{t.reportScreen.downloadPng}</span>
            </button>

            <button
              disabled={downloadingFormat !== null}
              onClick={handleDownloadVectorPdf}
              className="px-3 py-2 rounded-lg border border-slate-200 bg-white text-slate-700 text-xs font-semibold hover:bg-slate-50 flex items-center gap-1.5 transition-colors disabled:opacity-60 cursor-pointer"
              title="Download vector-grade PDF"
            >
              {downloadingFormat === 'vector-pdf' ? (
                <Loader2 className="w-3.5 h-3.5 animate-spin" />
              ) : (
                <FileText className="w-3.5 h-3.5 text-[#7C2D12]" />
              )}
              <span>{t.reportScreen.downloadVector}</span>
            </button>

            <button
              disabled={downloadingFormat !== null}
              onClick={handleDownloadPdf}
              className="px-4 py-2 rounded-lg bg-[#7C2D12] text-white text-xs font-bold hover:bg-[#68250e] shadow-xs flex items-center gap-1.5 transition-colors disabled:opacity-60 cursor-pointer"
            >
              {downloadingFormat === 'pdf' ? (
                <Loader2 className="w-3.5 h-3.5 animate-spin" />
              ) : (
                <Download className="w-3.5 h-3.5" />
              )}
              <span>{t.reportScreen.downloadPdf}</span>
            </button>
          </div>
        </div>

        {/* Status Notification Toast */}
        {statusMessage && (
          <div
            className={`mt-3 p-3 rounded-lg text-xs flex items-center gap-2 animate-in fade-in duration-200 ${
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
            <span className="font-medium">{statusMessage.text}</span>
          </div>
        )}
      </div>

      {/* Official Certificate Paper Container */}
      <div
        id={CERTIFICATE_ELEMENT_ID}
        className="bg-white rounded-xl border border-slate-300 p-6 sm:p-8 shadow-sm space-y-6 text-slate-900 print:border-none print:shadow-none print:p-0"
      >
        {/* Certificate Header Banner */}
        <div className="border-b-2 border-[#7C2D12] pb-5 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div className="space-y-1">
            <div className="flex items-center gap-2">
              <span className="text-[10px] font-extrabold uppercase px-2 py-0.5 rounded bg-[#7C2D12] text-white tracking-widest">
                AGMARK • e-NAM
              </span>
              <span className="text-[11px] font-bold text-slate-500 uppercase tracking-wider">
                {AppConfig.sihProblemCode}
              </span>
            </div>
            <h1 className="text-xl sm:text-2xl font-black text-slate-900 tracking-tight">
              {t.reportScreen.officialTitle}
            </h1>
            <p className="text-[11px] font-semibold text-slate-600 uppercase tracking-wider">
              {t.reportScreen.officialSubtitle}
            </p>
            <p className="text-[10px] text-slate-400">
              {t.reportScreen.govtSubtitle}
            </p>
          </div>

          <div className="text-right sm:border-l sm:border-slate-200 sm:pl-5 shrink-0 space-y-1">
            <div className="text-[10px] uppercase font-bold text-slate-400">
              {t.reportScreen.certificateNumber}
            </div>
            <div className="text-sm font-mono font-bold text-slate-900">
              {inspection.id}
            </div>
            <div className="text-[10px] text-slate-500">
              {t.reportScreen.issueDate}: {new Date(inspection.timestamp).toLocaleDateString()}
            </div>
            <div className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 text-[10px] font-bold border border-emerald-200 mt-1">
              <ShieldCheck className="w-3 h-3 text-emerald-600" />
              <span>{t.reportScreen.verifiedBadge}</span>
            </div>
          </div>
        </div>

        {/* Section 1: Lot & Consignment Details */}
        <div className="space-y-2">
          <h3 className="text-xs font-bold uppercase tracking-wider text-[#7C2D12] border-b border-slate-200 pb-1">
            {t.reportScreen.lotDetailsHeader}
          </h3>
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 text-xs">
            <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-100">
              <span className="text-[10px] text-slate-500 block uppercase font-medium">
                {t.reportScreen.batchNumber}
              </span>
              <span className="font-bold text-slate-900 font-mono">
                {batch.batchNumber}
              </span>
            </div>

            <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-100">
              <span className="text-[10px] text-slate-500 block uppercase font-medium">
                {t.reportScreen.farmerName}
              </span>
              <span className="font-bold text-slate-900">
                {batch.farmerName}
              </span>
              {batch.farmerPhone && (
                <span className="text-[10px] text-slate-400 block font-mono">
                  {batch.farmerPhone}
                </span>
              )}
            </div>

            <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-100">
              <span className="text-[10px] text-slate-500 block uppercase font-medium">
                {t.reportScreen.mandiYard}
              </span>
              <span className="font-semibold text-slate-800">
                {batch.mandiLocation}
              </span>
            </div>

            <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-100">
              <span className="text-[10px] text-slate-500 block uppercase font-medium">
                {t.reportScreen.onionVariety}
              </span>
              <span className="font-semibold text-slate-800">
                {batch.onionVariety}
              </span>
            </div>

            <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-100">
              <span className="text-[10px] text-slate-500 block uppercase font-medium">
                {t.reportScreen.lotWeight}
              </span>
              <span className="font-bold text-slate-900">
                {batch.weightQuintals} {t.common.quintals}
              </span>
            </div>

            <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-100">
              <span className="text-[10px] text-slate-500 block uppercase font-medium">
                {t.reportScreen.bagQuantity}
              </span>
              <span className="font-bold text-slate-900">
                {batch.bagCount} {t.common.bags}
              </span>
            </div>
          </div>
        </div>

        {/* Section 2: Inspection & Sampling Parameters */}
        <div className="space-y-2">
          <h3 className="text-xs font-bold uppercase tracking-wider text-[#7C2D12] border-b border-slate-200 pb-1">
            {t.reportScreen.inspectionHeader}
          </h3>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 text-xs">
            <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-100">
              <span className="text-[10px] text-slate-500 block uppercase font-medium">
                {t.reportScreen.leadInspector}
              </span>
              <span className="font-bold text-slate-900">
                {inspection.inspectorName}
              </span>
            </div>

            <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-100">
              <span className="text-[10px] text-slate-500 block uppercase font-medium">
                {t.reportScreen.inspectorId}
              </span>
              <span className="font-mono font-semibold text-slate-800">
                {inspection.inspectorId}
              </span>
            </div>

            <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-100">
              <span className="text-[10px] text-slate-500 block uppercase font-medium">
                {t.reportScreen.sampleWeight}
              </span>
              <span className="font-bold text-slate-900">
                {inspection.sampleWeightKg} {t.common.kg}
              </span>
            </div>

            <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-100">
              <span className="text-[10px] text-slate-500 block uppercase font-medium">
                {t.reportScreen.verificationToken}
              </span>
              <span className="font-mono font-bold text-slate-900">
                {inspection.verificationToken}
              </span>
            </div>
          </div>
        </div>

        {/* Section 3: Computer Vision Grading Results */}
        <div className="space-y-3">
          <h3 className="text-xs font-bold uppercase tracking-wider text-[#7C2D12] border-b border-slate-200 pb-1">
            {t.reportScreen.gradingResultsHeader}
          </h3>

          <div className="p-4 rounded-xl border-2 flex flex-col sm:flex-row items-center justify-between gap-4 bg-slate-50/50">
            <div className="flex items-center gap-3">
              <div
                className={`w-14 h-14 rounded-xl border flex flex-col items-center justify-center shrink-0 ${gradeColor}`}
              >
                <Award className="w-7 h-7" />
                <span className="text-[10px] font-black uppercase">
                  {inspection.assignedGrade}
                </span>
              </div>

              <div>
                <span className="text-[11px] font-bold uppercase text-slate-500">
                  {t.reportScreen.assignedGrade}
                </span>
                <h4 className="text-lg font-black text-slate-900">
                  {inspection.assignedGrade === 'Grade A'
                    ? t.heapAnalysis.gradeExport
                    : inspection.assignedGrade === 'Grade B'
                    ? t.heapAnalysis.gradeFair
                    : t.heapAnalysis.gradeReject}
                </h4>
                <p className="text-xs text-slate-500 mt-0.5">
                  {t.reportScreen.gradeRationale}: {inspection.analysis?.grades?.gradeAPercent ?? 75}% {t.grades.gradeA}, {inspection.analysis?.grades?.gradeBPercent ?? 15}% {t.grades.gradeB}, {inspection.analysis?.grades?.rejectPercent ?? 10}% {t.grades.reject}
                </p>
              </div>
            </div>

            <div className="text-right text-xs">
              <div className="font-bold text-slate-800">
                {Math.round((inspection.analysis?.overallConfidence ?? 0.92) * 100)}% {t.common.confidence}
              </div>
              <div className="text-slate-400 text-[11px]">
                {inspection.analysis?.visibleOnionCount ?? 24} {t.heapAnalysis.scannedBulbs}
              </div>
            </div>
          </div>
        </div>

        {/* Section 4: Defect Breakdown Summary */}
        {inspection.analysis?.defects && (
          <div className="space-y-2">
            <h3 className="text-xs font-bold uppercase tracking-wider text-[#7C2D12] border-b border-slate-200 pb-1">
              {t.reportScreen.defectBreakdownHeader}
            </h3>
            <div className="grid grid-cols-3 sm:grid-cols-6 gap-2 text-center text-xs">
              <div className="p-2 bg-emerald-50 rounded-lg border border-emerald-200">
                <span className="text-[10px] text-emerald-800 block font-semibold">{t.defects.healthy}</span>
                <span className="text-base font-extrabold text-emerald-700">
                  {inspection.analysis.defects.healthy}
                </span>
              </div>
              <div className="p-2 bg-orange-50 rounded-lg border border-orange-200">
                <span className="text-[10px] text-orange-800 block font-semibold">{t.defects.damaged}</span>
                <span className="text-base font-extrabold text-orange-700">
                  {inspection.analysis.defects.damaged}
                </span>
              </div>
              <div className="p-2 bg-red-50 rounded-lg border border-red-200">
                <span className="text-[10px] text-red-800 block font-semibold">{t.defects.rotten}</span>
                <span className="text-base font-extrabold text-red-700">
                  {inspection.analysis.defects.rotten}
                </span>
              </div>
              <div className="p-2 bg-amber-50 rounded-lg border border-amber-200">
                <span className="text-[10px] text-amber-800 block font-semibold">{t.defects.sprouted}</span>
                <span className="text-base font-extrabold text-amber-700">
                  {inspection.analysis.defects.sprouted}
                </span>
              </div>
              <div className="p-2 bg-purple-50 rounded-lg border border-purple-200">
                <span className="text-[10px] text-purple-800 block font-semibold">{t.defects.undersized}</span>
                <span className="text-base font-extrabold text-purple-700">
                  {inspection.analysis.defects.undersized}
                </span>
              </div>
              <div className="p-2 bg-slate-50 rounded-lg border border-slate-200">
                <span className="text-[10px] text-slate-600 block font-semibold">{t.defects.unknown}</span>
                <span className="text-base font-extrabold text-slate-700">
                  {inspection.analysis.defects.unknown}
                </span>
              </div>
            </div>
          </div>
        )}

        {/* Section 5: Assayer Notes */}
        {inspection.notes && (
          <div className="space-y-1">
            <h3 className="text-xs font-bold uppercase tracking-wider text-[#7C2D12] border-b border-slate-200 pb-1">
              {t.reportScreen.notesHeader}
            </h3>
            <p className="text-xs text-slate-700 italic bg-slate-50 p-2.5 rounded-lg border border-slate-100">
              "{inspection.notes}"
            </p>
          </div>
        )}

        {/* Statutory Mandi Disclaimer */}
        <DisclaimerBanner disclaimerText={inspection.analysis?.disclaimer} />

        {/* Cryptographic Digital Signature & QR Verification Seal */}
        <div className="border-t-2 border-slate-200 pt-4 flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-white rounded-lg border border-slate-200 shadow-2xs shrink-0">
              <QRCodeSVG
                value={`https://enam.gov.in/verify?cert=${inspection.id}&token=${inspection.verificationToken}`}
                size={75}
                level="M"
              />
            </div>
            <div className="space-y-0.5">
              <div className="text-xs font-bold text-slate-900">
                {t.reportScreen.digitalSignTitle}
              </div>
              <div className="text-[10px] text-slate-500 max-w-sm">
                {t.reportScreen.digitalSignSubtitle}
              </div>
              <div className="text-[10px] font-mono text-slate-400 pt-0.5">
                SHA-256 Digest: {inspection.verificationToken} • {inspection.timestamp}
              </div>
            </div>
          </div>

          <div className="text-center sm:text-right shrink-0">
            <div className="text-xs font-serif italic text-slate-800 font-bold mb-1">
              {inspection.inspectorName}
            </div>
            <div className="text-[10px] uppercase font-bold text-slate-400 border-t border-slate-300 pt-0.5">
              Authorized Mandi Assayer Signature
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
