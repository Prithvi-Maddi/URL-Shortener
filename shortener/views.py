from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.shortcuts import get_object_or_404, redirect

from .models import ShortURL
from .serializers import ShortURLSerializer
from .utils import generate_unique_short_code
# Create your views here.

class ShortenURLView(APIView):
    def post(self, request):
        original_url = request.data.get("original_url")
        if not original_url:
            return Response({"error": "Missing URL"}, status=400)
        short_code = generate_unique_short_code()
        short_url = ShortURL.objects.create(original_url=original_url, short_code=short_code)
        return Response({
            "short_code": short_code,
            "short_url": request.build_absolute_uri(f"/{short_code}")
        }, status=201)

class RedirectView(APIView):
    def get(self, request, short_code):
        url = get_object_or_404(ShortURL, short_code=short_code)
        url.redirect_count += 1
        url.save()
        return redirect(url.original_url)

class AnalyticsView(APIView):
    def get(self, request, short_code):
        url = get_object_or_404(ShortURL, short_code=short_code)
        serializer = ShortURLSerializer(url)
        return Response(serializer.data)

