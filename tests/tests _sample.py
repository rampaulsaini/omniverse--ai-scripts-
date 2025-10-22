from src.sample_script import generate_pdf
from pathlib import Path

def test_pdf_creation():
    output_path = "docs/test.pdf"
    generate_pdf(output_path)
    assert Path(output_path).exists()
  
