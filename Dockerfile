FROM python:3.10.8-alpine

#app directory
WORKDIR /app
#demo user
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN addgroup -g ${GROUP_ID} demo \
 && adduser -D demo -u ${USER_ID} -g demo -G demo -s /bin/sh

#copy files
COPY --chown=demo . /app/

RUN pip install --upgrade pip
RUN pip install --no-build-isolation --no-cache-dir -r requirements.txt

#install depedencies
RUN apk add --no-cache --virtual .build-deps \
        gcc libc-dev make \
        python3-dev py3-pip \
        libffi-dev cython \
    && pip install --upgrade pip setuptools wheel cython \
    && pip install --no-cache-dir -r requirements.txt \
    && apk del .build-deps

USER demo

#entrypoint
CMD ["uvicorn", "app.main:app", "--proxy-headers", "--host", "0.0.0.0", "--port", "8080"]