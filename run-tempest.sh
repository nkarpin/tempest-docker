#!/bin/bash
source /home/tests/$SOURCE_FILE

DS_REPO_PLUGIN=/home/tempest/tempest/designate-tempest-plugin
US_REPO_TEMPEST=/home/tempest/tempest

for i in ${DS_REPO_TEMPEST} ${US_REPO_TEMPEST} ;do
    git checkout master && git pull
done

cd /home/tempest/python-tempestconf
source .venv/bin/activate

python config_tempest/config_tempest.py --debug identity.uri $OS_AUTH_URL \
            identity.admin_password  $OS_PASSWORD --create

sed -i 's/\/dashboard/:8078/' /home/tempest/python-tempestconf/etc/tempest.conf
sed -i 's/ec2_url/#ec2_url/' /home/tempest/python-tempestconf/etc/tempest.conf
#sed -i 's///' /home/tempest/python-tempestconf/etc/tempest.conf
sed -i 's/designate = False/designate = True/' /home/tempest/python-tempestconf/etc/tempest.conf
sed -i '/^.service_available./a\designate = True' /home/tempest/python-tempestconf/etc/tempest.conf

cat <<EOF >> /home/tempest/python-tempestconf/etc/tempest.conf
[dns_feature_enabled]
api_v2_quotas = True
api_v2 = True
api_v1 = False
api_v2_root_recordsets = True
api_admin = False
bug_1573141_fixed = True

[dns]
nameservers = 172.16.10.90:53

[designate]
nameservers = 172.16.10.90:53
EOF

cp /home/tempest/python-tempestconf/etc/tempest.conf /home/tempest/tempest/etc/tempest.conf
export TEMPEST_CONFIG=/home/tempest/tempest/etc/tempest.conf
cd /home/tempest/tempest
#source .venv/bin/activate

#exec tempest run --regex designate_tempest_plugin.tests.api
tempest run "$@"
pip install junitxml
pip install xunit2testrail
testr last --subunit | subunit2junitxml > /home/tests/verification.xml
source /home/tests/$TESTRAIL_ENV

report -v \
--testrail-plan-name "$TESTRAIL_PLAN_NAME" \
--env-description "$TEST_GROUP" \
--testrail-url  "$TESTRAIL_URL" \
--testrail-user "$TESTRAIL_USER" \
--testrail-password "$TESTRAIL_PASSWORD" \
--testrail-project "$TESTRAIL_PROJECT" \
--testrail-milestone "$TESTRAIL_MILESTONE" \
--testrail-suite "$TESTRAIL_SUITE" \
--testrail-name-template '{custom_test_group}.{title}' \
--xunit-name-template '{classname}.{methodname}' /home/tests/verification.xml
