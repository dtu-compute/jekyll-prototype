FROM ruby:2.5.3

EXPOSE 8080 4000

RUN apt -y update

RUN gem install bundler

RUN apt -y install curl

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

RUN apt -y install gcc g++ make

RUN apt -y install nodejs

RUN apt -y install haskell-platform

# RUN cabal update
# RUN cabal install --force-reinstalls cabal-install
# RUN cabal install pandoc
# RUN cabal install pandoc-smart

# This version is ancient
RUN apt -y install pandoc

RUN curl -L https://github.com/jgm/pandoc/releases/download/2.7.3/pandoc-2.7.3-1-amd64.deb -o pandoc-2.7.3-1-amd64.deb
RUN dpkg -i pandoc-2.7.3-1-amd64.deb

RUN apt -y install texlive-latex-extra

# for pushd
RUN apt -y install bash

RUN mkdir -p /jekyll-prototype/course_website
RUN mkdir -p /jekyll-prototype/contents
RUN mkdir -p /jekyll-prototype/translator
RUN mkdir -p /jekyll-prototype/codemirror
WORKDIR /jekyll-prototype

ADD ./course_website /jekyll-prototype/course_website/
ADD ./translator /jekyll-prototype/translator/

RUN cd course_website && \
    bundle update --bundler && \
    bundle install

RUN cd course_website && \
    npm install && \
    npm run build

RUN cd translator && \
    bundle update --bundler && \
    bundle install

RUN cd translator && \
    npm install

ADD ./codemirror /jekyll-prototype/codemirror/

RUN cp translator/dtu-enote-asciidoctor-extensions.js /jekyll-prototype/codemirror/src/components

RUN cd codemirror && \
    npm install && \
    npm run build

ADD ./content /jekyll-prototype/content
ADD ./tests/ /jekyll-prototype/tests/

ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN DTU_ENOTE_VOL=$(pwd) ./translator/translate.sh 01005

ADD ./run-server.sh /jekyll-prototype/run-server.sh

CMD ["/bin/bash", "-l", "-c", "/jekyll-prototype/run-server.sh"]
