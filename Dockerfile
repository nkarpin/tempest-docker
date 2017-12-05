FROM ubuntu:16.04
MAINTAINER Oksana Voshchana anascko@gmail.com

WORKDIR /tmp
USER root

RUN apt-get update
RUN apt-get install -y git python-setuptools curl
RUN easy_install pip

# Install dependencies
RUN apt-get install -y libxml2-dev libxslt-dev lib32z1-dev
RUN apt-get install -y python2.7-dev python-dev libssl-dev
RUN apt-get install -y python-libxml2 libxslt1-dev libsasl2-dev python-virtualenv
RUN apt-get install -y libsqlite3-dev libldap2-dev libffi-dev git
RUN pip install python-openstackclient
RUN mkdir /home/tempest
ADD run-tempest.sh /home/tempest
RUN chmod +x /home/tempest/run-tempest.sh; cp /home/tempest/run-tempest.sh /usr/bin/run-tests

WORKDIR /home/tempest
RUN git clone --branch 1.1.3 https://github.com/openstack/python-tempestconf.git; cd python-tempestconf \
#    && virtualenv .venv \
#    && /bin/bash -c "source .venv/bin/activate" \
    && pip install -U pip python-subunit && pip install -U setuptools  \
    && pip install -e . && pip install requests \
    && pip install -r requirements.txt 

RUN git clone https://github.com/openstack/tempest.git && cd tempest \
#    && virtualenv .venv \
#    && /bin/bash -c "source .venv/bin/activate" \
    && pip install -U pip python-subunit \
    && pip install -U setuptools && pip install -e . \ 
    && pip install -r test-requirements.txt && testr init \ 
    && pip install ipdb

WORKDIR /home/tempest/tempest
#RUN /bin/bash -c "source .venv/bin/activate" \

# Can adds cinder-tempest-plugin  but now tempest has some issue with it
RUN  for i in designate-tempest-plugin magnum-tempest-plugin neutron-tempest-plugin manila-tempest-plugin \
       keystone-tempest-plugin murano-tempest-plugin heat-tempest-plugin tempest-horizon \
       ironic-tempest-plugin octavia-tempest-plugin barbican-tempest-plugin; do \
       git clone https://github.com/openstack/"$i" && pip install -e ./"$i" && pip install -r ./"$i"/test-requirements.txt; done

RUN pip install 'tox!=2.8.0'

RUN pip install junitxml \
    && pip install xunit2testrail

ENV SOURCE_FILE keystonercv3
ENV TESTRAIL_ENV testrailenv
ENV TESTRAIL_ON true

ENTRYPOINT ["run-tests"]
