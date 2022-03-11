FROM deltaio/delta-sharing-server:0.4.0

RUN chmod -R +w /opt/docker/bin && sed -i -E 's#(^declare -r app_classpath=\")(.*)#\1\$lib_dir/../ssl/fake-gcs-server-cert.jar:\2#g' /opt/docker/bin/delta-sharing-server