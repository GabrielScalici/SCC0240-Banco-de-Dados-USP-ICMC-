
CREATE TABLE PESSOA(
    CPF         CHAR(15)			 NOT NULL,
    RG          CHAR(11)		     NOT NULL,
    NOME        VARCHAR(30),
    DATA_NASC   DATE,
    VINCULO     VARCHAR(15),

	CONSTRAINT PK_PESSOA PRIMARY KEY(CPF),
    CONSTRAINT CK_VINCULO CHECK(UPPER(VINCULO) IN ('PROPRIETARIO', 'FUNCIONARIO', 'CLIENTE'))

);

CREATE TABLE CLIENTE(
    CONSTRAINT PK_CLIENTE PRIMARY KEY(CPF)
)INHERITS(PESSOA);

CREATE TABLE BAR(
    NRO_BALCAO  INT PRIMARY KEY NOT NULL
);


CREATE TABLE FUNCIONARIO(
    CARTEIRA_TRAB   CHAR(15)    NOT NULL, --CHECAR QUANTOS NUMEROS PARA CARTEIRA DE TRABALHO
    CACHE           REAL        NOT NULL,
    NRO_BALCAO      INT,

    CONSTRAINT PK_FUNCIONARIO PRIMARY KEY(CPF),
    -- GARANTIR QUE SALARIO NAO TENHA VALORES ABSURDOS
    CONSTRAINT FK_NRO_BALCAO FOREIGN KEY(NRO_BALCAO) REFERENCES BAR(NRO_BALCAO) ON UPDATE CASCADE ON DELETE SET NULL,
	CONSTRAINT CK_CACHE CHECK(CACHE > 700 AND CACHE < 5000)

)INHERITS(PESSOA);

CREATE TABLE PROPRIETARIO(
    NRO_CAMINHOES   INT     NOT NULL,

    CONSTRAINT PK_PROPRIETARIO PRIMARY KEY(CPF),
    -- GARANTIR A QUANTIDADE MAXIMA DE CAMINHOES POR PROPRIETARIO
    CONSTRAINT CK_NRO_CAMINHOES CHECK(NRO_CAMINHOES<=2 AND NRO_CAMINHOES>0)
)INHERITS(PESSOA);

--CHECAR SE E ASSIM QUE FAZ ESSA TABELA DATA
CREATE TABLE DATA_ALOCACAO(
    DIA     DATE    NOT NULL,
    HORA    time    NOT NULL,
    CONSTRAINT PK_DATA_ALOCACAO PRIMARY KEY(DIA,HORA)
);

CREATE TABLE ALOCACAO(
    CPF_FUNCIONARIO CHAR(15)    NOT NULL,
    NRO_BALCAO      INT         NOT NULL,
    DIA             DATE        NOT NULL, -- CHECAR SE EH ASSIM MESMO OU TEM QUE CRIAR SO UM
    HORA            TIME        NOT NULL, -- CHECAR JUNTO COM O DE CIME
    COMISSAO        REAL,

    CONSTRAINT PK_ALOCACAO      PRIMARY KEY(CPF_FUNCIONARIO, NRO_BALCAO, DIA, HORA),
    CONSTRAINT FK_FUNCIONARIO   FOREIGN KEY(CPF_FUNCIONARIO) REFERENCES FUNCIONARIO(CPF)      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_NRO_BALCAO    FOREIGN KEY(NRO_BALCAO)      REFERENCES BAR(NRO_BALCAO)       ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_DATA          FOREIGN KEY(DIA, HORA)       REFERENCES DATA_ALOCACAO(DIA,HORA) ON UPDATE CASCADE ON DELETE CASCADE, -- CHECAR SET NULL

    -- CHECAR SE A COMISSAO NAO ESTA COM VALOR ABSURDO
    CONSTRAINT CK_COMISSAO CHECK(COMISSAO > 0 AND COMISSAO < 10000)
);

CREATE TABLE FANTASIA(
    CODIGO_BARRAS   CHAR(13)     	NOT NULL,
    NOME            VARCHAR(30),
    COR             VARCHAR(10),
    TAMANHO         CHAR(1),
    -- VERIFICA SE POSSUI TAMANHO VALIDO
	CONSTRAINT PK_FANTASIA PRIMARY KEY(CODIGO_BARRAS),
    CONSTRAINT CK_TAMANHO CHECK(UPPER(TAMANHO) IN ('P', 'M', 'G', 'X'))

);

