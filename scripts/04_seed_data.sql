DECLARE @Today DATE = CAST(SYSUTCDATETIME() AS DATE);

INSERT fleet.ShipStatus (ShipStatusId, StatusCode, StatusName, IsOperational)
VALUES (1, 'ACTIVE',   N'Active',   1),
       (2, 'INACTIVE', N'Inactive', 0),
       (3, 'LAID_UP',  N'Laid Up',  0);

INSERT fleet.FiscalYearPattern (FiscalYearCode, StartMonth, EndMonth, Description)
VALUES ('0112',  1, 12, N'January - December'),
       ('0403',  4,  3, N'April - March'),
       ('1009', 10,  9, N'October - September'),
       ('0706',  7,  6, N'July - June');

INSERT finance.Currency (CurrencyCode, CurrencyName, MinorUnits)
VALUES ('USD', N'United States Dollar', 2),
       ('EUR', N'Euro', 2),
       ('SGD', N'Singapore Dollar', 2);

INSERT crew.Nationality (CountryCode, NationalityName)
VALUES ('GR', N'Greek'),      ('MX', N'Mexican'),    ('PH', N'Filipino'),
       ('IN', N'Indian'),     ('UA', N'Ukrainian'),  ('RO', N'Romanian'),
       ('ID', N'Indonesian'), ('HR', N'Croatian'),   ('MM', N'Burmese');

INSERT app.AppRole (RoleId, RoleCode, RoleName)
VALUES (1, 'ADMIN',         N'Administrator'),
       (2, 'FLEET_MANAGER', N'Fleet Manager'),
       (3, 'VIEWER',        N'Viewer');

INSERT crew.CrewRank (RankCode, RankName, Department, SeniorityOrder, IsUniquePerContract)
VALUES
    ('CAPTAIN',     N'Captain',                   'Deck',      1, 1),
    ('CH_MATE',     N'Chief Mate',                'Deck',      2, 1),
    ('SEC_MATE',    N'Second Mate',               'Deck',      3, 1),
    ('THIRD_MATE',  N'Third Mate',                'Deck',      4, 1),
    ('DECK_CADET',  N'Deck Cadet',                'Deck',      5, 0),
    ('BOATSWAIN',   N'Boatswain',                 'Deck',      6, 1),
    ('AB',          N'Able Seaman',               'Deck',      7, 0),
    ('OS',          N'Ordinary Seaman',           'Deck',      8, 0),
    ('RADIO_OFF',   N'Radio Officer',             'Deck',      9, 1),
    ('CH_ENG',      N'Chief Engineer',            'Engine',   10, 1),
    ('SEC_ENG',     N'Second Engineer',           'Engine',   11, 1),
    ('THIRD_ENG',   N'Third Engineer',            'Engine',   12, 1),
    ('FOURTH_ENG',  N'Fourth Engineer',           'Engine',   13, 1),
    ('TRAINEE_ENG', N'Trainee Marine Engineer',   'Engine',   14, 0),
    ('MOTORMAN',    N'Motorman',                  'Engine',   15, 0),
    ('OILER',       N'Oiler',                     'Engine',   16, 0),
    ('WIPER',       N'Wiper',                     'Engine',   17, 0),
    ('ETO',         N'Electro-Technical Officer', 'Engine',   18, 1),
    ('LEAD_ETO',    N'Lead ETO',                  'Engine',   19, 1),
    ('FIRST_ELEC',  N'First Electrician',         'Engine',   20, 1),
    ('CH_ELEC_OFF', N'Chief Electrical Officer',  'Engine',   21, 1),
    ('CH_ELEC_ENG', N'Chief Electrical Engineer', 'Engine',   22, 1),
    ('CH_STEWARD',  N'Chief Steward',             'Catering', 23, 1),
    ('CH_COOK',     N'Chief Cook',                'Catering', 24, 1);

INSERT fleet.Ship (ShipId, DisplayId, ShipName, FiscalYearCode, ShipStatusId, IMONumber)
VALUES (1, 'SHIP01', N'Flying Dutchman',  '0112', 1, '9174528'),
       (2, 'SHIP02', N'Thousand Sunny',   '0403', 1, '9265311'),
       (3, 'SHIP03', N'Flying Dutchmen',  '0403', 1, '9318476'),
       (4, 'SHIP04', N'Thousand Sanny',   '0112', 1, '9402183'),
       (5, 'SHIP05', N'Flying Dutchmin',  '1009', 1, '9487620'),
       (6, 'SHIP06', N'Thousand Senny',   '0706', 2, NULL);

ALTER SEQUENCE fleet.ShipIdSequence RESTART WITH 7;

INSERT app.AppUser (FullName, Email, RoleId)
VALUES (N'Alina Petrescu', N'alina.petrescu@example.com', 1),
       (N'Marcus Hale',    N'marcus.hale@example.com',    2),
       (N'Priya Nair',     N'priya.nair@example.com',     2),
       (N'Tomas Vrba',     N'tomas.vrba@example.com',     3),
       (N'Grace Oyelaran', N'grace.oyelaran@example.com', 3);

INSERT app.UserShipAssignment (UserId, ShipId)
SELECT u.UserId, s.ShipId
FROM app.AppUser u CROSS JOIN fleet.Ship s
WHERE u.Email = N'alina.petrescu@example.com';

INSERT app.UserShipAssignment (UserId, ShipId)
SELECT u.UserId, v.ShipId
FROM app.AppUser u CROSS APPLY (VALUES (1), (2), (3)) v(ShipId)
WHERE u.Email = N'marcus.hale@example.com';

INSERT app.UserShipAssignment (UserId, ShipId)
SELECT u.UserId, v.ShipId
FROM app.AppUser u CROSS APPLY (VALUES (4), (5), (6)) v(ShipId)
WHERE u.Email = N'priya.nair@example.com';

INSERT app.UserShipAssignment (UserId, ShipId)
SELECT u.UserId, 2
FROM app.AppUser u
WHERE u.Email = N'tomas.vrba@example.com';

DECLARE @Complement TABLE (Slot INT IDENTITY(1,1) PRIMARY KEY, RankCode VARCHAR(20));

INSERT @Complement (RankCode) VALUES
    ('CAPTAIN'), ('CH_MATE'), ('SEC_MATE'), ('THIRD_MATE'), ('DECK_CADET'),
    ('BOATSWAIN'), ('AB'), ('AB'), ('AB'), ('OS'),
    ('CH_ENG'), ('SEC_ENG'), ('THIRD_ENG'), ('FOURTH_ENG'), ('TRAINEE_ENG'),
    ('ETO'), ('MOTORMAN'), ('OILER'), ('WIPER'), ('CH_COOK');

DECLARE @CrewName TABLE
(
    Seq         INT PRIMARY KEY,
    FirstName   NVARCHAR(50),
    LastName    NVARCHAR(50),
    BirthDate   DATE,
    CountryCode CHAR(2)
);

