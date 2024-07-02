FROM maven as stage0
COPY --chown=1001:0 . app
WORKDIR app
RUN mvn clean install

FROM icr.io/appcafe/websphere-liberty:kernel-java17-openj9-ubi as stage1

# Copy application and config files
COPY --chown=1001:0 --from=stage0  daytrader-ee7/target/daytrader-ee7.ear /config/apps
COPY --chown=1001:0 --from=stage0  daytrader-ee7/src/main/liberty/config/server_db2_container.xml /config/server.xml
COPY --chown=1001:0 --from=stage0  jvm.container.options /config/

# Copy DB2 client jar files
COPY --chown=1001:0 db2jars /opt/ibm/wlp/usr/shared/resources/db2jars

# This script will add the requested XML snippets, grow image to be fit-for-purpose and apply interim fixes
RUN configure.sh
