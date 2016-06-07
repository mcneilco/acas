FROM mcneilco/tomcat-maven
WORKDIR /src
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN		mkdir -p $CATALINA_HOME/webapps/cmpdreg/client
ADD		. $CATALINA_HOME/webapps/cmpdreg/client