INSERT @CrewName (Seq, FirstName, LastName, BirthDate, CountryCode) VALUES
    (  1, N'Soka',        N'Philip',       '1980-07-30', 'GR'),
    (  2, N'Masteros',    N'Philip',       '1980-07-30', 'GR'),
    (  3, N'John',        N'Masterbear',   '1975-07-30', 'GR'),
    (  4, N'Bob',         N'Marley',       '1998-07-30', 'MX'),
    (  5, N'John',        N'Chena',        '1995-07-30', 'MX'),
    (  6, N'Soka',        N'Philop',       '1976-07-11', 'RO'),
    (  7, N'Masteros',    N'Philop',       '1978-02-22', 'ID'),
    (  8, N'John',        N'Masterbeer',   '1980-09-05', 'HR'),
    (  9, N'Bob',         N'Marliy',       '1982-04-16', 'MM'),
    ( 10, N'John',        N'Chene',        '1984-11-27', 'GR'),
    ( 11, N'Soka',        N'Philup',       '1985-06-10', 'MX'),
    ( 12, N'Masteros',    N'Philup',       '1987-01-21', 'PH'),
    ( 13, N'John',        N'Masterbeir',   '1989-08-04', 'IN'),
    ( 14, N'Bob',         N'Marloy',       '1991-03-15', 'UA'),
    ( 15, N'John',        N'Cheni',        '1993-10-26', 'RO'),
    ( 16, N'Soka',        N'Philap',       '1995-05-09', 'ID'),
    ( 17, N'Masteros',    N'Philap',       '1997-12-20', 'HR'),
    ( 18, N'John',        N'Masterbeor',   '1999-07-03', 'MM'),
    ( 19, N'Bob',         N'Marluy',       '2001-02-14', 'GR'),
    ( 20, N'John',        N'Cheno',        '2003-09-25', 'MX'),
    ( 21, N'Soka',        N'Philep',       '1967-04-08', 'PH'),
    ( 22, N'Masteros',    N'Philep',       '1968-11-19', 'IN'),
    ( 23, N'John',        N'Masterbeur',   '1970-06-02', 'UA'),
    ( 24, N'Bob',         N'Marlay',       '1972-01-13', 'RO'),
    ( 25, N'John',        N'Chenu',        '1974-08-24', 'ID'),
    ( 26, N'Soka',        N'Pholip',       '1976-03-07', 'HR'),
    ( 27, N'Masteros',    N'Pholip',       '1978-10-18', 'MM'),
    ( 28, N'John',        N'Masterbiar',   '1980-05-01', 'GR'),
    ( 29, N'Bob',         N'Merley',       '1982-12-12', 'MX'),
    ( 30, N'John',        N'China',        '1984-07-23', 'PH'),
    ( 31, N'Soka',        N'Pholop',       '1985-02-06', 'IN'),
    ( 32, N'Masteros',    N'Pholop',       '1987-09-17', 'UA'),
    ( 33, N'John',        N'Masterbier',   '1989-04-28', 'RO'),
    ( 34, N'Bob',         N'Merliy',       '1991-11-11', 'ID'),
    ( 35, N'John',        N'Chine',        '1993-06-22', 'HR'),
    ( 36, N'Soka',        N'Pholup',       '1995-01-05', 'MM'),
    ( 37, N'Masteros',    N'Pholup',       '1997-08-16', 'GR'),
    ( 38, N'John',        N'Masterbiir',   '1999-03-27', 'MX'),
    ( 39, N'Bob',         N'Merloy',       '2001-10-10', 'PH'),
    ( 40, N'John',        N'Chini',        '2003-05-21', 'IN'),
    ( 41, N'Soka',        N'Pholap',       '1967-12-04', 'UA'),
    ( 42, N'Masteros',    N'Pholap',       '1968-07-15', 'RO'),
    ( 43, N'John',        N'Masterbior',   '1970-02-26', 'ID'),
    ( 44, N'Bob',         N'Merluy',       '1972-09-09', 'HR'),
    ( 45, N'John',        N'Chino',        '1974-04-20', 'MM'),
    ( 46, N'Soka',        N'Pholep',       '1976-11-03', 'GR'),
    ( 47, N'Masteros',    N'Pholep',       '1978-06-14', 'MX'),
    ( 48, N'John',        N'Masterbiur',   '1980-01-25', 'PH'),
    ( 49, N'Bob',         N'Merlay',       '1982-08-08', 'IN'),
    ( 50, N'John',        N'Chinu',        '1984-03-19', 'UA'),
    ( 51, N'Soka',        N'Phulip',       '1985-10-02', 'RO'),
    ( 52, N'Masteros',    N'Phulip',       '1987-05-13', 'ID'),
    ( 53, N'John',        N'Masterboar',   '1989-12-24', 'HR'),
    ( 54, N'Bob',         N'Mirley',       '1991-07-07', 'MM'),
    ( 55, N'John',        N'Chona',        '1993-02-18', 'GR'),
    ( 56, N'Soka',        N'Phulop',       '1995-09-01', 'MX'),
    ( 57, N'Masteros',    N'Phulop',       '1997-04-12', 'PH'),
    ( 58, N'John',        N'Masterboer',   '1999-11-23', 'IN'),
    ( 59, N'Bob',         N'Mirliy',       '2001-06-06', 'UA'),
    ( 60, N'John',        N'Chone',        '2003-01-17', 'RO'),
    ( 61, N'Soka',        N'Phulup',       '1967-08-28', 'ID'),
    ( 62, N'Masteros',    N'Phulup',       '1968-03-11', 'HR'),
    ( 63, N'John',        N'Masterboir',   '1970-10-22', 'MM'),
    ( 64, N'Bob',         N'Mirloy',       '1972-05-05', 'GR'),
    ( 65, N'John',        N'Choni',        '1974-12-16', 'MX'),
    ( 66, N'Soka',        N'Phulap',       '1976-07-27', 'PH'),
    ( 67, N'Masteros',    N'Phulap',       '1978-02-10', 'IN'),
    ( 68, N'John',        N'Masterboor',   '1980-09-21', 'UA'),
    ( 69, N'Bob',         N'Mirluy',       '1982-04-04', 'RO'),
    ( 70, N'John',        N'Chono',        '1984-11-15', 'ID'),
    ( 71, N'Soka',        N'Phulep',       '1985-06-26', 'HR'),
    ( 72, N'Masteros',    N'Phulep',       '1987-01-09', 'MM'),
    ( 73, N'John',        N'Masterbour',   '1989-08-20', 'GR'),
    ( 74, N'Bob',         N'Mirlay',       '1991-03-03', 'MX'),
    ( 75, N'John',        N'Chonu',        '1993-10-14', 'PH'),
    ( 76, N'Soka',        N'Phalip',       '1995-05-25', 'IN'),
    ( 77, N'Masteros',    N'Phalip',       '1997-12-08', 'UA'),
    ( 78, N'John',        N'Masterbuar',   '1999-07-19', 'RO'),
    ( 79, N'Bob',         N'Morley',       '2001-02-02', 'ID'),
    ( 80, N'John',        N'Chuna',        '2003-09-13', 'HR'),
    ( 81, N'Soka',        N'Phalop',       '1967-04-24', 'MM'),
    ( 82, N'Masteros',    N'Phalop',       '1968-11-07', 'GR'),
    ( 83, N'John',        N'Masterbuer',   '1970-06-18', 'MX'),
    ( 84, N'Bob',         N'Morliy',       '1972-01-01', 'PH'),
    ( 85, N'John',        N'Chune',        '1974-08-12', 'IN'),
    ( 86, N'Soka',        N'Phalup',       '1976-03-23', 'UA'),
    ( 87, N'Masteros',    N'Phalup',       '1978-10-06', 'RO'),
    ( 88, N'John',        N'Masterbuir',   '1980-05-17', 'ID'),
    ( 89, N'Bob',         N'Morloy',       '1982-12-28', 'HR'),
    ( 90, N'John',        N'Chuni',        '1984-07-11', 'MM'),
    ( 91, N'Soka',        N'Phalap',       '1985-02-22', 'GR'),
    ( 92, N'Masteros',    N'Phalap',       '1987-09-05', 'MX'),
    ( 93, N'John',        N'Masterbuor',   '1989-04-16', 'PH'),
    ( 94, N'Bob',         N'Morluy',       '1991-11-27', 'IN'),
    ( 95, N'John',        N'Chuno',        '1993-06-10', 'UA'),
    ( 96, N'Soka',        N'Phalep',       '1995-01-21', 'RO'),
    ( 97, N'Masteros',    N'Phalep',       '1997-08-04', 'ID'),
    ( 98, N'John',        N'Masterbuur',   '1999-03-15', 'HR'),
    ( 99, N'Bob',         N'Morlay',       '2001-10-26', 'MM'),
    (100, N'John',        N'Chunu',        '2003-05-09', 'GR'),
    (101, N'Soka',        N'Phelip',       '1967-12-20', 'MX'),
    (102, N'Masteros',    N'Phelip',       '1968-07-03', 'PH'),
    (103, N'John',        N'Masterbaar',   '1970-02-14', 'IN'),
    (104, N'Bob',         N'Murley',       '1972-09-25', 'UA'),
    (105, N'John',        N'Chana',        '1974-04-08', 'RO'),
    (106, N'Soka',        N'Phelop',       '1976-11-19', 'ID'),
    (107, N'Masteros',    N'Phelop',       '1978-06-02', 'HR'),
    (108, N'John',        N'Masterbaer',   '1980-01-13', 'MM'),
    (109, N'Bob',         N'Murliy',       '1982-08-24', 'GR'),
    (110, N'John',        N'Chane',        '1984-03-07', 'MX'),
    (111, N'Soka',        N'Phelup',       '1985-10-18', 'PH'),
    (112, N'Masteros',    N'Phelup',       '1987-05-01', 'IN'),
    (113, N'John',        N'Masterbair',   '1989-12-12', 'UA'),
    (114, N'Bob',         N'Murloy',       '1991-07-23', 'RO'),
    (115, N'John',        N'Chani',        '1993-02-06', 'ID'),
    (116, N'Soka',        N'Phelap',       '1995-09-17', 'HR'),
    (117, N'Masteros',    N'Phelap',       '1997-04-28', 'MM'),
    (118, N'John',        N'Masterbaor',   '1999-11-11', 'GR'),
    (119, N'Bob',         N'Murluy',       '2001-06-22', 'MX'),
    (120, N'John',        N'Chano',        '2003-01-05', 'PH');

