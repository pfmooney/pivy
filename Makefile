all: piv-tool piv-agent

_ED25519_SOURCES=		\
	ed25519.c		\
	fe25519.c		\
	ge25519.c		\
	sc25519.c		\
	hash.c			\
	blocks.c
ED25519_SOURCES=$(_ED25519_SOURCES:%=ed25519/%)

_CHAPOLY_SOURCES=		\
	chacha.c		\
	poly1305.c
CHAPOLY_SOURCES=$(_CHAPOLY_SOURCES:%=chapoly/%)

_LIBSSH_SOURCES=		\
	sshbuf.c		\
	sshkey.c		\
	ssh-ed25519.c		\
	ssh-ecdsa.c		\
	ssh-rsa.c		\
	cipher.c		\
	digest-openssl.c	\
	bcrypt-pbkdf.c		\
	blowfish.c		\
	rsa.c			\
	base64.c		\
	atomicio.c		\
	authfd.c
LIBSSH_SOURCES=				\
	$(_LIBSSH_SOURCES:%=libssh/%)	\
	$(ED25519_SOURCES)		\
	$(CHAPOLY_SOURCES)

PIVTOOL_SOURCES=		\
	pivtool.c		\
	tlv.c			\
	piv.c			\
	debug.c			\
	bunyan.c		\
	$(LIBSSH_SOURCES)
PIVTOOL_HEADERS=		\
	tlv.h			\
	piv.h			\
	bunyan.h		\
	debug.h
PIVTOOL_OBJS=		$(PIVTOOL_SOURCES:%.c=%.o)
PIVTOOL_CFLAGS=		-I/usr/include/PCSC \
			-I/usr/include/openssl-1.0 \
			-fstack-protector-all \
			-O2 -g
PIVTOOL_LDFLAGS=	-m64
PIVTOOL_LIBS=		-L/usr/lib/openssl-1.0 \
			-lcrypto -lpcsclite -lbsd

piv-tool :		CFLAGS=		$(PIVTOOL_CFLAGS)
piv-tool :		LIBS+=		$(PIVTOOL_LIBS)
piv-tool :		LDFLAGS+=	$(PIVTOOL_LDFLAGS)
piv-tool :		HEADERS=	$(PIVTOOL_HEADERS)

piv-tool: $(PIVTOOL_OBJS)
	$(CC) $(LDFLAGS) -o $@ $(PIVTOOL_OBJS) $(LIBS)

AGENT_SOURCES=			\
	agent.c			\
	tlv.c			\
	piv.c			\
	debug.c			\
	bunyan.c		\
	$(LIBSSH_SOURCES)
AGENT_HEADERS=		\
	tlv.h			\
	piv.h			\
	bunyan.h		\
	debug.h
AGENT_OBJS=		$(AGENT_SOURCES:%.c=%.o)
AGENT_CFLAGS=		-I/usr/include/PCSC \
			-I/usr/include/openssl-1.0 \
			-fstack-protector-all \
			-O2 -g
AGENT_LDFLAGS=		-m64
AGENT_LIBS=		-L/usr/lib/openssl-1.0 \
			-lcrypto -lpcsclite -lbsd

piv-agent :		CFLAGS=		$(AGENT_CFLAGS)
piv-agent :		LIBS+=		$(AGENT_LIBS)
piv-agent :		LDFLAGS+=	$(AGENT_LDFLAGS)
piv-agent :		HEADERS=	$(AGENT_HEADERS)

piv-agent: $(AGENT_OBJS)
	$(CC) $(LDFLAGS) -o $@ $(AGENT_OBJS) $(LIBS)

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -o $@ -c $<

clean:
	rm -f piv-tool $(PIVTOOL_OBJS)
	rm -f piv-agent $(AGENT_OBJS)