CREATE TABLE FESTA(
    DIA             DATE        NOT NULL,
    HORA            time        NOT NULL,
    TIPO            VARCHAR     NOT NULL,

    CONSTRAINT PK_FESTA          PRIMARY KEY(DIA, HORA),
    CONSTRAINT CK_TIPO CHECK(UPPER(TIPO) IN ('CARNAVAL', 'BALADA'))
);

CREATE TABLE CARNAVAL(
    ID_CARNAVAL     INT         NOT NULL,
    DIA             DATE        NOT NULL,
    HORA            time        NOT NULL,
    VALOR_INGRESSO  REAL        NOT NULL,

    CONSTRAINT PK_CARNAVAL PRIMARY KEY(ID_CARNAVAL, DIA, HORA),
    CONSTRAINT FK_CARNAVAL FOREIGN KEY(DIA, HORA) REFERENCES FESTA(DIA,HORA),
    CONSTRAINT CK_VALOR_INGRESSO CHECK(VALOR_INGRESSO >= 0)

);

CREATE TABLE BALADA(
    ID_BALADA       INT         NOT NULL,
    DIA             DATE        NOT NULL,
    HORA            time        NOT NULL,
    VALOR_INGRESSO  REAL        NOT NULL,


    CONSTRAINT PK_BALADA PRIMARY KEY(ID_BALADA, DIA, HORA),
    CONSTRAINT FK_BALADA FOREIGN KEY(DIA, HORA) REFERENCES FESTA(DIA,HORA),
    CONSTRAINT CK_VALOR_INGRESSO CHECK(VALOR_INGRESSO >= 0)
);

CREATE TABLE COMANDA(
    CODIGO          INT 			NOT NULL,
    CPF_CLIENTE     CHAR(15)        NOT NULL,
    VALOR_TOTAL     REAL            NOT NULL    DEFAULT '0',
    CODIGO_FANTASIA CHAR(13)                    DEFAULT '0', -- CHECAR SE PODE SER NULL CASO NAO TENHA PEGO FANTASIA
    DIA_FESTA       DATE            NOT NULL,                -- CHECAR SE PODE COLOCAR DIA E HORA JUNTO
    HORA_FESTA      TIME            NOT NULL,

	CONSTRAINT PK_COMANDA		  PRIMARY KEY(CODIGO),
    CONSTRAINT FK_CPF_CLIENTE     FOREIGN KEY(CPF_CLIENTE)            REFERENCES CLIENTE(CPF)             ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_CODIGO_FANTASIA FOREIGN KEY(CODIGO_FANTASIA)        REFERENCES FANTASIA(CODIGO_BARRAS)  ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_FESTA           FOREIGN KEY(DIA_FESTA, HORA_FESTA)  REFERENCES FESTA(DIA,HORA)          ON UPDATE CASCADE ON DELETE CASCADE -- CHECAR SE EH CASCADE MESMO

);

