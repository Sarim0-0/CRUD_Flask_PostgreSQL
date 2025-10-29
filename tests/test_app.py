# flake8: noqa: E402
import os
import sys

# Add parent directory to path so app.py can be imported
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app import app


def test_home():
    tester = app.test_client()
    response = tester.get('/')
    assert response.status_code == 200
