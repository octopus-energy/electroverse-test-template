FROM python:3.12.6-bookworm

WORKDIR /usr/src/app

RUN adduser --system appuser

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y \
    gcc gdal-bin gnupg libpq-dev netcat-openbsd wget && \
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y postgresql-client-15

RUN mkdir staticfiles
RUN chown -R appuser staticfiles

COPY --chown=appuser:nogroup requirements.txt .
RUN pip install -r requirements.txt

COPY --chown=appuser:nogroup entrypoint.sh .
COPY --chown=appuser:nogroup manage.py .
COPY --chown=appuser:nogroup ./src .

RUN chmod 775 entrypoint.sh
CMD /entrypoint.sh

USER appuser