from django.urls import path
from .views import ShortenURLView, RedirectView, AnalyticsView

urlpatterns = [
    path("shorten", ShortenURLView.as_view(), name="shorten"),
    path("<str:short_code>", RedirectView.as_view(), name="redirect"),
    path("analytics/<str:short_code>", AnalyticsView.as_view(), name="analytics"),
]
