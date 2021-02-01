#!/bin/bash

opal project -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD --add --name test --database postgresdb
opal project -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD --add --name sophia --database postgresdb
opal project -o https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD --add --name omop_test --database postgresdb
opal rest /datashield/package/dsBase/methods --opal https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method PUT
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
    opal import-csv --o https://localhost:8443 --u administrator --password $OPAL_ADMINISTRATOR_PASSWORD --destination test --path /home/administrator/$CNSIM_FILE --tables CNSIM --separator , --type CNSIM
    opal perm-table --o https://localhost:8443 --u administrator --password $OPAL_ADMINISTRATOR_PASSWORD --type USER --project test --subject guest  --permission view --add --tables CNSIM
fi
opal perm-datashield --opal https://localhost:8443 --user administrator --password $OPAL_ADMINISTRATOR_PASSWORD --type USER --subject guest --permission use --add
opal rest -o https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method POST "/service/r/packages?manager=gh&name=sib-swiss/dsSwissKnife"
opal rest -o https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method POST "/service/r/packages?manager=gh&name=sib-swiss/resourcex"
opal rest -o https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method POST "/service/r/packages?name=DSI"
opal rest -o https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method POST "/service/r/packages?name=tensorflow"
opal rest -o https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method POST "/service/r/packages?manager=gh&name=vanduttran/dsSSCP"
opal rest -o https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method POST "/service/r/packages?manager=gh&name=vanduttran/dsSSCPclient"
opal rest /datashield/package/dsSwissKnife/methods --opal https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method PUT
opal rest /datashield/package/dsSSCP/methods --opal https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method PUT
opal rest /datashield/package/dsSSCPclient/methods --opal https://localhost:8443 --user administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --method PUT
