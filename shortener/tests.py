from django.test import TestCase
from rest_framework.test import APITestCase
from rest_framework import status
from .models import ShortURL
from .utils import generate_unique_short_code


class ShortCodeGenerationTests(TestCase):
    def test_code_has_correct_length(self):
        code = generate_unique_short_code(length=8)
        self.assertEqual(len(code), 8)

    def test_code_is_unique(self):
        code1 = generate_unique_short_code()
        code2 = generate_unique_short_code()
        self.assertNotEqual(code1, code2)


class ShortenEndpointTests(APITestCase):
    def test_valid_url_shortening(self):
        response = self.client.post('/shorten',
            {'original_url': 'https://example.com'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('short_code', response.data)
        self.assertIn('short_url', response.data)

    def test_missing_url(self):
        response = self.client.post('/shorten', {}, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('error', response.data)

    def test_malformed_url(self):
        response = self.client.post('/shorten',
            {'original_url': 'badurl'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)  
        # Note: URLField won't reject by default


class RedirectTests(APITestCase):
    def setUp(self):
        self.url_obj = ShortURL.objects.create(
            original_url='https://google.com',
            short_code='test123'
        )

    def test_redirect_to_original_url(self):
        response = self.client.get('/test123')
        self.assertEqual(response.status_code, 302)
        self.assertEqual(response.url, 'https://google.com')

    def test_redirect_increments_count(self):
        self.client.get('/test123')
        self.url_obj.refresh_from_db()
        self.assertEqual(self.url_obj.redirect_count, 1)

    def test_redirect_invalid_code(self):
        response = self.client.get('/nope')
        self.assertEqual(response.status_code, 404)


class AnalyticsTests(APITestCase):
    def setUp(self):
        self.url_obj = ShortURL.objects.create(
            original_url='https://github.com',
            short_code='stats01'
        )

    def test_get_analytics(self):
        response = self.client.get('/analytics/stats01')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['original_url'], 'https://github.com')
        self.assertEqual(response.data['redirect_count'], 0)

    def test_analytics_invalid_code(self):
        response = self.client.get('/analytics/unknown')
        self.assertEqual(response.status_code, 404)