DECLARE @Berth TABLE (Seq INT PRIMARY KEY, ShipId INT, Slot INT, RankId SMALLINT);

INSERT @Berth (Seq, ShipId, Slot, RankId)
SELECT  ROW_NUMBER() OVER (ORDER BY s.ShipId, c.Slot),
        s.ShipId, c.Slot, r.RankId
FROM fleet.Ship s
CROSS JOIN @Complement c
JOIN crew.CrewRank r ON r.RankCode = c.RankCode;

INSERT crew.CrewMember
    (CrewMemberId, DisplayId, FirstName, LastName, BirthDate, NationalityId, Gender, CreatedBy)
SELECT  cn.Seq,
        'CREW' + FORMAT(cn.Seq, '000'),
        cn.FirstName,
        cn.LastName,
        cn.BirthDate,
        n.NationalityId,
        CASE WHEN cn.Seq % 11 = 0 THEN 'F' ELSE 'M' END,
        N'seed'
FROM @CrewName cn
JOIN crew.Nationality n ON n.CountryCode = cn.CountryCode;

ALTER SEQUENCE crew.CrewMemberIdSequence RESTART WITH 121;

INSERT crew.CrewServiceHistory
    (CrewMemberId, ShipId, RankId, SignOnDate, SignOffDate, EndOfContractDate,
     ContractReference, CreatedBy)
SELECT  b.Seq, b.ShipId, b.RankId,
        CASE WHEN b.Slot IN (3, 17, 20) THEN DATEADD(DAY, -300, @Today)
             WHEN b.Slot = 7            THEN DATEADD(DAY, -280, @Today)
             WHEN b.Slot = 9            THEN DATEADD(DAY, -400, @Today)
             ELSE DATEADD(DAY, -(90 + (b.Seq % 60)), @Today)
        END,
        CASE WHEN b.Slot = 9 THEN DATEADD(DAY, -35, @Today) END,
        CASE WHEN b.Slot = 3  THEN DATEADD(DAY, -45, @Today)
             WHEN b.Slot = 17 THEN DATEADD(DAY, -60, @Today)
             WHEN b.Slot = 20 THEN DATEADD(DAY, -31, @Today)
             WHEN b.Slot = 7  THEN DATEADD(DAY, -25, @Today)
             WHEN b.Slot = 9  THEN DATEADD(DAY, -40, @Today)
             ELSE DATEADD(DAY, (30 + (b.Seq % 90)), @Today)
        END,
        'CTR-' + FORMAT(b.ShipId, '00') + '-' + FORMAT(b.Seq, '0000'),
        N'seed'
FROM @Berth b;

INSERT crew.CrewServiceHistory
    (CrewMemberId, ShipId, RankId, SignOnDate, SignOffDate, EndOfContractDate,
     ContractReference, CreatedBy)
SELECT  b.Seq, b.ShipId, b.RankId,
        DATEADD(DAY, 30, @Today), NULL, DATEADD(DAY, 210, @Today),
        'CTR-' + FORMAT(b.ShipId, '00') + '-' + FORMAT(b.Seq, '0000') + '-R',
        N'seed'
FROM @Berth b
WHERE b.Slot = 9;

GO

INSERT finance.ChartOfAccount
    (AccountNumber, AccountDescription, ParentAccountNumber,
     AccountLevel, IsPostable, AccountType)
VALUES
    (1000000, N'ASSETS',                                              NULL,    1, 0, 'Asset'),
    (1000200, N'Current Assets',                                      1000000, 2, 0, 'Asset'),
    (1000300, N'Liquid Assets',                                       1000200, 3, 0, 'Asset'),
    (1016000, N'Cash in Bank',                                        1000300, 4, 0, 'Asset'),
    (1016100, N'Cash in Bank – Acct 1',                               1016000, 5, 1, 'Asset'),
    (1016200, N'Cash in Bank – Acct 2',                               1016000, 5, 1, 'Asset'),
    (1098000, N'Savings and Temporary Cash Investments',              1000300, 4, 0, 'Asset'),
    (1098100, N'Savings Account',                                     1098000, 5, 1, 'Asset'),
    (1098200, N'Certificate of Deposit',                              1098000, 5, 1, 'Asset'),
    (1098300, N'Money Market Accounts',                               1098000, 5, 0, 'Asset'),
    (1098310, N'Money Market – Acct 1',                               1098300, 6, 1, 'Asset'),
    (1098320, N'Wing Money Market in Investment',                     1098300, 6, 1, 'Asset'),
    (1499,    N'Undeposited Funds',                                   1000300, 4, 1, 'Asset'),
    (1110000, N'Accounts Receivable',                                 1000200, 3, 0, 'Asset'),
    (1120000, N'Accounts Receivable',                                 1110000, 4, 1, 'Asset'),
    (1190000, N'Allowance for Doubtful Accounts',                     1110000, 4, 1, 'Asset'),
    (1350000, N'Prepaid Expenses',                                    1000200, 3, 0, 'Asset'),
    (1350100, N'Prepaid General',                                     1350000, 4, 1, 'Asset'),
    (1350200, N'Prepaid Advances',                                    1350000, 4, 1, 'Asset'),
    (1400000, N'Investments',                                         1000000, 2, 0, 'Asset'),
    (1410000, N'Investments – Unrestricted',                          1400000, 3, 0, 'Asset'),
    (1411000, N'Scholarship Fund',                                    1410000, 4, 1, 'Asset'),
    (1414000, N'General Fund',                                        1410000, 4, 1, 'Asset'),
    (1430000, N'Investments – Restricted',                            1400000, 3, 1, 'Asset'),
    (1441000, N'Investment Valuation Allowance',                      1400000, 3, 1, 'Asset'),
    (1500000, N'Fixed Assets',                                        1000000, 2, 0, 'Asset'),
    (1505000, N'Land',                                                1500000, 3, 1, 'Asset'),
    (1520000, N'Fixed Assets – Buildings & Improvements',             1500000, 3, 0, 'Asset'),
    (1520010, N'Building 1',                                          1520000, 4, 1, 'Asset'),
    (1520020, N'Building 2',                                          1520000, 4, 1, 'Asset'),
    (1520090, N'Work in Progress',                                    1520000, 4, 1, 'Asset'),
    (1525000, N'Accumulated Depreciation – Buildings & Improvements', 1500000, 3, 1, 'Asset'),
    (1530000, N'Fixed Assets – Furniture & Fixtures',                 1500000, 3, 1, 'Asset'),
    (1535000, N'Accumulated Depreciation – Furniture & Fixtures',     1500000, 3, 1, 'Asset'),
    (1540000, N'Fixed Assets – Computers',                            1500000, 3, 1, 'Asset'),
    (1545000, N'Accumulated Depreciation – Computers',                1500000, 3, 1, 'Asset'),
    (1570000, N'Fixed Assets – Other Equipment',                      1500000, 3, 1, 'Asset'),
    (1575000, N'Accumulated Depreciation – Other Equipment',          1500000, 3, 1, 'Asset'),
    (1620000, N'Fixed Assets – Communication Equipment',              1500000, 3, 1, 'Asset'),
    (1625000, N'Accumulated Depreciation – Communication Equipment',  1500000, 3, 1, 'Asset'),
    (1600000, N'Equipment Under Capital Leases',                      1000000, 2, 0, 'Asset'),
    (1605000, N'Accumulated Depreciation – Capital Leases',           1600000, 3, 1, 'Asset');

