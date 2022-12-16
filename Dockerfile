FROM perl:5.34

COPY . /usr/src/nozaki
WORKDIR /usr/src/nozaki

RUN cpanm --installdeps .

ENTRYPOINT [ "perl", "./nozaki.pl" ]