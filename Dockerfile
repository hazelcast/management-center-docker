FROM openjdk:8-jre
ENV MC_VERSION 3.8.4
ENV MC_HOME /opt/hazelcast/mancenter
ENV MANCENTER_DATA /data
VOLUME ["/data"]

RUN mkdir -p $MC_HOME
WORKDIR $MC_HOME

ADD http://download.hazelcast.com/management-center/management-center-$MC_VERSION.zip $MC_HOME/mancenter.zip
RUN unzip mancenter.zip
WORKDIR $MC_HOME/mancenter
### Start Management Center standalone server.
COPY start.sh .
RUN chmod a+x start.sh
CMD ["/bin/sh", "-c", "./start.sh"]
EXPOSE 8080
