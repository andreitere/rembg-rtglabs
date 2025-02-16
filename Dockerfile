# Example derived from:
# https://github.com/GoogleContainerTools/distroless/blob/main/examples/python3-requirements/Dockerfile
#
# Build a virtualenv using the appropriate Debian release
# * Install python3-venv for the built-in Python3 venv module (not installed by default)
# * Install gcc libpython3-dev to compile C Python modules
# * Update pip to support bdist_wheel
FROM python:3.11-slim AS build
RUN apt-get update && \
    apt-get install --no-install-suggests --no-install-recommends --yes python3-venv gcc libpython3-dev && \
    python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip

# Build the virtualenv as a separate step: Only re-execute this step when requirements.txt changes
FROM build AS build-venv
COPY requirements.txt /requirements.txt
RUN /venv/bin/pip install --disable-pip-version-check -r /requirements.txt

# Copy the virtualenv into a distroless image
FROM python:3.11-slim
COPY --from=build-venv /venv /venv
COPY . /app
WORKDIR /app
EXPOSE 5000
ENTRYPOINT ["/venv/bin/gunicorn", "-b", "0.0.0.0:5000", "wsgi:app"]