INSERT finance.ChartOfAccount
    (AccountNumber, AccountDescription, ParentAccountNumber,
     AccountLevel, IsPostable, AccountType)
VALUES
    (2000000, N'LIABILITIES AND NET ASSETS',                          NULL,    1, 0, 'Liability'),
    (2010000, N'Liabilities',                                         2000000, 2, 0, 'Liability'),
    (2015000, N'Accounts Payable',                                    2010000, 3, 1, 'Liability'),
    (2016000, N'Credit Cards (only if Credit Card Function in QuickBooks® is used)',
                                                                      2010000, 3, 1, 'Liability'),
    (2100000, N'Accrued Payroll Liabilities',                         2010000, 3, 0, 'Liability'),
    (2110000, N'Accrued Salaries',                                    2100000, 4, 1, 'Liability'),
    (2121000, N'Accrued Leave',                                       2100000, 4, 1, 'Liability'),
    (2130000, N'Accrued Payroll Taxes',                               2100000, 4, 1, 'Liability'),
    (2195000, N'Obligations Under Capital Leases – Current',          2010000, 3, 1, 'Liability'),
    (2350000, N'Deferred Revenue and Credits',                        2010000, 3, 1, 'Liability'),
    (2600000, N'Notes Payable - Current',                             2010000, 3, 1, 'Liability'),
    (2700000, N'Long-Term Liabilities',                               2000000, 2, 0, 'Liability'),
    (2750000, N'Obligations Under Capital Leases',                    2700000, 3, 1, 'Liability'),
    (2755000, N'Notes Payable – Long-Term',                           2700000, 3, 1, 'Liability'),
    (3000000, N'Net Assets',                                          2000000, 2, 0, 'Liability'),
    (3005000, N'Current Year Net Assets',                             3000000, 3, 1, 'Liability'),
    (3015000, N'Net Assets – Unrestricted',                           3000000, 3, 1, 'Liability'),
    (3025000, N'Net Assets – Temporarily Restricted',                 3000000, 3, 1, 'Liability'),
    (3030000, N'Net Assets – Permanently Restricted',                 3000000, 3, 1, 'Liability'),
    (3000,    N'Opening Balance Equity',                              3000000, 3, 1, 'Liability'),
    (3900,    N'Retained Earnings',                                   3000000, 3, 1, 'Liability');

INSERT finance.ChartOfAccount
    (AccountNumber, AccountDescription, ParentAccountNumber,
     AccountLevel, IsPostable, AccountType)
VALUES
    (4000000, N'REVENUES AND EXPENSES',                               NULL,    1, 0, 'Revenue'),
    (4999,    N'Uncategorized Income',                                4000000, 2, 1, 'Revenue');

INSERT finance.ChartOfAccount
    (AccountNumber, AccountDescription, ParentAccountNumber,
     AccountLevel, IsPostable, AccountType)
VALUES
    (5000000, N'Revenues',                                            4000000, 2, 0, 'Revenue'),
    (5010000, N'Revenues from Government Contracts',                  5000000, 3, 0, 'Revenue'),
    (5050000, N'Federal, State and Local Government Missions',        5010000, 4, 0, 'Revenue'),
    (5050100, N'Aircraft Minor Maintenance',                          5050000, 5, 1, 'Revenue'),
    (5050200, N'Aircraft Fuel',                                       5050000, 5, 1, 'Revenue'),
    (5050300, N'Miscellaneous',                                       5050000, 5, 1, 'Revenue'),
    (5060000, N'State Appropriation',                                 5010000, 4, 1, 'Revenue'),
    (5080000, N'Government Contributions – Unrestricted',             5010000, 4, 1, 'Revenue'),
    (5081000, N'Government Contributions – Restricted',               5010000, 4, 1, 'Revenue'),
    (5082000, N'Government Contributed Facilities & Utilities',       5010000, 4, 1, 'Revenue'),
    (5083000, N'Government Contributions Materials & Supplies (DRMO)',5010000, 4, 1, 'Revenue'),
    (5090000, N'State Director Income',                               5010000, 4, 0, 'Revenue'),
    (5090100, N'State Director Rent & Utilities – From NHQ',          5090000, 5, 1, 'Revenue'),
    (5090200, N'State Director Flying – From NHQ',                    5090000, 5, 1, 'Revenue'),
    (5100000, N'Revenues from Activities',                            5000000, 3, 0, 'Revenue'),
    (5223200, N'Senior Activities',                                   5100000, 4, 0, 'Revenue'),
    (5223201, N'Activity 1',                                          5223200, 5, 1, 'Revenue'),
    (5223202, N'Activity 2',                                          5223200, 5, 1, 'Revenue'),
    (5224200, N'Cadet Activities',                                    5100000, 4, 0, 'Revenue'),
    (5224201, N'Encampment',                                          5224200, 5, 1, 'Revenue'),
    (5224202, N'Activity 1',                                          5224200, 5, 1, 'Revenue'),
    (5224300, N'Combined Senior & Cadet Activities',                  5100000, 4, 0, 'Revenue'),
    (5224301, N'Activity 1',                                          5224300, 5, 1, 'Revenue'),
    (5224302, N'Activity 2',                                          5224300, 5, 1, 'Revenue'),
    (5225200, N'Flight Activities/Member Flying',                     5100000, 4, 0, 'Revenue'),
    (5225201, N'Aircraft Minor Maintenance',                          5225200, 5, 1, 'Revenue'),
    (5225202, N'Aircraft Fuel',                                       5225200, 5, 1, 'Revenue'),
    (5225203, N'Miscellaneous',                                       5225200, 5, 1, 'Revenue'),
    (5235000, N'Other Mission Income',                                5100000, 4, 1, 'Revenue'),
    (5240000, N'Fundraising Income',                                  5000000, 3, 0, 'Revenue'),
    (5240100, N'Wreaths Across America',                              5240000, 4, 1, 'Revenue'),
    (5240200, N'Raffle Income',                                       5240000, 4, 1, 'Revenue'),
    (5240300, N'Other Fundraising Income',                            5240000, 4, 1, 'Revenue'),
    (5310000, N'Revenue from Dues',                                   5000000, 3, 0, 'Revenue'),
    (5310010, N'Member Dues',                                         5310000, 4, 0, 'Revenue'),
    (5310011, N'From NHQ',                                            5310010, 5, 1, 'Revenue'),
    (5310012, N'From Members',                                        5310010, 5, 1, 'Revenue'),
    (5342000, N'Contributions - From NHQ',                            5000000, 3, 1, 'Revenue'),
    (5400000, N'Other Revenue and Gains',                             5000000, 3, 0, 'Revenue'),
    (5410000, N'Interest Income',                                     5400000, 4, 1, 'Revenue'),
    (5412000, N'Contributions',                                       5400000, 4, 0, 'Revenue'),
    (5412010, N'Contributions – Unrestricted',                        5412000, 5, 0, 'Revenue'),
    (5412011, N'Contributions – Unrestricted – Cash',                 5412010, 6, 1, 'Revenue'),
    (5412012, N'Contributions – Unrestricted – Non-Cash',             5412010, 6, 1, 'Revenue'),
    (5412020, N'Contributions – Restricted',                          5412000, 5, 0, 'Revenue'),
    (5412021, N'Contributions – Restricted – Cash',                   5412020, 6, 1, 'Revenue'),
    (5412022, N'Contributions – Restricted – Non-Cash',               5412020, 6, 1, 'Revenue'),
    (5413000, N'Non-Government Contributed Facilities & Utilities',   5400000, 4, 1, 'Revenue'),
    (5415000, N'Miscellaneous Income',                                5400000, 4, 1, 'Revenue'),
    (5416000, N'Rental Income',                                       5400000, 4, 1, 'Revenue'),
    (5419000, N'Investment Income',                                   5400000, 4, 0, 'Revenue'),
    (5419010, N'Investment Income – Unrestricted',                    5419000, 5, 1, 'Revenue'),
    (5419020, N'Investment Income – Restricted',                      5419000, 5, 1, 'Revenue'),
    (5420000, N'Unrealized Market Gain/Loss',                         5400000, 4, 1, 'Revenue'),
    (5422000, N'Gain/Loss on Sale of Securities',                     5400000, 4, 1, 'Revenue'),
    (5423000, N'Gain/Loss on Sale or Disposal of Assets',             5400000, 4, 1, 'Revenue'),
    (5424100, N'Material & Supply Sales',                             5400000, 4, 1, 'Revenue'),
    (5424200, N'Insurance Collected',                                 5400000, 4, 1, 'Revenue'),
    (5424300, N'Unrelated Business Income',                           5400000, 4, 0, 'Revenue'),
    (5424310, N'Advertising Sales (Dennison Brothers)',               5424300, 5, 1, 'Revenue'),
    (5424320, N'Other UBI',                                           5424300, 5, 1, 'Revenue');

