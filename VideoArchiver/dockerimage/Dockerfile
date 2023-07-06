FROM python:3.11-alpine3.18 as build

#WORKDIR /APP

COPY yt-dlp /usr/local/bin

RUN apk --no-cache add ffmpeg \
    && mkdir /vids # should be one line
    
# RUN apk --no-cache add \
#     binutils \
#     curl \
#     && GLIBC_VER=$(curl -s https://api.github.com/repos/sgerrand/alpine-pkg-glibc/releases/latest | grep tag_name | cut -d : -f 2,3 | tr -d \",' ') \
#     && curl -sL https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
#     && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
#     && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
#     && apk add --no-cache \
#     glibc-${GLIBC_VER}.apk \
#     glibc-bin-${GLIBC_VER}.apk \
#     && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
#     && unzip awscliv2.zip \
#     && aws/install \
#     && rm -rf \
#     awscliv2.zip \
#     aws \
#     /usr/local/aws-cli/v2/*/dist/aws_completer \
#     /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
#     /usr/local/aws-cli/v2/*/dist/awscli/examples \
#     && apk --no-cache del \
#     binutils \
#     curl \
#     && rm glibc-${GLIBC_VER}.apk \
#     && rm glibc-bin-${GLIBC_VER}.apk \
#     && rm -rf /var/cache/apk/*

# RUN awsv2 --version   # Just to make sure its installed alright

# RUN mkdir efs \
#     && mount -t efs -o tls,iam file-system-id efs-mount-point/  ## Try to mount the pointlol
    
ENTRYPOINT yt-dlp -P /vids --no-playlist $VIDEO_URL
#CMD yt-dlp -P /vids --no-playlist