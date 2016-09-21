FROM zilman/gunicorn
MAINTAINER Eugene Zilman <ezilman@gmail.com>

RUN pip install meinheld falcon

COPY app.py /

EXPOSE 8000
CMD ["app:app"]