INSERT finance.ChartOfAccount
    (AccountNumber, AccountDescription, ParentAccountNumber,
     AccountLevel, IsPostable, AccountType)
VALUES
    (6210000, N'Special Events',                                      5000000, 3, 0, 'Revenue'),
    (6212000, N'Wing Conference Registration',                        6210000, 4, 1, 'Revenue'),
    (6213000, N'Other Wing Events',                                   6210000, 4, 1, 'Revenue'),
    (6214000, N'Unit Events',                                         6210000, 4, 1, 'Revenue'),
    (6299999, N'PY Budgeted Reserves Use (for budget use only)',      5000000, 3, 1, 'Revenue'),
    (6300000, N'From National Headquarters',                          5000000, 3, 0, 'Revenue'),
    (6310000, N'From NHQ – Funded Flying',                            6300000, 4, 0, 'Revenue'),
    (6310100, N'Aircraft Minor Maintenance',                          6310000, 5, 0, 'Revenue'),
    (6310110, N'CD Missions',                                         6310100, 6, 1, 'Revenue'),
    (6310120, N'SAR Actual Missions',                                 6310100, 6, 1, 'Revenue'),
    (6310130, N'SAR Training Missions',                               6310100, 6, 1, 'Revenue'),
    (6310170, N'ROTC Flying',                                         6310100, 6, 1, 'Revenue'),
    (6310180, N'Cadet Orientation Rides',                             6310100, 6, 1, 'Revenue'),
    (6310200, N'Aircraft Fuel',                                       6310000, 5, 0, 'Revenue'),
    (6310210, N'CD Missions',                                         6310200, 6, 1, 'Revenue'),
    (6310220, N'SAR Actual Missions',                                 6310200, 6, 1, 'Revenue'),
    (6310230, N'SAR Training Missions',                               6310200, 6, 1, 'Revenue'),
    (6310270, N'ROTC Flying',                                         6310200, 6, 1, 'Revenue'),
    (6310280, N'Cadet Orientation Rides',                             6310200, 6, 1, 'Revenue'),
    (6310300, N'Miscellaneous',                                       6310000, 5, 0, 'Revenue'),
    (6310310, N'CD Missions',                                         6310300, 6, 1, 'Revenue'),
    (6310320, N'SAR Actual Missions',                                 6310300, 6, 1, 'Revenue'),
    (6310330, N'SAR Training Missions',                               6310300, 6, 1, 'Revenue'),
    (6310380, N'Cadet Orientation Glider Tows',                       6310300, 6, 1, 'Revenue'),
    (6313000, N'From NHQ – Aircraft & Vehicle Maintenance',           6300000, 4, 0, 'Revenue'),
    (6313010, N'Aircraft Reimbursable Maintenance',                   6313000, 5, 1, 'Revenue'),
    (6313015, N'Consolidated Mx Ferry Costs',                         6313000, 5, 1, 'Revenue'),
    (6313020, N'Glider Reimbursable Maintenance',                     6313000, 5, 1, 'Revenue'),
    (6313030, N'Vehicle Reimbursable Maintenance',                    6313000, 5, 1, 'Revenue'),
    (6314000, N'From NHQ – Senior Activities',                        6300000, 4, 1, 'Revenue'),
    (6315000, N'From NHQ – Cadet Activities',                         6300000, 4, 0, 'Revenue'),
    (6315010, N'National Flight Academies',                           6315000, 5, 1, 'Revenue'),
    (6315020, N'National Cadet Competition',                          6315000, 5, 1, 'Revenue'),
    (6315030, N'Advance Technologies Academies',                      6315000, 5, 1, 'Revenue'),
    (6315040, N'National Character & Leadership',                     6315000, 5, 1, 'Revenue'),
    (6315090, N'Other Cadet Activities',                              6315000, 5, 1, 'Revenue'),
    (6320000, N'From NHQ – Other',                                    6300000, 4, 0, 'Revenue'),
    (6320010, N'IACE',                                                6320000, 5, 1, 'Revenue'),
    (6320020, N'NESA',                                                6320000, 5, 1, 'Revenue'),
    (6320030, N'Teacher Flights',                                     6320000, 5, 1, 'Revenue'),
    (6320040, N'DDR',                                                 6320000, 5, 1, 'Revenue'),
    (6320050, N'Travel',                                              6320000, 5, 1, 'Revenue'),
    (6320060, N'Scholarships',                                        6320000, 5, 1, 'Revenue'),
    (6320070, N'Supplies',                                            6320000, 5, 1, 'Revenue'),
    (6320100, N'Miscellaneous',                                       6320000, 5, 1, 'Revenue'),
    (6320200, N'Miscellaneous Missions',                              6320000, 5, 0, 'Revenue'),
    (6320210, N'Aircraft Minor Maintenance',                          6320200, 6, 1, 'Revenue'),
    (6320220, N'Aircraft Fuel',                                       6320200, 6, 1, 'Revenue'),
    (6320230, N'Miscellaneous',                                       6320200, 6, 1, 'Revenue'),
    (6500000, N'From Units Below National Headquarters',              5000000, 3, 0, 'Revenue'),
    (6510000, N'From Regions and Wings',                              6500000, 4, 0, 'Revenue'),
    (6510100, N'From Regions',                                        6510000, 5, 0, 'Revenue'),
    (6510110, N'From Regions through NHQ',                            6510100, 6, 1, 'Revenue'),
    (6510120, N'Other Income from Regions',                           6510100, 6, 1, 'Revenue'),
    (6510200, N'From Wings',                                          6510000, 5, 0, 'Revenue'),
    (6510210, N'Proficiency Flying',                                  6510200, 6, 1, 'Revenue'),
    (6510215, N'Aircraft Fuel',                                       6510200, 6, 1, 'Revenue'),
    (6510220, N'Vehicle Maintenance',                                 6510200, 6, 1, 'Revenue'),
    (6510225, N'Vehicle Fuel',                                        6510200, 6, 1, 'Revenue'),
    (6510230, N'Mission Reimbursements',                              6510200, 6, 1, 'Revenue'),
    (6510240, N'Membership Dues',                                     6510200, 6, 1, 'Revenue'),
    (6510250, N'Activities',                                          6510200, 6, 1, 'Revenue'),
    (6510290, N'Miscellaneous',                                       6510200, 6, 1, 'Revenue'),
    (6513000, N'From Units Below',                                    6500000, 4, 0, 'Revenue'),
    (6513010, N'Proficiency Flying',                                  6513000, 5, 1, 'Revenue'),
    (6513015, N'Aircraft Fuel',                                       6513000, 5, 1, 'Revenue'),
    (6513020, N'Vehicle Maintenance',                                 6513000, 5, 1, 'Revenue'),
    (6513025, N'Vehicle Fuel',                                        6513000, 5, 1, 'Revenue'),
    (6513030, N'Mission Reimbursements',                              6513000, 5, 1, 'Revenue'),
    (6513040, N'Membership Dues',                                     6513000, 5, 1, 'Revenue'),
    (6513050, N'Wing Conference',                                     6513000, 5, 1, 'Revenue'),
    (6513060, N'Encampment',                                          6513000, 5, 1, 'Revenue'),
    (6513090, N'Miscellaneous',                                       6513000, 5, 1, 'Revenue');

