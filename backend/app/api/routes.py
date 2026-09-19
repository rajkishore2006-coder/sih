from fastapi import APIRouter, File, UploadFile, HTTPException, status
from backend.app.schemas.analysis import HeapAnalysisResponse, HealthResponse
from backend.app.services.analysis_service import HeapAnalysisService
from backend.app.config import settings

router = APIRouter()
analysis_service = HeapAnalysisService()

ALLOWED_MIME_TYPES = ["image/jpeg", "image/png", "image/webp", "image/jpg"]

@router.get("/health", response_model=HealthResponse)
async def health_check():
    return HealthResponse(
        status="ok",
        version=settings.app_version,
        is_prototype=settings.is_prototype,
        model_loaded=bool(settings.model_weights_path),
    )

@router.get("/api/model-info")
async def model_info():
    return {
        "architecture": "OnionInstanceSeg + QualityClassifier",
        "is_prototype": settings.is_prototype,
        "weights_configured": bool(settings.model_weights_path),
        "sam2_refinement_active": settings.enable_sam2_refinement,
        "classes": ["Healthy", "Damaged", "Rotten", "Sprouted", "Undersized", "Unknown"],
        "grades": ["Grade A", "Grade B", "Reject"],
        "standard": "AGMARK Mandi Onion Grading Standards (SIH26031)",
    }

@router.post("/api/analyze-heap", response_model=HeapAnalysisResponse)
async def analyze_heap(file: UploadFile = File(...)):
    if file.content_type and file.content_type.lower() not in ALLOWED_MIME_TYPES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unsupported image type: {file.content_type}. Please upload JPEG, PNG, or WebP.",
        )

    content = await file.read()
    if len(content) == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Uploaded file is empty.",
        )

    max_bytes = settings.max_upload_size_mb * 1024 * 1024
    if len(content) > max_bytes:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"Image size exceeds limit of {settings.max_upload_size_mb}MB.",
        )

    try:
        result = analysis_service.analyze_heap_image(content, filename=file.filename or "heap.jpg")
        return result
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process onion heap image: {str(exc)}",
        )
