# VERSION 1.10-dev
# AUTHOR: Matthieu "Puckel_" Roisil
# AUTHOR: Cristòfol Torrens
# DESCRIPTION: Basic Airflow container
# BUILD: docker build --rm -t piffall/docker-airflow .
# SOURCE: https://github.com/piffall/docker-airflow

FROM ubuntu:16.04
MAINTAINER Cristòfol Torrens "piffall@gmail.com"

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_BRANCH="@master"
ARG AIRFLOW_HOME=/usr/local/airflow

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

RUN apt-get update -y \
    && apt-get install -y apt-utils \
    && apt-get upgrade -y \
    && apt-get install -y \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        libblas-dev \
        liblapack-dev \
        libpq-dev \
        libmysqlclient-dev \
        libsasl2-dev \
        libldap2-dev \
        libffi-dev \
        libssl-dev \
        python-dev \
        build-essential \
        apt-utils \
        git \
        libkrb5-dev \
        python-pip \
        python-requests \
        apt-utils \
        curl \
        rsync \
        netcat \
        locales \
        python-mysqldb \
        software-properties-common \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow

RUN add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update -y \
    && apt-get install -y \
        python3.6 \
        python3.6-dev

RUN pip install -U pip setuptools wheel --upgrade

RUN pip install -U pip setuptools wheel --upgrade \
    && pip install virtualenv \
    && pip install Cython \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install pyasn1-modules \
    && pip install pycrypto \
    && pip install git+https://github.com/piffall/incubator-airflow${AIRFLOW_BRANCH}#egg=apache-airflow[all] \
    && pip install kubernetes \
    && pip install google-api-python-client \
    && pip install celery[redis]==4.0.2 \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

COPY script/entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

RUN chown -R airflow: ${AIRFLOW_HOME}

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/entrypoint.sh"]
