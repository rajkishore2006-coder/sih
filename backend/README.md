# OnionSure AI Heap Analysis Backend

FastAPI service for SIH26031: Smart Onion Batch Quality Estimation from Heap Images.

## Architecture

- **Instance Segmentation**: Detects visible individual onions within overlapping heap piles with polygon contour masks and bounding boxes.
- **Defect Classifier**: Classifies each detected onion into `Healthy`, `Damaged`, `Rotten`, `Sprouted`, `Undersized`, or `Unknown`.
- **Digital Grading Engine**: Calculates visible sample distributions: `Grade A %`, `Grade B %`, and `Reject %` according to AGMARK/Mandi criteria.
- **Annotated Overlay**: Generates color-coded polygon masks and defect labels.
- **Heap Surface Disclaimer**: Accompanying warning clarifying that estimation derives from surface onions visible to the camera.

## Run Backend

```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

## Endpoints

- `GET /health` - API and model status
- `GET /api/model-info` - Architecture details and supported defect classes
- `POST /api/analyze-heap` - Upload multipart image (`file`) for instant segmentation, defect analysis, and grade percentages

## Connect with Flutter App

Run Flutter with:
```bash
flutter run --dart-define=HEAP_ANALYSIS_API_URL=http://localhost:8000/api/analyze-heap
```
Or toggle mock/live mode directly inside the app settings!
