# OnionSure - AI-Powered Onion Quality & Digital Grading

A modern React & TypeScript web application rewritten from the SIH26031 Flutter prototype. OnionSure enables AI-powered onion batch quality estimation from heap images, digital grading (Grade A, Grade B, Reject), batch tracking with QR codes, inspection logging, and verifiable PDF-style inspection reports with cryptographic validation.

## Key Features

- **Batch Management**: Create, view, search, and track onion harvest batches with QR identification and storage parameters.
- **Heap AI Quality Inspection**:
  - Upload heap photos or capture sample inspection frames.
  - Interactive bounding box and segmentation overlay with toggleable visible onion detection masks.
  - Automatic digital grading distribution: Grade A, Grade B, and Reject percentages.
  - Defect breakdown (sprouting, rot, mechanical cuts, discoloration).
  - Storage advisories and actionable shelf-life recommendations.
- **Verifiable Digital Reports**:
  - Comprehensive inspection certificates with unique verification hashes.
  - QR codes encode instant verification URLs with deep-link hash validation.
  - Formatted for clean desktop and print-ready PDF reporting.
- **Batch Verification Portal**:
  - Verify inspection integrity by scanning or pasting report verification hashes.
- **Local Persistence & Configurable Backend**:
  - Persists batches and inspection logs in client `localStorage`.
  - Configurable backend endpoint for connecting to the FastAPI `HeapAnalysisService` or running in self-contained realistic demo mode.

## Tech Stack

- **Framework**: React 18 with TypeScript
- **Bundler & Dev Server**: Vite 6
- **Styling**: Tailwind CSS v4
- **Icons**: Lucide React
- **QR Code Generation**: `qrcode.react`

## Development

```bash
# Install dependencies
npm install

# Start development server (port 3000)
npm run dev

# Run type check & linter
npm run lint

# Build production bundle
npm run build
```