INSERT finance.ChartOfAccount
    (AccountNumber, AccountDescription, ParentAccountNumber,
     AccountLevel, IsPostable, AccountType)
VALUES
    (7000000, N'OPERATING EXPENSES',                                  4000000, 2, 0, 'Expense'),
    (7100000, N'Awards and Grants to Individuals',                    7000000, 3, 0, 'Expense'),
    (7120000, N'Awards',                                              7100000, 4, 1, 'Expense'),
    (7135000, N'Scholarships',                                        7100000, 4, 1, 'Expense'),
    (7200000, N'Salaries and Related Expenses',                       7000000, 3, 0, 'Expense'),
    (7210000, N'Salaries',                                            7200000, 4, 1, 'Expense'),
    (7220000, N'Accrued Leave Expense',                               7200000, 4, 1, 'Expense'),
    (7310000, N'401(k) Corporate Contribution',                       7200000, 4, 1, 'Expense'),
    (7320000, N'Health Insurance',                                    7200000, 4, 1, 'Expense'),
    (7324000, N'Worker’s Comp Insurance',                             7200000, 4, 1, 'Expense'),
    (7325000, N'Other Employee Benefits',                             7200000, 4, 1, 'Expense'),
    (7410000, N'Payroll Tax Expense',                                 7200000, 4, 1, 'Expense'),
    (6560,    N'Payroll Expenses',                                    7200000, 4, 1, 'Expense'),
    (6999,    N'Uncategorized Expenses',                              7000000, 3, 1, 'Expense'),
    (7520000, N'Professional Services',                               7000000, 3, 1, 'Expense'),
    (7600000, N'Mission Expenses',                                    7000000, 3, 0, 'Expense'),
    (7695000, N'Other Mission Expenses',                              7600000, 4, 1, 'Expense'),
    (7696000, N'Vehicle Fuel',                                        7600000, 4, 1, 'Expense'),
    (7697000, N'Aircraft Fuel',                                       7600000, 4, 1, 'Expense'),
    (7700000, N'Supplies',                                            7000000, 3, 0, 'Expense'),
    (7700100, N'Supplies',                                            7700000, 4, 1, 'Expense'),
    (7701000, N'Cost of Sales',                                       7700000, 4, 1, 'Expense'),
    (7730000, N'Equipment Purchases',                                 7000000, 3, 0, 'Expense'),
    (7735000, N'Equipment',                                           7730000, 4, 1, 'Expense'),
    (7745000, N'Communication Equipment',                             7730000, 4, 1, 'Expense'),
    (7800000, N'Telephone and Communication',                         7000000, 3, 0, 'Expense'),
    (7810000, N'Telephone & Communication',                           7800000, 4, 1, 'Expense'),
    (7813000, N'Internet Fees',                                       7800000, 4, 1, 'Expense'),
    (7820000, N'IT Expenses',                                         7800000, 4, 1, 'Expense'),
    (7900000, N'Postage and Shipping',                                7000000, 3, 1, 'Expense'),
    (8000000, N'Occupancy Expenses',                                  7000000, 3, 0, 'Expense'),
    (8010000, N'Rent',                                                8000000, 4, 1, 'Expense'),
    (8015000, N'Utilities',                                           8000000, 4, 1, 'Expense'),
    (8016000, N'Property Taxes',                                      8000000, 4, 1, 'Expense'),
    (8020000, N'Contributed Facilities and Utilities',                8000000, 4, 1, 'Expense'),
    (8085000, N'Other Facility Expenditures',                         8000000, 4, 1, 'Expense'),
    (8100000, N'Maintenance Expenses',                                7000000, 3, 0, 'Expense'),
    (8110000, N'Aircraft Maintenance',                                8100000, 4, 1, 'Expense'),
    (8120000, N'Vehicle Maintenance',                                 8100000, 4, 1, 'Expense'),
    (8121000, N'Equipment Leases',                                    8100000, 4, 1, 'Expense'),
    (8123000, N'Other Equipment Maintenance',                         8100000, 4, 1, 'Expense'),
    (8230000, N'Dues & Publications',                                 7000000, 3, 1, 'Expense'),
    (8310000, N'Travel',                                              7000000, 3, 1, 'Expense'),
    (8400000, N'Activities and Encampments',                          7000000, 3, 0, 'Expense'),
    (8475000, N'Cadet Activities',                                    8400000, 4, 0, 'Expense'),
    (8475010, N'Encampment',                                          8475000, 5, 1, 'Expense'),
    (8475020, N'Activity 2',                                          8475000, 5, 1, 'Expense'),
    (8475030, N'Drug Demand Reduction',                               8475000, 5, 1, 'Expense'),
    (8475040, N'Glider Flights Expense',                              8475000, 5, 1, 'Expense'),
    (8475050, N'O-Rides Member Aircraft',                             8475000, 5, 1, 'Expense'),
    (8475060, N'IACE',                                                8475000, 5, 1, 'Expense'),
    (8476000, N'Senior Activities',                                   8400000, 4, 0, 'Expense'),
    (8476010, N'Activity 1',                                          8476000, 5, 1, 'Expense'),
    (8476020, N'Activity 2',                                          8476000, 5, 1, 'Expense'),
    (8476030, N'Activity 3',                                          8476000, 5, 1, 'Expense'),
    (8480000, N'Combined Senior & Cadet Activities',                  8400000, 4, 0, 'Expense'),
    (8480010, N'Activity 1',                                          8480000, 5, 1, 'Expense'),
    (8480020, N'Activity 2',                                          8480000, 5, 1, 'Expense'),
    (8505000, N'Conferences, Conventions and Meetings',               7000000, 3, 0, 'Expense'),
    (8510000, N'Wing Conference Expense',                             8505000, 4, 1, 'Expense'),
    (8530000, N'Miscellaneous Wing Events',                           8505000, 4, 1, 'Expense'),
    (8540000, N'Unit Events',                                         8505000, 4, 1, 'Expense'),
    (8650000, N'Depreciation Expense',                                7000000, 3, 0, 'Expense'),
    (8652000, N'Depreciation – Buildings & Improvements',             8650000, 4, 1, 'Expense'),
    (8653000, N'Depreciation – Furniture & Fixtures',                 8650000, 4, 1, 'Expense'),
    (8654000, N'Depreciation – Computers',                            8650000, 4, 1, 'Expense'),
    (8657000, N'Depreciation – Other Equipment',                      8650000, 4, 1, 'Expense'),
    (8665000, N'Depreciation – Capital Leases',                       8650000, 4, 1, 'Expense'),
    (8667000, N'Depreciation – Communications Equipment',             8650000, 4, 1, 'Expense'),
    (8700000, N'Insurance',                                           7000000, 3, 1, 'Expense'),
    (8820000, N'Professional Development',                            7000000, 3, 1, 'Expense'),
    (9100000, N'Bad Debt Expense',                                    7000000, 3, 1, 'Expense'),
    (9240000, N'Advertising',                                         7000000, 3, 1, 'Expense'),
    (9300000, N'Other Expenses',                                      7000000, 3, 0, 'Expense'),
    (9301000, N'Protocol Expenses (Region & Wing only)',              9300000, 4, 1, 'Expense'),
    (9302000, N'Miscellaneous',                                       9300000, 4, 1, 'Expense'),
    (9303000, N'Bank Expense',                                        9300000, 4, 1, 'Expense'),
    (9304000, N'Credit Card Expense',                                 9300000, 4, 1, 'Expense'),
    (9305000, N'Interest Expense',                                    9300000, 4, 1, 'Expense'),
    (9306000, N'Unrelated Business Income Expense',                   9300000, 4, 0, 'Expense'),
    (9306100, N'Fundraising Expenses',                                9306000, 5, 1, 'Expense'),
    (9306200, N'Raffle Expenses',                                     9306000, 5, 1, 'Expense'),
    (9306300, N'Lobbying Expenses',                                   9306000, 5, 1, 'Expense'),
    (9399999, N'Budgeted Reserves (for budget use only)',             7000000, 3, 1, 'Expense'),
    (9401000, N'Expenditures with NHQ',                               7000000, 3, 0, 'Expense'),
    (9401010, N'Membership Dues',                                     9401000, 4, 1, 'Expense'),
    (9401020, N'Consolidated Minor Maintenance',                      9401000, 4, 1, 'Expense'),
    (9401030, N'Property Assessments',                                9401000, 4, 1, 'Expense'),
    (9401040, N'National Activities',                                 9401000, 4, 1, 'Expense'),
    (9401050, N'Dennison Brothers Taxes',                             9401000, 4, 1, 'Expense'),
    (9401090, N'Miscellaneous',                                       9401000, 4, 1, 'Expense'),
    (9510000, N'Expenditures with Regions',                           7000000, 3, 0, 'Expense'),
    (9510010, N'Aircraft Maintenance',                                9510000, 4, 1, 'Expense'),
    (9510015, N'Aircraft Fuel',                                       9510000, 4, 1, 'Expense'),
    (9510020, N'Vehicle Maintenance',                                 9510000, 4, 1, 'Expense'),
    (9510025, N'Vehicle Fuel',                                        9510000, 4, 1, 'Expense'),
    (9510030, N'Mission Reimbursements',                              9510000, 4, 1, 'Expense'),
    (9510040, N'Membership Dues',                                     9510000, 4, 1, 'Expense'),
    (9510050, N'Website Hosting',                                     9510000, 4, 1, 'Expense'),
    (9510055, N'Region Activities',                                   9510000, 4, 1, 'Expense'),
    (9510060, N'Region Conference',                                   9510000, 4, 1, 'Expense'),
    (9510090, N'Miscellaneous',                                       9510000, 4, 1, 'Expense'),
    (9520000, N'Expenditures with Wings',                             7000000, 3, 0, 'Expense'),
    (9520010, N'Proficiency Flying',                                  9520000, 4, 1, 'Expense'),
    (9520015, N'Aircraft Fuel',                                       9520000, 4, 1, 'Expense'),
    (9520020, N'Vehicle Maintenance',                                 9520000, 4, 1, 'Expense'),
    (9520025, N'Vehicle Fuel',                                        9520000, 4, 1, 'Expense'),
    (9520030, N'Mission Reimbursements',                              9520000, 4, 1, 'Expense'),
    (9520040, N'Membership Dues',                                     9520000, 4, 1, 'Expense'),
    (9520050, N'Wing Conferences',                                    9520000, 4, 1, 'Expense'),
    (9520060, N'Encampment',                                          9520000, 4, 1, 'Expense'),
    (9520090, N'Miscellaneous',                                       9520000, 4, 1, 'Expense'),
    (9530000, N'Expenditures with Units Below',                       7000000, 3, 0, 'Expense'),
    (9530010, N'Proficiency Flying',                                  9530000, 4, 1, 'Expense'),
    (9530015, N'Aircraft Fuel',                                       9530000, 4, 1, 'Expense'),
    (9530020, N'Vehicle Maintenance',                                 9530000, 4, 1, 'Expense'),
    (9530025, N'Vehicle Fuel',                                        9530000, 4, 1, 'Expense'),
    (9530030, N'Mission Reimbursements',                              9530000, 4, 1, 'Expense'),
    (9530040, N'Membership Dues',                                     9530000, 4, 1, 'Expense'),
    (9530050, N'Encampment',                                          9530000, 4, 1, 'Expense'),
    (9530060, N'Scholarships',                                        9530000, 4, 1, 'Expense'),
    (9530070, N'Unit Activities',                                     9530000, 4, 1, 'Expense'),
    (9530090, N'Miscellaneous',                                       9530000, 4, 1, 'Expense');

