FROM perl:5.42

COPY . /usr/src/nozaki
WORKDIR /usr/src/nozaki

RUN cpanm --installdeps .

ENTRYPOINT [ "perl", "./nozaki.pl" ]