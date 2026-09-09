# Schlankes Basis-Image. Die Version ist festgeschrieben,
# damit derselbe Build morgen dasselbe Ergebnis liefert.
FROM python:3.12-slim

WORKDIR /app
COPY main.py .

# Kein root im Container. Kostet eine Zeile und faellt in jedem
# Image-Scan positiv auf.
RUN useradd --create-home appuser
USER appuser

CMD ["python", "main.py"]