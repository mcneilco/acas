FROM mcneilco/tomcat-maven
WORKDIR /src
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN		mkdir -p $CATALINA_HOME/webapps/cmpdreg/client/custom
ADD		. $CATALINA_HOME/webapps/cmpdreg/client/custom
RUN		cp $CATALINA_HOME/webapps/cmpdreg/client/custom/marvin4js-license.cxl $CATALINA_HOME/webapps/ROOT/
RUN		mkdir -p /root/.chemaxon
RUN		cp $CATALINA_HOME/webapps/cmpdreg/client/custom/licenses/license.cxl /root/.chemaxon/license.cxl
