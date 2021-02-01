FROM obiba/opal

COPY omop_test_resource sophia_resource test_cnsim.json cnsim1.csv cnsim2.csv /opt/opal/data
COPY first_run_sophia.sh /opt/opal/bin
RUN echo  "/opt/opal/bin/first_run_sophia.sh" >> /opt/opal/bin/first_run.sh
RUN echo  "mv /opt/opal/bin/first_run_sophia.sh /opt/opal/bin/first_run_sophia.sh.done"  >> /opt/opal/bin/first_run.sh





