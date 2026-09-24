import React, { useState, useRef } from 'react';
import {
  OnionDetectionItem,
  DefectType,
  DEFECT_DETAILS,
} from '../types';
import { Eye, CheckSquare, Tag, Filter, Info, X } from 'lucide-react';
import { useLanguage } from '../i18n/LanguageContext';

interface SegmentationOverlayProps {
  detections: OnionDetectionItem[];
  imageSrc?: string | null;
  onSelectDetection?: (detection: OnionDetectionItem | null) => void;
  selectedDetection?: OnionDetectionItem | null;
}

export const SegmentationOverlay: React.FC<SegmentationOverlayProps> = ({
  detections,
  imageSrc,
  onSelectDetection,
  selectedDetection: externalSelected,
}) => {
  const { t } = useLanguage();
  const [showPolygons, setShowPolygons] = useState(true);
  const [showBoundingBoxes, setShowBoundingBoxes] = useState(true);
  const [showLabels, setShowLabels] = useState(true);
  const [filterDefect, setFilterDefect] = useState<DefectType | 'All'>('All');
  const [internalSelected, setInternalSelected] = useState<OnionDetectionItem | null>(null);

  const containerRef = useRef<HTMLDivElement>(null);

  const selected = externalSelected !== undefined ? externalSelected : internalSelected;

  const filteredDetections =
    filterDefect === 'All'
      ? detections
      : detections.filter((d) => d.defectType === filterDefect);

  const getDefectName = (type: DefectType): string => {
    switch (type) {
      case 'Healthy':
        return t.defects.healthy;
      case 'Damaged':
        return t.defects.damaged;
      case 'Rotten':
        return t.defects.rotten;
      case 'Sprouted':
        return t.defects.sprouted;
      case 'Undersized':
        return t.defects.undersized;
      default:
        return t.defects.unknown;
    }
  };

  const handleStageClick = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!containerRef.current) return;
    const rect = containerRef.current.getBoundingClientRect();
    const clickX = (e.clientX - rect.left) / rect.width;
    const clickY = (e.clientY - rect.top) / rect.height;

    // Find clicked onion bulb
    const hit = filteredDetections.find(
      (d) =>
        clickX >= d.bbox.xmin &&
        clickX <= d.bbox.xmax &&
        clickY >= d.bbox.ymin &&
        clickY <= d.bbox.ymax
    );

    const newSelected = hit || null;
    setInternalSelected(newSelected);
    onSelectDetection?.(newSelected);
  };

  return (
    <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-xs">
      {/* Controls Bar */}
      <div className="p-3 bg-slate-50 border-b border-slate-200 flex flex-wrap items-center justify-between gap-2">
        <div className="flex flex-wrap items-center gap-1.5">
          <button
            type="button"
            onClick={() => setShowPolygons(!showPolygons)}
            className={`px-2.5 py-1 rounded-md text-xs font-semibold flex items-center gap-1.5 border transition-colors cursor-pointer ${
              showPolygons
                ? 'bg-slate-800 text-white border-slate-800'
                : 'bg-white text-slate-600 border-slate-300 hover:bg-slate-100'
            }`}
          >
            <Eye className="w-3.5 h-3.5" />
            <span>{t.heapAnalysis.polygonsToggle}</span>
          </button>

          <button
            type="button"
            onClick={() => setShowBoundingBoxes(!showBoundingBoxes)}
            className={`px-2.5 py-1 rounded-md text-xs font-semibold flex items-center gap-1.5 border transition-colors cursor-pointer ${
              showBoundingBoxes
                ? 'bg-slate-800 text-white border-slate-800'
                : 'bg-white text-slate-600 border-slate-300 hover:bg-slate-100'
            }`}
          >
            <CheckSquare className="w-3.5 h-3.5" />
            <span>{t.heapAnalysis.boxesToggle}</span>
          </button>

          <button
            type="button"
            onClick={() => setShowLabels(!showLabels)}
            className={`px-2.5 py-1 rounded-md text-xs font-semibold flex items-center gap-1.5 border transition-colors cursor-pointer ${
              showLabels
                ? 'bg-slate-800 text-white border-slate-800'
                : 'bg-white text-slate-600 border-slate-300 hover:bg-slate-100'
            }`}
          >
            <Tag className="w-3.5 h-3.5" />
            <span>{t.heapAnalysis.labelsToggle}</span>
          </button>
        </div>

        {/* Filter Dropdown */}
        <div className="flex items-center gap-1.5">
          <Filter className="w-3.5 h-3.5 text-slate-500" />
          <select
            value={filterDefect}
            onChange={(e) => setFilterDefect(e.target.value as any)}
            className="text-xs bg-white border border-slate-300 rounded-md px-2 py-1 text-slate-700 font-medium focus:outline-none focus:ring-1 focus:ring-slate-800"
          >
            <option value="All">{t.heapAnalysis.filterAllDefects} ({detections.length})</option>
            <option value="Healthy">{t.defects.healthy}</option>
            <option value="Damaged">{t.defects.damaged}</option>
            <option value="Rotten">{t.defects.rotten}</option>
            <option value="Sprouted">{t.defects.sprouted}</option>
            <option value="Undersized">{t.defects.undersized}</option>
          </select>
        </div>
      </div>

      {/* Interactive Overlay Stage */}
      <div
        ref={containerRef}
        onClick={handleStageClick}
        className="relative w-full aspect-[4/3] bg-gradient-to-br from-amber-950/85 via-red-950/90 to-amber-900 cursor-crosshair overflow-hidden select-none"
      >
        {/* Render Background Image or Synthetic Heap Texture */}
        {imageSrc ? (
          <img
            src={imageSrc}
            alt="Onion Heap"
            className="w-full h-full object-cover pointer-events-none"
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center opacity-40">
            <div className="grid grid-cols-6 grid-rows-4 gap-4 w-full h-full p-4 pointer-events-none">
              {Array.from({ length: 24 }).map((_, i) => (
                <div
                  key={i}
                  className="rounded-full bg-radial from-amber-600/40 via-red-800/40 to-amber-950/60 blur-xs"
                />
              ))}
            </div>
          </div>
        )}

        {/* SVG Drawing Layer for Polygons & Boxes */}
        <svg
          viewBox="0 0 1000 1000"
          preserveAspectRatio="none"
          className="absolute inset-0 w-full h-full pointer-events-none"
        >
          {filteredDetections.map((item) => {
            const isSelected = selected?.id === item.id;
            const meta = DEFECT_DETAILS[item.defectType];
            const color = meta ? meta.color : '#CA8A04';

            // Convert polygon coordinates (0..1) to 1000x1000 space
            const polyPoints = item.polygon
              .map((pt) => `${pt.x * 1000},${pt.y * 1000}`)
              .join(' ');

            const bx = item.bbox.xmin * 1000;
            const by = item.bbox.ymin * 1000;
            const bw = (item.bbox.xmax - item.bbox.xmin) * 1000;
            const bh = (item.bbox.ymax - item.bbox.ymin) * 1000;

            const defectLabel = getDefectName(item.defectType);

            return (
              <g key={item.id}>
                {/* Polygon Contour */}
                {showPolygons && polyPoints && (
                  <polygon
                    points={polyPoints}
                    fill={color}
                    fillOpacity={isSelected ? 0.45 : 0.22}
                    stroke={color}
                    strokeWidth={isSelected ? 3.5 : 2}
                    strokeDasharray={isSelected ? '4,2' : undefined}
                  />
                )}

                {/* Bounding Box */}
                {showBoundingBoxes && (
                  <rect
                    x={bx}
                    y={by}
                    width={bw}
                    height={bh}
                    fill="none"
                    stroke={color}
                    strokeWidth={isSelected ? 3 : 1.5}
                    rx="8"
                  />
                )}

                {/* Label Tag */}
                {showLabels && (
                  <g transform={`translate(${bx}, ${Math.max(22, by - 6)})`}>
                    <rect
                      x="0"
                      y="-18"
                      width={Math.max(70, defectLabel.length * 9 + 42)}
                      height="20"
                      fill={color}
                      rx="4"
                    />
                    <text
                      x="6"
                      y="-4"
                      fill="#ffffff"
                      fontSize="11"
                      fontWeight="bold"
                      fontFamily="sans-serif"
                    >
                      #{item.id} {defectLabel} ({Math.round(item.estimatedDiameterMm)}mm)
                    </text>
                  </g>
                )}
              </g>
            );
          })}
        </svg>

        {/* Selected Bulb Focus Highlighter Marker */}
        {selected && (
          <div
            className="absolute border-2 border-white rounded-lg shadow-lg pointer-events-none transition-all"
            style={{
              left: `${selected.bbox.xmin * 100}%`,
              top: `${selected.bbox.ymin * 100}%`,
              width: `${(selected.bbox.xmax - selected.bbox.xmin) * 100}%`,
              height: `${(selected.bbox.ymax - selected.bbox.ymin) * 100}%`,
              boxShadow: '0 0 0 9999px rgba(0, 0, 0, 0.4)',
            }}
          />
        )}
      </div>

      {/* Selected Bulb Details Footer */}
      {selected ? (
        <div className="p-3 bg-slate-900 text-white flex items-center justify-between gap-3 text-xs">
          <div className="flex items-center gap-3 flex-wrap">
            <div
              className="w-3 h-3 rounded-full shrink-0"
              style={{ backgroundColor: DEFECT_DETAILS[selected.defectType]?.color }}
            />
            <div>
              <span className="font-bold text-slate-100">{t.heapAnalysis.bulbDetailHeader} #{selected.id}:</span>{' '}
              <span className="font-semibold text-amber-400">
                {getDefectName(selected.defectType)}
              </span>{' '}
              • {selected.grade} • {t.heapAnalysis.diameterLabel}: {selected.estimatedDiameterMm}mm •{' '}
              {t.common.confidence}: {Math.round(selected.confidence * 100)}%
            </div>
          </div>
          <button
            onClick={() => {
              setInternalSelected(null);
              onSelectDetection?.(null);
            }}
            className="text-slate-400 hover:text-white p-1 rounded hover:bg-slate-800 cursor-pointer"
            title={t.common.close}
          >
            <X className="w-4 h-4" />
          </button>
        </div>
      ) : (
        <div className="px-3 py-2 bg-slate-50 text-slate-500 text-xs flex items-center gap-2">
          <Info className="w-3.5 h-3.5 text-slate-400 shrink-0" />
          <span>{t.heapAnalysis.clickPrompt}</span>
        </div>
      )}
    </div>
  );
};
