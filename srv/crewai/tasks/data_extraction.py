"""
Data extraction task for food intelligence
"""

from crewai import Task

def create_extraction_task(agent, raw_data: str):
    """Create data extraction task"""
    return Task(
        description=f"""Extract structured intelligence from this raw data:

{raw_data}

Requirements:
1. Identify company names and contact information
2. Extract product/ingredient details (names, certifications, origins)
3. Note pricing information if available
4. Classify urgency using Fibonacci scale (1, 2, 3, 5, 8)
5. Calculate confidence scores for each extraction

Output must be valid JSON with fields:
{{
    "companies": [{{name, contact, confidence}}],
    "products": [{{name, type, certifications, confidence}}],
    "pricing": [{{product, amount, currency, confidence}}],
    "urgency_fibonacci": <1-8>,
    "extraction_confidence": <0-1>
}}""",
        agent=agent,
        expected_output="Structured JSON with extracted intelligence and confidence scores"
    )
