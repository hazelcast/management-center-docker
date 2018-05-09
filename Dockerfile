FROM openjdk:8u141-jre

ENV MC_VERSION 3.10
ENV MC_HOME /opt/hazelcast/mancenter
ENV MANCENTER_DATA /data
ENV USER_NAME=hazelcast
ENV USER_UID=10001

# Prepare Management Center
RUN mkdir -p $MC_HOME
RUN mkdir -p $MANCENTER_DATA
WORKDIR $MC_HOME
ADD http://download.hazelcast.com/management-center/hazelcast-management-center-$MC_VERSION.zip $MC_HOME/mancenter.zip
RUN unzip mancenter.zip
COPY start.sh .
RUN chmod a+x start.sh

### Configure user
RUN useradd -l -u $USER_UID -r -g 0 -d $MC_HOME -s /sbin/nologin -c "${USER_UID} application user" $USER_NAME
RUN chown -R $USER_UID:0 $MC_HOME $MANCENTER_DATA
RUN chmod +x $MC_HOME/*.sh
USER $USER_UID

VOLUME ["/data"]
EXPOSE 8080

CMD ["/bin/sh", "-c", "./start.sh"]
