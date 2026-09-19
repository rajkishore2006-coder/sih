import React, { useState } from 'react';
import { OnionBatch } from '../types';
import { Info, User, Phone, MapPin, Sprout, Weight, PackageCheck, ArrowRight } from 'lucide-react';

interface CreateBatchScreenProps {
  onSaveBatch: (batch: OnionBatch) => void;
  onCancel: () => void;
}

const MANDI_LOCATIONS = [
  'Lasalgaon APMC, Nashik',
  'Pimpalgaon Baswant APMC',
  'Yeola Mandi Yard',
  'Kalwan APMC Yard',
  'Pune Gultekdi Market Yard',
  'Solapur Onion Market',
];

const ONION_VARIETIES = [
  'Nashik Red (Garva)',
  'Rangda Medium',
  'Pol Early Red',
  'White Onion (Dehydration)',
  'Yellow Spanish Hybrid',
];

export const CreateBatchScreen: React.FC<CreateBatchScreenProps> = ({
  onSaveBatch,
  onCancel,
}) => {
  const [farmerName, setFarmerName] = useState('Dattatray Shinde');
  const [farmerPhone, setFarmerPhone] = useState('+91 98901 23456');
  const [mandiLocation, setMandiLocation] = useState(MANDI_LOCATIONS[0]);
  const [onionVariety, setOnionVariety] = useState(ONION_VARIETIES[0]);
  const [weightQuintals, setWeightQuintals] = useState('95.0');
  const [bagCount, setBagCount] = useState('190');
  const [harvestDate, setHarvestDate] = useState(
    new Date(Date.now() - 3 * 86400000).toISOString().split('T')[0]
  );
  const [error, setError] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!farmerName.trim()) {
      setError('Please enter farmer or lot owner name');
      return;
    }
    const weightNum = parseFloat(weightQuintals);
    const bagNum = parseInt(bagCount, 10);
    if (isNaN(weightNum) || weightNum <= 0) {
      setError('Please enter valid weight in quintals');
      return;
    }
    if (isNaN(bagNum) || bagNum <= 0) {
      setError('Please enter valid bag count');
      return;
    }

    const randomSuffix = Math.floor(100 + Math.random() * 900);
    const mandiCode = mandiLocation.includes('Lasalgaon')
      ? 'NSK'
      : mandiLocation.includes('Pimpalgaon')
      ? 'PMP'
      : 'MND';

    const batchNumber = `BATCH-2026-${mandiCode}-${randomSuffix}`;
    const id = `batch-${Date.now()}`;

    const newBatch: OnionBatch = {
      id,
      batchNumber,
      farmerName: farmerName.trim(),
      farmerPhone: farmerPhone.trim(),
      mandiLocation,
      onionVariety,
      harvestDate: new Date(harvestDate).toISOString(),
      weightQuintals: weightNum,
      bagCount: bagNum,
      status: 'pending',
      createdAt: new Date().toISOString(),
      latestGrade: null,
      qrCodeData: `ONION-BATCH:${batchNumber}`,
    };

    onSaveBatch(newBatch);
  };

  return (
    <div className="max-w-2xl mx-auto space-y-5">
      {/* Informational callout */}
      <div className="bg-[#7C2D12]/5 border border-[#7C2D12]/20 rounded-xl p-4 flex gap-3 text-slate-800">
        <Info className="w-5 h-5 text-[#7C2D12] shrink-0 mt-0.5" />
        <div className="text-xs leading-relaxed">
          <span className="font-bold text-[#7C2D12]">Mandi Digital Traceability: </span>
          Assign a certified digital lot identifier to the incoming onion harvest. A cryptographic QR code payload will be generated for tamper-proof weighing, inspection, and auction grading.
        </div>
      </div>

      <form onSubmit={handleSubmit} className="bg-white rounded-xl border border-slate-200 p-5 space-y-4 shadow-xs">
        <h3 className="text-sm font-bold text-slate-900 border-b border-slate-100 pb-2">
          Farmer & Lot Registration
        </h3>

        {error && (
          <div className="p-3 text-xs text-red-700 bg-red-50 border border-red-200 rounded-lg">
            {error}
          </div>
        )}

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div className="space-y-1">
            <label className="block text-xs font-semibold text-slate-700 flex items-center gap-1.5">
              <User className="w-3.5 h-3.5 text-slate-400" />
              <span>Farmer / Trader Full Name</span>
            </label>
            <input
              type="text"
              required
              value={farmerName}
              onChange={(e) => setFarmerName(e.target.value)}
              placeholder="e.g. Ramesh Patil"
              className="w-full text-xs px-3 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-[#7C2D12] focus:outline-none"
            />
          </div>

          <div className="space-y-1">
            <label className="block text-xs font-semibold text-slate-700 flex items-center gap-1.5">
              <Phone className="w-3.5 h-3.5 text-slate-400" />
              <span>Mobile Number</span>
            </label>
            <input
              type="text"
              value={farmerPhone}
              onChange={(e) => setFarmerPhone(e.target.value)}
              placeholder="+91 98231 00000"
              className="w-full text-xs px-3 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-[#7C2D12] focus:outline-none"
            />
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div className="space-y-1">
            <label className="block text-xs font-semibold text-slate-700 flex items-center gap-1.5">
              <MapPin className="w-3.5 h-3.5 text-slate-400" />
              <span>Mandi APMC Yard</span>
            </label>
            <select
              value={mandiLocation}
              onChange={(e) => setMandiLocation(e.target.value)}
              className="w-full text-xs px-3 py-2.5 border border-slate-300 rounded-lg bg-white focus:ring-2 focus:ring-[#7C2D12] focus:outline-none"
            >
              {MANDI_LOCATIONS.map((loc) => (
                <option key={loc} value={loc}>
                  {loc}
                </option>
              ))}
            </select>
          </div>

          <div className="space-y-1">
            <label className="block text-xs font-semibold text-slate-700 flex items-center gap-1.5">
              <Sprout className="w-3.5 h-3.5 text-slate-400" />
              <span>Onion Variety</span>
            </label>
            <select
              value={onionVariety}
              onChange={(e) => setOnionVariety(e.target.value)}
              className="w-full text-xs px-3 py-2.5 border border-slate-300 rounded-lg bg-white focus:ring-2 focus:ring-[#7C2D12] focus:outline-none"
            >
              {ONION_VARIETIES.map((v) => (
                <option key={v} value={v}>
                  {v}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="space-y-1">
            <label className="block text-xs font-semibold text-slate-700 flex items-center gap-1.5">
              <Weight className="w-3.5 h-3.5 text-slate-400" />
              <span>Weight (Quintals)</span>
            </label>
            <input
              type="number"
              step="0.5"
              required
              value={weightQuintals}
              onChange={(e) => setWeightQuintals(e.target.value)}
              className="w-full text-xs px-3 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-[#7C2D12] focus:outline-none"
            />
          </div>

          <div className="space-y-1">
            <label className="block text-xs font-semibold text-slate-700 flex items-center gap-1.5">
              <PackageCheck className="w-3.5 h-3.5 text-slate-400" />
              <span>Bag Count</span>
            </label>
            <input
              type="number"
              required
              value={bagCount}
              onChange={(e) => setBagCount(e.target.value)}
              className="w-full text-xs px-3 py-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-[#7C2D12] focus:outline-none"
            />
          </div>

          <div className="space-y-1">
            <label className="block text-xs font-semibold text-slate-700">
              Harvest / Curing Date
            </label>
            <input
              type="date"
              value={harvestDate}
              onChange={(e) => setHarvestDate(e.target.value)}
              className="w-full text-xs px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-[#7C2D12] focus:outline-none"
            />
          </div>
        </div>

        <div className="pt-3 flex items-center justify-end gap-2 border-t border-slate-100">
          <button
            type="button"
            onClick={onCancel}
            className="px-4 py-2 text-xs font-semibold text-slate-600 hover:bg-slate-100 rounded-lg transition-colors"
          >
            Cancel
          </button>
          <button
            type="submit"
            className="px-5 py-2.5 text-xs font-bold bg-[#7C2D12] text-white hover:bg-[#68250e] rounded-lg shadow-sm flex items-center gap-2 transition-colors"
          >
            <span>Register & Generate QR</span>
            <ArrowRight className="w-4 h-4" />
          </button>
        </div>
      </form>
    </div>
  );
};