GO

DECLARE @Postable TABLE (AccountNumber INT PRIMARY KEY, BaseValue DECIMAL(19,4));

INSERT @Postable (AccountNumber, BaseValue) VALUES
    (7120000,   1000.00),
    (7135000,   3000.00),
    (7210000, 142000.00),
    (7220000,   8500.00),
    (5050100,   2200.00),
    (5050200,   4800.00);

IF EXISTS (SELECT 1 FROM @Postable p
           WHERE NOT EXISTS (SELECT 1 FROM finance.ChartOfAccount c
                             WHERE c.AccountNumber = p.AccountNumber AND c.IsPostable = 1))
BEGIN
    SELECT  BadAccount = p.AccountNumber,
            Reason = CASE WHEN NOT EXISTS (SELECT 1 FROM finance.ChartOfAccount c
                                           WHERE c.AccountNumber = p.AccountNumber)
                          THEN 'Does not exist'
                          ELSE 'Exists but is a lead account and cannot take postings' END
    FROM @Postable p
    WHERE NOT EXISTS (SELECT 1 FROM finance.ChartOfAccount c
                      WHERE c.AccountNumber = p.AccountNumber AND c.IsPostable = 1);

    THROW 50902, 'Posting target list contains an account that is missing or not postable.', 1;
END

INSERT finance.BudgetEntry
    (ShipId, AccountNumber, PeriodKey, BudgetValue, CurrencyCode, Remarks, CreatedBy)
