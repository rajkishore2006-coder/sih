import React, { useState } from 'react';
import { OnionBatch, OnionInspection } from '../types';
import { ShieldCheck, Search, CheckCircle2, AlertCircle, ArrowRight, Download, Check } from 'lucide-react';
import { generateNativeVectorPdf } from '../utils/certificateGenerator';

interface VerifyScreenProps {
  batches: OnionBatch[];
  inspections: OnionInspection[];
  onViewReport: (batch: OnionBatch, inspection: OnionInspection) => void;
  onBack: () => void;
}

export const VerifyScreen: React.FC<VerifyScreenProps> = ({
  batches,
  inspections,
  onViewReport,
}) => {
  const [tokenQuery, setTokenQuery] = useState(
    () => (inspections.length > 0 ? inspections[0].verificationToken : '')
  );
  const [searched, setSearched] = useState(false);
  const [downloaded, setDownloaded] = useState(false);
  const [foundRecord, setFoundRecord] = useState<{
    batch: OnionBatch;
    inspection: OnionInspection;
  } | null>(null);

  const handleDownloadVerifiedPdf = () => {
    if (!foundRecord) return;
    const filename = `OnionSure_Verified_Certificate_${foundRecord.inspection.id}_${foundRecord.batch.batchNumber}.pdf`;
    generateNativeVectorPdf(foundRecord.batch, foundRecord.inspection, filename);
    setDownloaded(true);
    setTimeout(() => setDownloaded(false), 3000);
  };

  const handleSearch = () => {
    const clean = tokenQuery.trim().toLowerCase();
    setSearched(true);
    if (!clean) {
      setFoundRecord(null);
      return;
    }

    const insp = inspections.find(
      (i) =>
        i.verificationToken.toLowerCase() === clean ||
        i.id.toLowerCase() === clean ||
        i.batchNumber.toLowerCase() === clean
    );

    if (insp) {
      const b = batches.find((item) => item.id === insp.batchId || item.batchNumber === insp.batchNumber);
      if (b) {
        setFoundRecord({ batch: b, inspection: insp });
        return;
      }
    }

    setFoundRecord(null);
  };

  return (
    <div className="max-w-2xl mx-auto space-y-5">
      <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-xs space-y-4">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-indigo-50 text-indigo-700 flex items-center justify-center shrink-0">
            <ShieldCheck className="w-6 h-6" />
          </div>
          <div>
            <h2 className="text-base font-bold text-slate-900">
              e-NAM Certificate Authenticity Verification
            </h2>
            <p className="text-xs text-slate-500">
              Verify digital AGMARK grading certificates issued to mandi onion lots
            </p>
          </div>
        </div>

        <div className="space-y-2">
          <label className="block text-xs font-semibold text-slate-700">
            Enter Verification Token or Batch Number:
          </label>
          <div className="flex gap-2">
            <div className="relative flex-1">
              <input
                type="text"
                value={tokenQuery}
                onChange={(e) => {
                  setTokenQuery(e.target.value);
                  setSearched(false);
                }}
                onKeyDown={(e) => e.key === 'Enter' && handleSearch()}
                placeholder="e.g. VERIF-NSK-8921-A or BATCH-2026-NSK-104"
                className="w-full text-xs pl-9 pr-3 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-[#7C2D12] focus:outline-none font-mono"
              />
              <Search className="w-4 h-4 text-slate-400 absolute left-3 top-3 pointer-events-none" />
            </div>
            <button
              type="button"
              onClick={handleSearch}
              className="px-4 py-2.5 bg-[#7C2D12] text-white text-xs font-bold rounded-lg hover:bg-[#68250e] transition-colors shrink-0"
            >
              Verify Record
            </button>
          </div>
        </div>

        {/* Quick Test Tokens */}
        <div>
          <span className="text-[11px] font-semibold text-slate-400 block mb-1.5">
            Active Mandi Certified Tokens:
          </span>
          <div className="flex flex-wrap gap-1.5">
            {inspections.map((i) => (
              <button
                key={i.id}
                type="button"
                onClick={() => {
                  setTokenQuery(i.verificationToken);
                  setSearched(false);
                }}
                className="text-[11px] font-mono px-2 py-1 rounded bg-slate-100 hover:bg-slate-200 text-slate-700 border border-slate-200"
              >
                {i.verificationToken}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Search Result */}
      {searched && (
        <div>
          {foundRecord ? (
            <div className="bg-white rounded-xl border-2 border-emerald-500/50 p-5 shadow-sm space-y-4 animate-in fade-in">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2 text-emerald-800 font-bold text-sm">
                  <CheckCircle2 className="w-5 h-5 text-emerald-600" />
                  <span>Valid & Cryptographically Verified Lot Certificate</span>
                </div>
                <span className="text-xs px-2.5 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-bold">
                  {foundRecord.inspection.assignedGrade}
                </span>
              </div>

              <div className="grid grid-cols-2 gap-3 text-xs bg-slate-50 p-3 rounded-lg border border-slate-200">
                <div>
                  <span className="text-slate-400 block text-[10px] uppercase font-bold">
                    Batch Number:
                  </span>
                  <span className="font-bold text-slate-900">
                    {foundRecord.batch.batchNumber}
                  </span>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px] uppercase font-bold">
                    Farmer / Lot Owner:
                  </span>
                  <span className="font-semibold text-slate-800">
                    {foundRecord.batch.farmerName}
                  </span>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px] uppercase font-bold">
                    APMC Mandi:
                  </span>
                  <span className="font-medium text-slate-800">
                    {foundRecord.batch.mandiLocation}
                  </span>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px] uppercase font-bold">
                    Authorized Inspector:
                  </span>
                  <span className="font-medium text-slate-800">
                    {foundRecord.inspection.inspectorName} (
                    {foundRecord.inspection.inspectorId})
                  </span>
                </div>
              </div>

              <div className="flex flex-col sm:flex-row gap-2">
                <button
                  type="button"
                  onClick={handleDownloadVerifiedPdf}
                  className="flex-1 py-2.5 px-4 rounded-lg bg-[#7C2D12] text-white text-xs font-bold hover:bg-[#68250e] flex items-center justify-center gap-1.5 transition-colors shadow-xs cursor-pointer"
                  title="Directly download certified PDF verification report"
                >
                  {downloaded ? (
                    <>
                      <Check className="w-4 h-4 text-emerald-300" />
                      <span>Downloaded PDF!</span>
                    </>
                  ) : (
                    <>
                      <Download className="w-4 h-4" />
                      <span>Download Certificate PDF</span>
                    </>
                  )}
                </button>

                <button
                  type="button"
                  onClick={() =>
                    onViewReport(foundRecord.batch, foundRecord.inspection)
                  }
                  className="flex-1 py-2.5 px-4 rounded-lg border border-slate-300 text-slate-700 text-xs font-bold hover:bg-slate-50 flex items-center justify-center gap-1.5 transition-colors cursor-pointer"
                >
                  <span>View Official Certificate</span>
                  <ArrowRight className="w-4 h-4" />
                </button>
              </div>
            </div>
          ) : (
            <div className="bg-white rounded-xl border border-red-200 p-6 text-center space-y-1">
              <AlertCircle className="w-7 h-7 text-red-500 mx-auto mb-1" />
              <div className="text-xs font-bold text-slate-800">
                No Certified Record Found
              </div>
              <p className="text-[11px] text-slate-500">
                Token "{tokenQuery}" does not match any authenticated mandi inspection record.
              </p>
            </div>
          )}
        </div>
      )}
    </div>
  );
};
