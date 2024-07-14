# --------------------------- stage 1 -----------------
FROM python:3.11 AS backend-build

WORKDIR /app

COPY ./backend /app

RUN pip install --no-cache-dir -r requirements.txt

RUN rm requirements.txt
# --------------------------- end stage 1 -----------------
# --------------------------- stage 2 -----------------

FROM python:3.11

WORKDIR /app

# Copy the installed dependencies from the previous stage
COPY --from=backend-build /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Copy the application source code from the previous stage
COPY --from=backend-build /app /app

# Expose port 5000
EXPOSE 5000

CMD ["python","app.py"]