SELECT  s.ShipId,
        p.AccountNumber,
        ap.PeriodKey,
        CAST(p.BaseValue * (0.9 + (ABS(CHECKSUM(s.ShipId, p.AccountNumber, ap.PeriodKey)) % 21) / 100.0)
             AS DECIMAL(19,4)),
        'USD',
        N'Seeded budget',
        N'seed'
FROM fleet.Ship s
CROSS JOIN @Postable p
CROSS JOIN finance.AccountingPeriod ap
WHERE s.ShipId IN (1, 2, 3)
  AND ap.PeriodKey BETWEEN 202401 AND 202512
  AND ABS(CHECKSUM(s.ShipId, p.AccountNumber, ap.PeriodKey)) % 11 <> 0;

INSERT finance.AccountTransaction
    (ShipId, AccountNumber, PeriodKey, TransactionDate, ActualValue, CurrencyCode,
     VoucherReference, Description, CreatedBy)
SELECT  s.ShipId,
        p.AccountNumber,
        ap.PeriodKey,
        DATEADD(DAY, (ABS(CHECKSUM(s.ShipId, p.AccountNumber, ap.PeriodKey)) % 27), ap.PeriodStartDate),
        CASE WHEN ABS(CHECKSUM(ap.PeriodKey, p.AccountNumber, s.ShipId)) % 13 = 0
             THEN 0.00
             ELSE CAST(p.BaseValue * (0.75 + (ABS(CHECKSUM(ap.PeriodKey, s.ShipId, p.AccountNumber)) % 51) / 100.0)
                       AS DECIMAL(19,4))
        END,
        'USD',
        'VCH-' + FORMAT(s.ShipId, '00') + '-' + CAST(ap.PeriodKey AS VARCHAR(6))
               + '-' + CAST(p.AccountNumber AS VARCHAR(10)),
        N'Seeded actual',
        N'seed'
FROM fleet.Ship s
CROSS JOIN @Postable p
CROSS JOIN finance.AccountingPeriod ap
WHERE s.ShipId IN (1, 2, 3)
  AND ap.PeriodKey BETWEEN 202401 AND 202507
  AND ABS(CHECKSUM(s.ShipId, p.AccountNumber, ap.PeriodKey)) % 7 <> 0;

INSERT finance.AccountTransaction
    (ShipId, AccountNumber, PeriodKey, TransactionDate, ActualValue, CurrencyCode,
     VoucherReference, Description, CreatedBy)
SELECT  s.ShipId,
        p.AccountNumber,
        ap.PeriodKey,
        DATEADD(DAY, 20 + (ABS(CHECKSUM(p.AccountNumber, s.ShipId)) % 8), ap.PeriodStartDate),
        CAST(p.BaseValue * 0.15 AS DECIMAL(19,4)),
        'USD',
        'VCH-' + FORMAT(s.ShipId, '00') + '-' + CAST(ap.PeriodKey AS VARCHAR(6))
               + '-' + CAST(p.AccountNumber AS VARCHAR(10)) + '-B',
        N'Seeded supplementary actual',
        N'seed'
FROM fleet.Ship s
CROSS JOIN @Postable p
CROSS JOIN finance.AccountingPeriod ap
WHERE s.ShipId IN (1, 2, 3)
  AND ap.PeriodKey BETWEEN 202401 AND 202507
  AND ABS(CHECKSUM(s.ShipId, p.AccountNumber, ap.PeriodKey)) % 5 = 0;

GO

SELECT  Ships         = (SELECT COUNT(*) FROM fleet.Ship),
        Ranks         = (SELECT COUNT(*) FROM crew.CrewRank),
        CrewMembers   = (SELECT COUNT(*) FROM crew.CrewMember),
        Contracts     = (SELECT COUNT(*) FROM crew.CrewServiceHistory),
        Accounts      = (SELECT COUNT(*) FROM finance.ChartOfAccount),
        LeadAccounts  = (SELECT COUNT(*) FROM finance.ChartOfAccount WHERE IsPostable = 0),
        PostableAccts = (SELECT COUNT(*) FROM finance.ChartOfAccount WHERE IsPostable = 1),
        MaxCoaDepth   = (SELECT MAX(AccountLevel) FROM finance.ChartOfAccount),
        BudgetRows    = (SELECT COUNT(*) FROM finance.BudgetEntry),
        ActualRows    = (SELECT COUNT(*) FROM finance.AccountTransaction);

;WITH Derived AS
(
    SELECT AccountNumber, DerivedLevel = CAST(1 AS TINYINT)
    FROM finance.ChartOfAccount WHERE ParentAccountNumber IS NULL
    UNION ALL
    SELECT c.AccountNumber, CAST(d.DerivedLevel + 1 AS TINYINT)
    FROM finance.ChartOfAccount c
    JOIN Derived d ON d.AccountNumber = c.ParentAccountNumber
)
SELECT  Problem = 'AccountLevel does not match the parent chain',
        c.AccountNumber, c.AccountDescription,
        StoredLevel = c.AccountLevel, d.DerivedLevel
FROM finance.ChartOfAccount c
JOIN Derived d ON d.AccountNumber = c.AccountNumber
WHERE c.AccountLevel <> d.DerivedLevel
OPTION (MAXRECURSION 20);

SELECT  Problem = CASE WHEN c.IsPostable = 1
                       THEN 'Marked postable but has children'
                       ELSE 'Marked as a lead account but has no children' END,
        c.AccountNumber, c.AccountDescription, c.IsPostable
FROM finance.ChartOfAccount c
WHERE c.IsPostable = CASE WHEN EXISTS (SELECT 1 FROM finance.ChartOfAccount ch
                                       WHERE ch.ParentAccountNumber = c.AccountNumber)
                          THEN 1 ELSE 0 END
ORDER BY c.AccountNumber;

SELECT  AccountLevel,
        Accounts     = COUNT(*),
        LeadAccounts = SUM(CASE WHEN IsPostable = 0 THEN 1 ELSE 0 END),
        Postable     = SUM(CASE WHEN IsPostable = 1 THEN 1 ELSE 0 END)
FROM finance.ChartOfAccount
GROUP BY AccountLevel
ORDER BY AccountLevel;

SELECT  f.FiscalYearCode,
        f.Description,
        SelectedPeriod  = ap.PeriodCode,
        FiscalYearStart = (SELECT PeriodCode FROM finance.AccountingPeriod
                           WHERE PeriodKey = fy.FiscalYearStartKey)
FROM fleet.FiscalYearPattern f
CROSS JOIN (SELECT PeriodKey, PeriodCode FROM finance.AccountingPeriod
            WHERE PeriodCode IN ('2025-02', '2025-07')) ap
CROSS APPLY finance.GetFiscalYearStart(f.FiscalYearCode, ap.PeriodKey) fy
ORDER BY f.FiscalYearCode, ap.PeriodCode;

SELECT  s.DisplayId,
        s.ShipName,
        [Status] = CASE WHEN DATEDIFF(DAY, csh.EndOfContractDate, CAST(SYSUTCDATETIME() AS DATE)) > 30
                        THEN 'Relief Due' ELSE 'Onboard' END,
        Headcount = COUNT(*)
FROM crew.CrewServiceHistory csh
JOIN fleet.Ship s ON s.ShipId = csh.ShipId
WHERE csh.SignOffDate IS NULL
  AND csh.SignOnDate <= CAST(SYSUTCDATETIME() AS DATE)
GROUP BY s.DisplayId, s.ShipName,
         CASE WHEN DATEDIFF(DAY, csh.EndOfContractDate, CAST(SYSUTCDATETIME() AS DATE)) > 30
              THEN 'Relief Due' ELSE 'Onboard' END
ORDER BY s.DisplayId, [Status];

PRINT 'Seed data loaded.';
GO

