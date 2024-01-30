from django.test import Client
import pytest


@pytest.fixture
def api_client() -> Client:
    return Client()
