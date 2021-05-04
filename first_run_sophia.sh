#!/bin/bash

opal project -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD --add --name test --database postgresdb
opal project -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD --add --name sophia --database postgresdb
opal project -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD --add --name omop_test --database postgresdb
opal rest /datashield/package/dsBase/methods --opal https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method PUT
opal perm-datashield --opal https://localhost:8443 --user administrator --password $OPAL_ADMINISTRATOR_PASSWORD --type USER --subject guest --permission use --add
opal rest -o https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method POST "/service/r/packages?manager=gh&name=sib-swiss/dsSwissKnife&ref=master"
opal rest -o https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method POST "/service/r/packages?manager=gh&name=sib-swiss/resourcex&ref=master"
opal rest -o https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method POST "/service/r/packages?name=DSI"
opal rest -o https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method POST "/service/r/packages?name=tensorflow"
opal rest -o https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method POST "/service/r/packages?manager=gh&name=vanduttran/dsSSCP&ref=master"
opal rest -o https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method POST "/service/r/packages?manager=gh&name=vanduttran/dsSSCPclient&ref=master"
opal rest -o https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method POST "/service/r/packages?manager=gh&name=sib-swiss/dsQueryLibraryServer&ref=main"
opal rest /datashield/package/dsSwissKnife/methods --opal https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method PUT
opal rest /datashield/package/dsSSCP/methods --opal https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method PUT
opal rest /datashield/package/dsSSCPclient/methods --opal https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method PUT
opal rest /datashield/package/resourcex/methods --opal https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method PUT
opal rest /datashield/package/dsQueryLibraryServer/methods --opal https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method PUT
sed s/@host@/$POSTGRESDATA_HOST/g /opt/opal/data/omop_test_resource | \
      sed s/@user@/$POSTGRESDATA_USER/g | \
      sed s/@password@/$POSTGRESDATA_PASSWORD/g | \
opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /project/omop_test/resources --content-type "application/json"

sed s/@host@/$POSTGRESDATA_HOST/g /opt/opal/data/sophia_resource | \
      sed s/@user@/$POSTGRESDATA_USER/g | \
      sed s/@password@/$POSTGRESDATA_PASSWORD/g | \
opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /project/sophia/resources --content-type "application/json"

opal user --opal https://localhost:8443 --user administrator --password $OPAL_ADMINISTRATOR_PASSWORD  --add --name guest --upassword guest123
if [[ -v CNSIM_FILE ]]; then
    opal file -up /opt/opal/data/$CNSIM_FILE /home/administrator -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD  -v
    cat /opt/opal/data/test_cnsim.json | opal rest -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /datasource/test/tables --content-type "application/json" -v
    opal import-csv --o https://localhost:8443 --u administrator --password $OPAL_ADMINISTRATOR_PASSWORD --destination test --path /home/administrator/$CNSIM_FILE --tables CNSIM --type CNSIM
    opal perm-table --o https://localhost:8443 --u administrator --password $OPAL_ADMINISTRATOR_PASSWORD --type USER --project test --subject guest  --permission view --add --tables CNSIM
fi
opal rest -o https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method POST "/project/omop_test/permissions/resources?type=USER&permission=RESOURCES_VIEW&principal=guest"

# TODO:
#openssl  req -newkey rsa:2048 -new -nodes -x509 -subj "/C=/ST=/L=/O=/CN="  -days 3650 -keyout key.pem -out cert.pem

#cat /srv/cert.pem >> certificate.json

#cat /opt/opal/data/certificate.json | opal rest -o https://opal_server2:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -m POST /system/subject-credentials --content-type "application/json" -v
#
