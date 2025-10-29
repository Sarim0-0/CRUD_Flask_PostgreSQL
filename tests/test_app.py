import os
import sys
import pytest

# Adjust path before importing app
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app import app


def test_home():
    tester = app.test_client()
    response = tester.get('/')
    assert response.status_code == 200
