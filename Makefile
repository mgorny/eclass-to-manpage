AWK = gawk
INSTALL = install
SCRIPT = eclass-to-manpage.awk

ECLASSDIR = .
ECLASSES = $(sort $(wildcard ${ECLASSDIR}/*.eclass))

OUTDIR = .
MANPAGES = $(sort $(patsubst ${ECLASSDIR}/%,${OUTDIR}/%.5,${ECLASSES}))
ERRFILES = $(sort $(patsubst ${ECLASSDIR}/%,${OUTDIR}/%.5.err,${ECLASSES}))

DESTDIR =
PREFIX = /usr/local
MANDIR = $(PREFIX)/share/man
MAN5DIR = $(MANDIR)/man5
DATADIR = $(PREFIX)/share/eclass-manpages

DISTNAME = eclass-manpages-$(shell date "+%Y%m%d")
DISTARCH = ${DISTNAME}.tar.xz
DISTFILES = COPYING Makefile eclass-to-manpage.awk
TAR = tar --format=ustar --numeric-owner --owner 0 --group 0 --sort=name
TAR_X = tar -x -J
COMP = xz -9e

${OUTDIR}/%.5: ${ECLASSDIR}/%
	rm -f $@ $@.tmp
	${AWK} -f ${SCRIPT} $< > $@.tmp 2> $@.err || [ $$? -eq 77 ]
	chmod a-w $@.tmp
	mv $@.tmp $@

all: ${MANPAGES}
	[ -z "${ERRFILES}" ] || cat ${ERRFILES}

install: all
	${INSTALL} -d -m 0755 ${DESTDIR}${MAN5DIR}
	for f in ${MANPAGES}; do \
		! [ -s "$${f}" ] || ${INSTALL} -m 0644 $${f} ${DESTDIR}${MAN5DIR}/; \
	done
	${INSTALL} -d -m 0755 ${DESTDIR}${DATADIR}
	${INSTALL} -m 0644 ${SCRIPT} ${DESTDIR}${DATADIR}/

clean:
	rm -f ${MANPAGES} ${ERRFILES}

dist:
	rm -r -f ${DISTNAME} ${DISTARCH}
	${INSTALL} -d -m 0755 ${DISTNAME}
	${INSTALL} -t ${DISTNAME} -m 0644 ${DISTFILES} ${ECLASSES}
	${TAR} -c ${DISTNAME} | ${COMP} -c > ${DISTARCH}
	rm -r -f ${DISTNAME}

distcheck: dist
	${TAR_X} -f ${DISTARCH}
	+${MAKE} -C ${DISTNAME}
	rm -r -f ${DISTNAME}

.PHONY: all install clean dist distcheck