CREATE TABLE ALUGUEL(
    CODIGO          INT 	 NOT NULL,
    CODIGO_FANTASIA CHAR(13) NOT NULL,

    CONSTRAINT PK_ALUGUEL         PRIMARY KEY(CODIGO, CODIGO_FANTASIA),
    CONSTRAINT FK_CODIGO_FANTASIA FOREIGN KEY(CODIGO_FANTASIA)       REFERENCES FANTASIA(CODIGO_BARRAS)  ON UPDATE CASCADE ON DELETE CASCADE, -- CHECAR OS SET NULL E CASCADE
    CONSTRAINT FK_CODIGO          FOREIGN KEY(CODIGO)                REFERENCES COMANDA(CODIGO)          ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PALCO(
    NRO_PALCO   INT PRIMARY KEY NOT NULL,
    INTERVALO   TIME            NOT NULL --CHECAR DIREITO EM COMO ARMAZENAR ESSE INTERVALOR DE TEMPO

);

CREATE TABLE BANDA(
    NOME            VARCHAR(30) 		 	NOT NULL,
    DURACAO_SHOW    TIME                    NOT NULL, -- CHECAR SE PODE SER POR DATE MESMO
    GENERO          VARCHAR(12)             NOT NULL,
    CACHE           REAL                    NOT NULL,

	CONSTRAINT PK_BANDA PRIMARY KEY(NOME),
    -- VER SE  O CACHE NAO POSSUI VALORES NEGATIVOS
    CONSTRAINT  CK_CACHE    CHECK(CACHE>=0)
);

CREATE TABLE SHOW_BANDA(
    BANDA   VARCHAR(20) NOT NULL,
    PALCO   INT         NOT NULL,
    HORA    TIME        NOT NULL, -- CHECAR SE PODE COLOCAR COMO DATA
    DATA    DATE,

    CONSTRAINT  PK_SHOW_BANDA   PRIMARY KEY(BANDA, PALCO, HORA),
    CONSTRAINT  FK_BANDA        FOREIGN KEY(BANDA) REFERENCES BANDA(NOME) ON UPDATE CASCADE ON DELETE CASCADE,        -- CHECAR CASCADE
    CONSTRAINT  FK_PALCO        FOREIGN KEY(PALCO) REFERENCES PALCO(NRO_PALCO) ON UPDATE CASCADE ON DELETE CASCADE    -- CHECAR CASCADE

);

CREATE TABLE CONTRATO_BANDA(
    NRO_CONTRATO    INT            NOT NULL,
    DATA            DATE           NOT NULL,                    -- CHECAR SE REALMENTE PRECISA DESSA DATA
    BANDA           VARCHAR(20)    NOT NULL,
    ID_CARNAVAL     INT            NOT NULL,
    DIA_CARNAVAL    DATE           NOT NULL,                    -- CHECAR SE EH SO O DIA OU A HORA
    HORA_CARNAVAL   TIME           NOT NULL,                    -- CHECAR SE EH SO O DIA OU A HORA
    VALOR_PAGO      REAL                        DEFAULT '0',

    CONSTRAINT  PK_CONTRATO_BANDA   PRIMARY KEY(NRO_CONTRATO, ID_CARNAVAL, BANDA, DATA, DIA_CARNAVAL, HORA_CARNAVAL),
    CONSTRAINT  FK_BANDA            FOREIGN KEY(BANDA)                                      REFERENCES BANDA(NOME)                                   ON UPDATE CASCADE ON DELETE CASCADE, -- CHECAR CASCADE
    CONSTRAINT  FK_CARNAVAL         FOREIGN KEY(ID_CARNAVAL, DIA_CARNAVAL, HORA_CARNAVAL)   REFERENCES CARNAVAL(ID_CARNAVAL,DIA,HORA)   ON UPDATE CASCADE ON DELETE CASCADE  -- CHECAR CASCADE E ARRUMAR DIA HORA

);

CREATE TABLE DJ(
    NOME            VARCHAR(30)			   	NOT NULL,
    DURACAO_SHOW    TIME                    NOT NULL, -- CHECAR SE PODE SER POR DATE MESMO
    CACHE           REAL                    NOT NULL,

	CONSTRAINT PK_DJ PRIMARY KEY(NOME),
    -- VER SE  O CACHE NAO POSSUI VALORES NEGATIVOS
    CONSTRAINT  CK_CACHE    CHECK(CACHE>=0)

);

CREATE TABLE SHOW_DJ(
    PALCO   INT             NOT NULL,
    DJ      VARCHAR(20)     NOT NULL,
    HORA    TIME            NOT NULL,
    DATA    DATE            NOT NULL,

    CONSTRAINT  PK_SHOW_DJ   PRIMARY KEY(PALCO, DJ, HORA),
    CONSTRAINT  FK_DJ        FOREIGN KEY(DJ)    REFERENCES DJ(NOME)         ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT  FK_PALCO     FOREIGN KEY(PALCO) REFERENCES PALCO(NRO_PALCO) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE CONTRATO_DJ(
    NRO_CONTRATO    INT         NOT NULL,
    ID_BALADA     INT         NOT NULL,
    DIA_BALADA      DATE        NOT NULL,
    HORA_BALADA     TIME        NOT NULL,
    DJ              VARCHAR(20) NOT NULL,
    VALOR_PAGO      REAL                    DEFAULT '0',

    CONSTRAINT  PK_CONTRATO_DJ PRIMARY KEY(NRO_CONTRATO, ID_BALADA, DIA_BALADA, HORA_BALADA, DJ),
    CONSTRAINT  FK_BALADA      FOREIGN KEY(ID_BALADA, DIA_BALADA, HORA_BALADA)  REFERENCES BALADA(ID_BALADA, DIA, HORA) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT  FK_DJ          FOREIGN KEY(DJ)                                  REFERENCES DJ(NOME)                     ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT  CK_VALOR_PAGO  CHECK(VALOR_PAGO >= 0)

);

CREATE TABLE FOOD_TRUCK(
    PLACA           CHAR(7)     		    NOT NULL,
    NOME            VARCHAR(30),
    CULINARIA       VARCHAR(20),
    PROPRIETARIO    CHAR(15)                NOT NULL,

	CONSTRAINT PK_FOOD_TRUCK	PRIMARY KEY(PLACA),
    CONSTRAINT FK_PROPRIETARIO  FOREIGN KEY(PROPRIETARIO)   REFERENCES PROPRIETARIO(CPF) ON UPDATE CASCADE ON DELETE CASCADE

);

CREATE TABLE PARTICIPACAO(
    PLACA       CHAR(7) NOT NULL,
    ID_CARNAVAL INT     NOT NULL,
    DIA         DATE    NOT NULL,
    HORA        TIME    NOT NULL,

    CONSTRAINT PK_PARTICIPACAO PRIMARY KEY(PLACA, ID_CARNAVAL, DIA, HORA),
    CONSTRAINT FK_DATA         FOREIGN KEY(ID_CARNAVAL, DIA, HORA) REFERENCES CARNAVAL(ID_CARNAVAL,DIA,HORA) ON UPDATE CASCADE ON DELETE CASCADE --CHECAR A FORMA DE DATA

);

CREATE TABLE COMIDA(
    NRO_CARDAPIO    INT         NOT NULL,
    PLACA           CHAR(7)      NOT NULL,
    NOME            VARCHAR(30)  NOT NULL,
    VALOR           REAL,

    CONSTRAINT PK_COMIDA PRIMARY KEY(NRO_CARDAPIO, PLACA),
    CONSTRAINT FK_PLACA  FOREIGN KEY(PLACA) REFERENCES FOOD_TRUCK(PLACA) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT CK_VALOR  CHECK(VALOR >= 0)
);

CREATE TABLE REGISTRA_COMIDA(
    CODIGO          INT     NOT NULL,
    NRO_CARDAPIO    INT     NOT NULL,
    PLACA           CHAR(7) NOT NULL,

	CONSTRAINT 	PK_REGISTRA_COMIDA	PRIMARY KEY(CODIGO, NRO_CARDAPIO, PLACA),
    CONSTRAINT  FK_CODIGO   FOREIGN KEY(CODIGO)              REFERENCES COMANDA(CODIGO)             ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT  FK_COMIDA   FOREIGN KEY(NRO_CARDAPIO, PLACA) REFERENCES COMIDA(NRO_CARDAPIO, PLACA) ON UPDATE CASCADE ON DELETE CASCADE

);

CREATE TABLE DATA_VENDA_COMIDA(
    DIA     DATE    NOT NULL, -- CHECAR SE PODE SER DATE MESMO
    HORA    TIME    NOT NULL,

    CONSTRAINT PK_DATA_VENDA_COMIDA PRIMARY KEY(DIA, HORA)
);

CREATE TABLE VENDA_DE_COMIDA(
    NOTA_FISCAL     VARCHAR(20)    NOT NULL, -- CHECAR QUANTOS DIGITOS TEM UMA NOTA FISCAL
    DIA             DATE           NOT NULL, -- CHECAR SE E ASSIM MESMO QUE FAZ A DATA
    HORA            TIME           NOT NULL,
    CODIGO          INT            NOT NULL,
    NRO_CARDAPIO    INT            NOT NULL,
    PLACA           CHAR(7)        NOT NULL,
    VALOR_TOTAL     REAL,

    CONSTRAINT PK_VENDA_COMIDA PRIMARY KEY(NOTA_FISCAL, DIA, HORA, CODIGO, NRO_CARDAPIO, PLACA),
    CONSTRAINT FK_DATA         FOREIGN KEY(DIA,HORA)                    REFERENCES DATA_VENDA_COMIDA(DIA,HORA)                  ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_REGISTRA     FOREIGN KEY(CODIGO, NRO_CARDAPIO, PLACA) REFERENCES REGISTRA_COMIDA(CODIGO, NRO_CARDAPIO, PLACA) ON UPDATE CASCADE ON DELETE CASCADE,
    --VERICIANDO SE NAO HA VALORES NEGATIVOS
    CONSTRAINT CK_VALOR    CHECK(VALOR_TOTAL >= 0)
);

CREATE TABLE BEBIDA(
    NRO_BALCAO      INT         NOT NULL,
    CODIGO_BARRAS   CHAR(13)    NOT NULL,
    NOME            VARCHAR(30),
    VALOR           REAL                    DEFAULT '0',

    CONSTRAINT PK_BEBIDA     PRIMARY KEY(NRO_BALCAO, CODIGO_BARRAS),
    CONSTRAINT FK_NRO_BALCAO FOREIGN KEY(NRO_BALCAO)    REFERENCES BAR(NRO_BALCAO)  ON UPDATE CASCADE ON DELETE CASCADE,
    -- PARA VERIFICAR QUE NAO TENHA VALOR NEGATIVO
    CONSTRAINT CK_VALOR     CHECK(VALOR >= 0)
);

CREATE TABLE REGISTRA_BEBIDA(
    CODIGO          INT         NOT NULL,
    NRO_BALCAO      INT         NOT NULL,
    CODIGO_BARRAS   CHAR(13)    NOT NULL,

    CONSTRAINT  PK_REGISTRA_BEBIDA  PRIMARY KEY(CODIGO, NRO_BALCAO, CODIGO_BARRAS),
    CONSTRAINT  FK_CODIGO           FOREIGN KEY(CODIGO)                    REFERENCES COMANDA(CODIGO)                    ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT  FK_NRO_BALCAO       FOREIGN KEY(NRO_BALCAO, CODIGO_BARRAS) REFERENCES BEBIDA(NRO_BALCAO, CODIGO_BARRAS)  ON UPDATE CASCADE ON DELETE CASCADE-- CHECAR SET NULL
);

CREATE TABLE DATA_VENDA_BEBIDA(
    DIA     DATE    NOT NULL, -- CHECAR SE PODE SER DATE MESMO
    HORA    TIME    NOT NULL,

    CONSTRAINT PK_DATA_VENDA_BEBIDA PRIMARY KEY(DIA, HORA)
);

CREATE TABLE VENDA_BEBIDA(
    NOTA_FISCAL     VARCHAR(20)    NOT NULL, -- CHECAR QUANTOS DIGITOS TEM UMA NOTA FISCAL
    DIA             DATE           NOT NULL, -- CHECAR SE E ASSIM MESMO QUE FAZ A DATA
    HORA            TIME           NOT NULL,
    CODIGO          INT            NOT NULL,
    NRO_BALCAO      INT            NOT NULL,
    CODIGO_BARRAS   CHAR(13)       NOT NULL,
    VALOR_TOTAL     REAL                    DEFAULT '0',

    CONSTRAINT PK_VENDA_BEBIDA  PRIMARY KEY(NOTA_FISCAL, DIA, HORA, CODIGO, NRO_BALCAO, CODIGO_BARRAS),
    CONSTRAINT FK_DATA          FOREIGN KEY(DIA,HORA)                          REFERENCES DATA_VENDA_BEBIDA(DIA,HORA)                        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_REGISTRA      FOREIGN KEY(CODIGO, NRO_BALCAO, CODIGO_BARRAS) REFERENCES REGISTRA_BEBIDA(CODIGO, NRO_BALCAO, CODIGO_BARRAS) ON UPDATE CASCADE ON DELETE CASCADE
);
