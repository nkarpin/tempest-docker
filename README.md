# tempest-docker
Tempest docker container

To run test we can add argument in run docker image
We shude include root with keystonercv3 and testrailenv (creds to testrail)

    docker run -it -v /root/:/home/tests ee236fc69889 --regex designate_tempest_plugin.tests.api
    
or you can add param from "ENV" end override it

    docker run -it -v /root/:/home/tests -e TESTRAIL_ON=true ee236fc69889 --regex smoke
    
tempest verify-config don't work it (designate don't include as service)
https://github.com/openstack/tempest/blob/master/tempest/cmd/verify_tempest_config.py#L343

Need to run using tox testr and other methods
