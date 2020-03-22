FROM alpine
RUN apk add --update curl yajl-tools
RUN apk add --update jq
ADD crontab.txt /crontab.txt
ADD script.sh /script.sh
COPY entry.sh /entry.sh
RUN chmod 755 /entry.sh /script.sh
RUN /usr/bin/crontab /crontab.txt

CMD ["/entry.sh"]
