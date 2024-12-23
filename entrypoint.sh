if [ "$DATABASE" = "postgres" ]
then
    echo "Waiting for postgres..."

    while ! nc -z $SQL_HOST $SQL_PORT; do
      sleep 0.1
    done

    echo "PostgreSQL started"
fi

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting development webserver..."
python manage.py runserver 0.0.0.0:8000