USE Gym;
GO

IF OBJECT_ID('dbo.enrollsin', 'U') IS NOT NULL DROP TABLE dbo.enrollsin;
IF OBJECT_ID('dbo.trainercertificate', 'U') IS NOT NULL DROP TABLE dbo.trainercertificate;
IF OBJECT_ID('dbo.trainerphoneno', 'U') IS NOT NULL DROP TABLE dbo.trainerphoneno;
IF OBJECT_ID('dbo.Memberphoneno', 'U') IS NOT NULL DROP TABLE dbo.Memberphoneno;
IF OBJECT_ID('dbo.Classdate', 'U') IS NOT NULL DROP TABLE dbo.Classdate;
IF OBJECT_ID('dbo.Payment', 'U') IS NOT NULL DROP TABLE dbo.Payment;
IF OBJECT_ID('dbo.Subscription', 'U') IS NOT NULL DROP TABLE dbo.Subscription;
IF OBJECT_ID('dbo.trainingplan', 'U') IS NOT NULL DROP TABLE dbo.trainingplan;
IF OBJECT_ID('dbo.Memberr', 'U') IS NOT NULL DROP TABLE dbo.Memberr;
IF OBJECT_ID('dbo.Class', 'U') IS NOT NULL DROP TABLE dbo.Class;
IF OBJECT_ID('dbo.membership', 'U') IS NOT NULL DROP TABLE dbo.membership;
IF OBJECT_ID('dbo.trainer', 'U') IS NOT NULL DROP TABLE dbo.trainer;
IF OBJECT_ID('dbo.ClassDifficulty', 'U') IS NOT NULL DROP TABLE dbo.ClassDifficulty;
IF OBJECT_ID('dbo.Membershiptype', 'U') IS NOT NULL DROP TABLE dbo.Membershiptype;
GO

CREATE TABLE Membershiptype (
    membershiptype VARCHAR(50) PRIMARY KEY,  
    price INT
);

CREATE TABLE ClassDifficulty (
    classdifficulty VARCHAR(100) PRIMARY KEY,
    classduration INT
);

CREATE TABLE trainer (
    trainerid INT IDENTITY(1,1) PRIMARY KEY, 
    trainerfname VARCHAR(50),
    trainermname VARCHAR(50),
    trainerlname VARCHAR(50),
    sex VARCHAR(50),
    workhours INT
);

CREATE TABLE membership (
    membershipid INT IDENTITY(1,1) PRIMARY KEY, 
    membershipdesc VARCHAR(100),
    membershiptype VARCHAR(50),
    FOREIGN KEY (membershiptype) REFERENCES Membershiptype(membershiptype)
);

CREATE TABLE Class (
    classid INT IDENTITY(1,1) PRIMARY KEY, 
    classname VARCHAR(100),
    classtype VARCHAR(100),
    trainerid INT,
    classdifficulty VARCHAR(100),
    FOREIGN KEY (classdifficulty) REFERENCES ClassDifficulty(classdifficulty),
    FOREIGN KEY (trainerid) REFERENCES trainer(trainerid)
);

CREATE TABLE Memberr (
    memberid INT IDENTITY(1,1) PRIMARY KEY, 
    fname VARCHAR(100),
    lname VARCHAR(100),
    sex VARCHAR(50),
    dateofbirth DATE,
    trainerid INT,
    planid INT,
    FOREIGN KEY (trainerid) REFERENCES trainer(trainerid)
);

CREATE TABLE trainingplan (
    planid INT IDENTITY(1,1) PRIMARY KEY, 
    dietplan VARCHAR(400),
    workoutplan VARCHAR(500),
    memberid INT,
    trainerid INT,
    FOREIGN KEY (memberid) REFERENCES Memberr(memberid),
    FOREIGN KEY (trainerid) REFERENCES trainer(trainerid)
);

CREATE TABLE Subscription (
    subscribid INT IDENTITY(1,1) PRIMARY KEY, 
    startdate DATE,
    enddate DATE,
    statuss VARCHAR(100),
    memberid INT,
    membershipid INT,
    FOREIGN KEY (memberid) REFERENCES Memberr(memberid),
    FOREIGN KEY (membershipid) REFERENCES membership(membershipid)
);

CREATE TABLE Payment (
    paymentid INT IDENTITY(1,1) PRIMARY KEY,
    paymenttype VARCHAR(50),
    paymentamount DECIMAL(10,2),
    paymentdate DATE,
    memberid INT,
    subscribid INT UNIQUE,
    FOREIGN KEY (memberid) REFERENCES Memberr(memberid),
    FOREIGN KEY (subscribid) REFERENCES Subscription(subscribid)
);

CREATE TABLE Classdate (
    classid INT,
    classdate DATE,
    PRIMARY KEY(classid, classdate),          
    FOREIGN KEY (classid) REFERENCES Class(classid)
);

CREATE TABLE Memberphoneno (
    memberid INT,
    memberphoneno VARCHAR(11),
    PRIMARY KEY(memberid, memberphoneno),   
    FOREIGN KEY (memberid) REFERENCES Memberr(memberid)
);

CREATE TABLE trainerphoneno (
    trainerid INT,
    phoneno VARCHAR(11),
    PRIMARY KEY(trainerid, phoneno),          
    FOREIGN KEY (trainerid) REFERENCES trainer(trainerid)
);

CREATE TABLE trainercertificate (
    trainerid INT,
    certificatess VARCHAR(400),
    PRIMARY KEY(trainerid, certificatess),    
    FOREIGN KEY (trainerid) REFERENCES trainer(trainerid)
);

CREATE TABLE enrollsin (
    classid INT,
    memberid INT,
    PRIMARY KEY(classid, memberid),          
    FOREIGN KEY (classid) REFERENCES Class(classid),
    FOREIGN KEY (memberid) REFERENCES Memberr(memberid)
);
GO

CREATE OR ALTER FUNCTION DaysUntilExpiry()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        Subscription.subscribid,                                          
        Memberr.fname + ' ' + Memberr.lname AS MemberName,
        Subscription.startdate,
        Subscription.enddate,
        Subscription.statuss,
        DATEDIFF(DAY, GETDATE(), Subscription.enddate) AS DaysUntilExpiry
    FROM Subscription
    INNER JOIN Memberr ON Subscription.memberid = Memberr.memberid
);
GO

CREATE OR ALTER FUNCTION fn_FilterClasses
(
    @ClassType       VARCHAR(100) = NULL,
    @ClassDate       DATE         = NULL,
    @ClassDifficulty VARCHAR(100) = NULL
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        Class.classid,
        Class.classname,
        Class.classtype,
        Class.classdifficulty,
        Classdate.classdate
    FROM Class 
    JOIN Classdate ON Class.classid = Classdate.classid
    WHERE
        (@ClassType IS NULL OR Class.classtype = @ClassType)
        AND (@ClassDate IS NULL OR Classdate.classdate = @ClassDate)
        AND (@ClassDifficulty IS NULL OR Class.classdifficulty = @ClassDifficulty)
);
GO

CREATE OR ALTER PROCEDURE sp_Insert_MembershipType
    @Type   VARCHAR(50),
    @Price  INT
AS
BEGIN
    INSERT INTO Membershiptype (membershiptype, price)
    VALUES (@Type, @Price);
END;
GO

CREATE OR ALTER PROCEDURE sp_Insert_ClassDifficulty
    @Difficulty  VARCHAR(100),
    @Duration    INT
AS
BEGIN
    INSERT INTO ClassDifficulty (classdifficulty, classduration)
    VALUES (@Difficulty, @Duration);
END;
GO

CREATE OR ALTER PROCEDURE sp_Insert_Trainer
    @Fname      VARCHAR(50),
    @Mname      VARCHAR(50),
    @Lname      VARCHAR(50),
    @Sex        VARCHAR(50),
    @WorkHours  INT
AS
BEGIN
    INSERT INTO trainer (trainerfname, trainermname, trainerlname, sex, workhours)
    VALUES (@Fname, @Mname, @Lname, @Sex, @WorkHours);
END;
GO

CREATE OR ALTER PROCEDURE sp_Insert_Membership
    @Desc   VARCHAR(100),
    @Type   VARCHAR(50)
AS
BEGIN
    INSERT INTO membership (membershipdesc, membershiptype)
    VALUES (@Desc, @Type);
END;
GO

CREATE OR ALTER PROCEDURE sp_Insert_Class
    @ClassName   VARCHAR(100),
    @ClassType   VARCHAR(100),
    @TrainerID   INT,
    @Difficulty  VARCHAR(100)
AS
BEGIN
    INSERT INTO Class (classname, classtype, trainerid, classdifficulty)
    VALUES (@ClassName, @ClassType, @TrainerID, @Difficulty);
END;
GO

CREATE OR ALTER PROCEDURE sp_Insert_Member
    @Fname      VARCHAR(100),
    @Lname      VARCHAR(100),
    @Sex        VARCHAR(50),
    @DOB        DATE,
    @TrainerID  INT,
    @PlanID     INT
AS
BEGIN
    INSERT INTO Memberr (fname, lname, sex, dateofbirth, trainerid, planid)
    VALUES (@Fname, @Lname, @Sex, @DOB, @TrainerID, @PlanID);
END;
GO

CREATE OR ALTER PROCEDURE sp_Insert_TrainingPlan
    @DietPlan   VARCHAR(400),
    @Workout    VARCHAR(500),
    @MemberID   INT = NULL,
    @TrainerID  INT = NULL
AS
BEGIN
    INSERT INTO trainingplan (dietplan, workoutplan, memberid, trainerid)
    VALUES (@DietPlan, @Workout, @MemberID, @TrainerID);
END;
GO

CREATE OR ALTER PROCEDURE sp_Insert_Subscription
    @StartDate     DATE,
    @EndDate       DATE,
    @Status        VARCHAR(100),
    @MemberID      INT,
    @MembershipID  INT
AS
BEGIN
    INSERT INTO Subscription (startdate, enddate, statuss, memberid, membershipid)
    VALUES (@StartDate, @EndDate, @Status, @MemberID, @MembershipID);
END;
GO

CREATE OR ALTER PROCEDURE sp_Insert_Payment
    @PaymentType   VARCHAR(50),
    @Amount        DECIMAL(10,2),
    @PaymentDate   DATE,
    @MemberID      INT,
    @SubscribID    INT
AS
BEGIN
    INSERT INTO Payment (paymenttype, paymentamount, paymentdate, memberid, subscribid)
    VALUES (@PaymentType, @Amount, @PaymentDate, @MemberID, @SubscribID);
END;
GO

CREATE OR ALTER PROCEDURE sp_Insert_ClassDate
    @ClassID    INT,
    @ClassDate  DATE
AS
BEGIN
    INSERT INTO Classdate (classid, classdate)
    VALUES (@ClassID, @ClassDate);
END;
GO

CREATE OR ALTER PROCEDURE sp_Insert_MemberPhoneNo
    @MemberID  INT,
    @PhoneNo   VARCHAR(11)
AS
BEGIN
    INSERT INTO Memberphoneno (memberid, memberphoneno)
    VALUES (@MemberID, @PhoneNo);
END;
GO

CREATE OR ALTER PROCEDURE sp_Insert_TrainerPhoneNo
    @TrainerID  INT,
    @PhoneNo    VARCHAR(11)
AS
BEGIN
    INSERT INTO trainerphoneno (trainerid, phoneno)
    VALUES (@TrainerID, @PhoneNo);
END;
GO

CREATE OR ALTER PROCEDURE sp_Insert_TrainerCertificate
    @TrainerID   INT,
    @Certificate VARCHAR(400)
AS
BEGIN
    INSERT INTO trainercertificate (trainerid, certificatess)
    VALUES (@TrainerID, @Certificate);
END;
GO

CREATE OR ALTER PROCEDURE sp_Insert_EnrollsIn
    @ClassID   INT,
    @MemberID  INT
AS
BEGIN
    INSERT INTO enrollsin (classid, memberid)
    VALUES (@ClassID, @MemberID);
END;
GO

CREATE OR ALTER PROCEDURE sp_Update_MembershipType
    @Type      VARCHAR(50),
    @NewPrice  INT
AS
BEGIN
    UPDATE Membershiptype
    SET price = @NewPrice
    WHERE membershiptype = @Type;
END;
GO

CREATE OR ALTER PROCEDURE sp_Update_ClassDifficulty
    @Difficulty   VARCHAR(100),
    @NewDuration  INT
AS
BEGIN
    UPDATE ClassDifficulty
    SET classduration = @NewDuration
    WHERE classdifficulty = @Difficulty;
END;
GO

CREATE OR ALTER PROCEDURE sp_Update_Trainer
    @TrainerID    INT,
    @NewFname     VARCHAR(50)  = NULL,
    @NewMname     VARCHAR(50)  = NULL,
    @NewLname     VARCHAR(50)  = NULL,
    @NewSex       VARCHAR(50)  = NULL,
    @NewWorkHours INT          = NULL
AS
BEGIN
    UPDATE trainer
    SET
        trainerfname = ISNULL(@NewFname,     trainerfname),
        trainermname = ISNULL(@NewMname,     trainermname),
        trainerlname = ISNULL(@NewLname,     trainerlname),
        sex          = ISNULL(@NewSex,       sex),
        workhours    = ISNULL(@NewWorkHours, workhours)
    WHERE trainerid = @TrainerID;
END;
GO

CREATE OR ALTER PROCEDURE sp_Update_Membership
    @MembershipID  INT,
    @NewDesc       VARCHAR(100) = NULL,
    @NewType       VARCHAR(50)  = NULL
AS
BEGIN
    UPDATE membership
    SET
        membershipdesc = ISNULL(@NewDesc, membershipdesc),
        membershiptype = ISNULL(@NewType, membershiptype)
    WHERE membershipid = @MembershipID;
END;
GO

CREATE OR ALTER PROCEDURE sp_Update_Class
    @ClassID       INT,
    @NewClassName  VARCHAR(100) = NULL,
    @NewClassType  VARCHAR(100) = NULL,
    @NewTrainerID  INT          = NULL,
    @NewDifficulty VARCHAR(100) = NULL
AS
BEGIN
    UPDATE Class
    SET
        classname       = ISNULL(@NewClassName,  classname),
        classtype       = ISNULL(@NewClassType,  classtype),
        trainerid       = ISNULL(@NewTrainerID,  trainerid),
        classdifficulty = ISNULL(@NewDifficulty, classdifficulty)
    WHERE classid = @ClassID;
END;
GO

CREATE OR ALTER PROCEDURE sp_Update_Member
    @MemberID     INT,
    @NewFname     VARCHAR(100) = NULL,
    @NewLname     VARCHAR(100) = NULL,
    @NewSex       VARCHAR(50)  = NULL,
    @NewDOB       DATE         = NULL,
    @NewTrainerID INT          = NULL,
    @NewPlanID    INT          = NULL
AS
BEGIN
    UPDATE Memberr
    SET
        fname       = ISNULL(@NewFname,     fname),
        lname       = ISNULL(@NewLname,     lname),
        sex         = ISNULL(@NewSex,       sex),
        dateofbirth = ISNULL(@NewDOB,       dateofbirth),
        trainerid   = ISNULL(@NewTrainerID, trainerid),
        planid      = ISNULL(@NewPlanID,    planid)
    WHERE memberid = @MemberID;
END;
GO

CREATE OR ALTER PROCEDURE sp_Update_TrainingPlan
    @PlanID      INT,
    @NewDietPlan VARCHAR(400) = NULL,
    @NewWorkout  VARCHAR(500) = NULL,
    @NewMemberID INT          = NULL,
    @NewTrainerID INT         = NULL
AS
BEGIN
    UPDATE trainingplan
    SET
        dietplan    = ISNULL(@NewDietPlan,  dietplan),
        workoutplan = ISNULL(@NewWorkout,   workoutplan),
        memberid    = ISNULL(@NewMemberID,  memberid),
        trainerid   = ISNULL(@NewTrainerID, trainerid)
    WHERE planid = @PlanID;
END;
GO

CREATE OR ALTER PROCEDURE sp_Update_Subscription
    @SubID           INT,
    @NewStartDate    DATE         = NULL,
    @NewEndDate      DATE         = NULL,
    @NewStatus       VARCHAR(100) = NULL,
    @NewMemberID     INT          = NULL,
    @NewMembershipID INT          = NULL
AS
BEGIN
    UPDATE Subscription
    SET
        startdate    = ISNULL(@NewStartDate,    startdate),
        enddate      = ISNULL(@NewEndDate,      enddate),
        statuss      = ISNULL(@NewStatus,       statuss),
        memberid     = ISNULL(@NewMemberID,     memberid),
        membershipid = ISNULL(@NewMembershipID, membershipid)
    WHERE subscribid = @SubID;
END;
GO

CREATE OR ALTER PROCEDURE sp_Update_Payment
    @PaymentID      INT,
    @NewPaymentType VARCHAR(50)   = NULL,
    @NewAmount      DECIMAL(10,2) = NULL,
    @NewDate        DATE          = NULL,
    @NewMemberID    INT           = NULL,
    @NewSubscribID  INT           = NULL
AS
BEGIN
    UPDATE Payment
    SET
        paymenttype   = ISNULL(@NewPaymentType, paymenttype),
        paymentamount = ISNULL(@NewAmount,      paymentamount),
        paymentdate   = ISNULL(@NewDate,        paymentdate),
        memberid      = ISNULL(@NewMemberID,    memberid),
        subscribid    = ISNULL(@NewSubscribID,  subscribid)
    WHERE paymentid = @PaymentID;
END;
GO

CREATE OR ALTER PROCEDURE sp_Update_ClassDate
    @ClassID  INT,
    @OldDate  DATE,
    @NewDate  DATE
AS
BEGIN
    UPDATE Classdate
    SET classdate = @NewDate
    WHERE classid = @ClassID AND classdate = @OldDate;
END;
GO

CREATE OR ALTER PROCEDURE sp_Update_MemberPhoneNo
    @MemberID  INT,
    @OldPhone  VARCHAR(11),
    @NewPhone  VARCHAR(11)
AS
BEGIN
    UPDATE Memberphoneno
    SET memberphoneno = @NewPhone
    WHERE memberid = @MemberID AND memberphoneno = @OldPhone;
END;
GO

CREATE OR ALTER PROCEDURE sp_Update_TrainerPhoneNo
    @TrainerID  INT,
    @OldPhone   VARCHAR(11),
    @NewPhone   VARCHAR(11)
AS
BEGIN
    UPDATE trainerphoneno
    SET phoneno = @NewPhone
    WHERE trainerid = @TrainerID AND phoneno = @OldPhone;
END;
GO

CREATE OR ALTER PROCEDURE sp_Update_TrainerCertificate
    @TrainerID      INT,
    @OldCertificate VARCHAR(400),
    @NewCertificate VARCHAR(400)
AS
BEGIN
    UPDATE trainercertificate
    SET certificatess = @NewCertificate
    WHERE trainerid = @TrainerID AND certificatess = @OldCertificate;
END;
GO

CREATE OR ALTER PROCEDURE DeleteFromTable
    @TableName VARCHAR(50),
    @IDValue   VARCHAR(100)
AS
BEGIN
    IF @TableName = 'Memberr'
    BEGIN
        DELETE FROM enrollsin      WHERE memberid = CAST(@IDValue AS INT);
        DELETE FROM Memberphoneno  WHERE memberid = CAST(@IDValue AS INT);
        DELETE FROM Payment        WHERE memberid = CAST(@IDValue AS INT);
        DELETE FROM Subscription   WHERE memberid = CAST(@IDValue AS INT);
        DELETE FROM trainingplan   WHERE memberid = CAST(@IDValue AS INT);
        DELETE FROM Memberr        WHERE memberid = CAST(@IDValue AS INT);
    END
    ELSE IF @TableName = 'trainer'
    BEGIN
        DELETE FROM trainerphoneno     WHERE trainerid = CAST(@IDValue AS INT);
        DELETE FROM trainercertificate WHERE trainerid = CAST(@IDValue AS INT);
        DELETE FROM enrollsin          WHERE classid IN (SELECT classid FROM Class WHERE trainerid = CAST(@IDValue AS INT));
        DELETE FROM Classdate          WHERE classid IN (SELECT classid FROM Class WHERE trainerid = CAST(@IDValue AS INT));
        DELETE FROM Class              WHERE trainerid = CAST(@IDValue AS INT);
        DELETE FROM trainingplan       WHERE trainerid = CAST(@IDValue AS INT);
        DELETE FROM trainer            WHERE trainerid = CAST(@IDValue AS INT);
    END
    ELSE IF @TableName = 'Class'
    BEGIN
        DELETE FROM enrollsin WHERE classid = CAST(@IDValue AS INT);
        DELETE FROM Classdate WHERE classid = CAST(@IDValue AS INT);
        DELETE FROM Class     WHERE classid = CAST(@IDValue AS INT);
    END
    ELSE IF @TableName = 'membership'
    BEGIN
        DELETE FROM Payment WHERE subscribid IN (
            SELECT subscribid FROM Subscription WHERE membershipid = CAST(@IDValue AS INT));
        DELETE FROM Subscription WHERE membershipid = CAST(@IDValue AS INT);
        DELETE FROM membership   WHERE membershipid = CAST(@IDValue AS INT);
    END
    ELSE IF @TableName = 'Payment'
        DELETE FROM Payment WHERE paymentid = CAST(@IDValue AS INT);
    ELSE IF @TableName = 'Subscription'
    BEGIN
        DELETE FROM Payment      WHERE subscribid = CAST(@IDValue AS INT);
        DELETE FROM Subscription WHERE subscribid = CAST(@IDValue AS INT);
    END
    ELSE IF @TableName = 'trainingplan'
        DELETE FROM trainingplan WHERE planid = CAST(@IDValue AS INT);
    ELSE IF @TableName = 'Membershiptype'
    BEGIN
        DELETE FROM Payment WHERE subscribid IN (
            SELECT subscribid FROM Subscription WHERE membershipid IN (
                SELECT membershipid FROM membership WHERE membershiptype = @IDValue));
        DELETE FROM Subscription WHERE membershipid IN (
            SELECT membershipid FROM membership WHERE membershiptype = @IDValue);
        DELETE FROM membership     WHERE membershiptype = @IDValue;
        DELETE FROM Membershiptype WHERE membershiptype = @IDValue;
    END
    ELSE IF @TableName = 'ClassDifficulty'
    BEGIN
        DELETE FROM enrollsin       WHERE classid IN (SELECT classid FROM Class WHERE classdifficulty = @IDValue);
        DELETE FROM Classdate       WHERE classid IN (SELECT classid FROM Class WHERE classdifficulty = @IDValue);
        DELETE FROM Class           WHERE classdifficulty = @IDValue;
        DELETE FROM ClassDifficulty WHERE classdifficulty = @IDValue;
    END
    ELSE IF @TableName = 'Classdate'
        DELETE FROM Classdate
        WHERE classid   = CAST(PARSENAME(REPLACE(@IDValue,',','.'),2) AS INT)
        AND   classdate = CAST(PARSENAME(REPLACE(@IDValue,',','.'),1) AS DATE);
    ELSE IF @TableName = 'Memberphoneno'
        DELETE FROM Memberphoneno
        WHERE memberid      = CAST(PARSENAME(REPLACE(@IDValue,',','.'),2) AS INT)
        AND   memberphoneno = PARSENAME(REPLACE(@IDValue,',','.'),1);
    ELSE IF @TableName = 'trainerphoneno'
        DELETE FROM trainerphoneno
        WHERE trainerid = CAST(PARSENAME(REPLACE(@IDValue,',','.'),2) AS INT)
        AND   phoneno   = PARSENAME(REPLACE(@IDValue,',','.'),1);
    ELSE IF @TableName = 'trainercertificate'
        DELETE FROM trainercertificate
        WHERE trainerid     = CAST(PARSENAME(REPLACE(@IDValue,',','.'),2) AS INT)
        AND   certificatess = PARSENAME(REPLACE(@IDValue,',','.'),1);
    ELSE IF @TableName = 'enrollsin'
        DELETE FROM enrollsin
        WHERE classid  = CAST(PARSENAME(REPLACE(@IDValue,',','.'),2) AS INT)
        AND   memberid = CAST(PARSENAME(REPLACE(@IDValue,',','.'),1) AS INT);
END;
GO

INSERT INTO Membershiptype VALUES
('Monthly', 500), ('Quarterly', 1200), ('Yearly', 4000), ('VIP', 7000);

INSERT INTO ClassDifficulty VALUES
('Beginner', 60), ('Intermediate', 75), ('Advanced', 90), ('Expert', 120);

INSERT INTO trainer (trainerfname, trainermname, trainerlname, sex, workhours) VALUES
('Ahmed', 'Ali', 'Hassan', 'Male', 40),
('Sara', 'Ibrahim', 'Mahmoud', 'Female', 35),
('Omar', 'Khaled', 'Youssef', 'Male', 45),
('Mona', 'Adel', 'Samir', 'Female', 30),
('Khaled', 'Nabil', 'Fathy', 'Male', 50),
('Hana', 'Tarek', 'Lotfy', 'Female', 38),
('Youssef', 'Magdy', 'Essam', 'Male', 42),
('Laila', 'Sameh', 'Nasser', 'Female', 36),
('Karim', 'Hossam', 'Fouad', 'Male', 44),
('Nadine', 'Sherif', 'Raouf', 'Female', 33);

INSERT INTO membership (membershipdesc, membershiptype) VALUES
('Basic Monthly', 'Monthly'),
('Quarter Plan', 'Quarterly'),
('Annual Plan', 'Yearly'),
('VIP Full Access', 'VIP');

INSERT INTO Class (classname, classtype, trainerid, classdifficulty) VALUES
('Yoga', 'Fitness', 2, 'Beginner'),
('CrossFit', 'Strength', 5, 'Advanced'),
('Cardio Blast', 'Cardio', 3, 'Intermediate'),
('Pilates', 'Fitness', 4, 'Beginner'),
('HIIT', 'Cardio', 6, 'Advanced'),
('Bodybuilding', 'Strength', 1, 'Expert'),
('Zumba', 'Dance', 8, 'Beginner'),
('Boxing', 'Combat', 9, 'Intermediate'),
('Stretching', 'Recovery', 10, 'Beginner'),
('Powerlifting', 'Strength', 7, 'Expert');

INSERT INTO trainingplan (dietplan, workoutplan, memberid, trainerid) VALUES
('Low carb', 'Fat loss', NULL, 1),
('High protein', 'Muscle gain', NULL, 2),
('Balanced diet', 'General fitness', NULL, 3),
('Keto diet', 'Weight loss', NULL, 4),
('Vegan diet', 'Lean body', NULL, 5),
('Athlete diet', 'Performance', NULL, 6),
('Mediterranean', 'Health', NULL, 7),
('Low sugar', 'Cardio fitness', NULL, 8),
('Bulking diet', 'Mass gain', NULL, 9),
('Cutting diet', 'Shredding', NULL, 10);

INSERT INTO Memberr (fname, lname, sex, dateofbirth, trainerid, planid) VALUES
('Maya', 'Hany', 'Female', '2003-05-10', 1, 1),
('Jana', 'Gohary', 'Female', '2000-08-15', 2, 2),
('Nathalie', 'david', 'Female', '1998-12-01', 3, 3),
('Ola', 'Khaled', 'Female', '1999-03-11', 4, 4),
('Hassan', 'Ali', 'Male', '1995-07-20', 5, 5),
('Yara', 'Tamer', 'Female', '2001-06-25', 6, 6),
('Ziad', 'Amr', 'Male', '1997-09-17', 7, 7),
('Salma', 'Nabil', 'Female', '2002-01-30', 8, 8),
('Youssef', 'Shawky', 'Male', '1996-11-05', 9, 9),
('Farah', 'Hossam', 'Female', '2004-02-14', 10, 10),
('Amr', 'Wael', 'Male', '1993-04-22', 1, 1),
('Dina', 'Ashraf', 'Female', '1998-07-18', 2, 2),
('Tarek', 'Fathy', 'Male', '1992-12-09', 3, 3),
('Nada', 'Sherif', 'Female', '2000-05-05', 4, 4),
('Yehia', 'Youssry', 'Male', '1991-08-13', 5, 5),
('Reem', 'Magdy', 'Female', '1999-09-21', 6, 6),
('Youssef', 'Ahmed', 'Male', '1997-10-10', 7, 7),
('Huda', 'Sameh', 'Female', '2003-03-03', 8, 8),
('Omar', 'Fouad', 'Male', '1995-06-06', 9, 9),
('Nourhan', 'Raouf', 'Female', '2002-12-12', 10, 10);

INSERT INTO Subscription (startdate, enddate, statuss, memberid, membershipid) VALUES
('2026-01-01', '2026-02-01', 'Expired', 1, 1),
('2026-02-01', '2027-05-01', 'Active', 2, 2),
('2026-03-01', '2027-03-01', 'Active', 3, 3),
('2026-01-15', '2027-01-15', 'Active', 4, 4),
('2026-02-10', '2026-03-10', 'Expired', 5, 1),
('2026-03-12', '2027-06-12', 'Active', 6, 2),
('2026-04-01', '2027-04-01', 'Active', 7, 3),
('2026-04-05', '2026-05-05', 'Cancelled', 8, 1),
('2026-04-10', '2027-05-10', 'Active', 9, 1),
('2026-04-12', '2027-07-12', 'Active', 10, 2),
('2026-04-15', '2027-04-15', 'Active', 11, 3),
('2026-04-18', '2027-04-18', 'Active', 12, 4),
('2026-04-20', '2026-05-20', 'Expired', 13, 1),
('2026-04-22', '2026-07-22', 'Cancelled', 14, 2),
('2026-04-25', '2028-04-25', 'Active', 15, 3),
('2026-04-27', '2027-04-27', 'Active', 16, 4),
('2026-04-28', '2026-05-28', 'Expired', 17, 1),
('2026-04-29', '2027-07-29', 'Active', 18, 2),
('2026-04-30', '2027-04-30', 'Active', 19, 3),
('2026-05-01', '2027-05-01', 'Active', 20, 4);

INSERT INTO Payment VALUES
('Cash', 500, '2026-01-01', 1, 1),
('Card', 1200, '2026-02-01', 2, 2),
('Cash', 4000, '2026-03-01', 3, 3),
('Card', 7000, '2026-01-15', 4, 4),
('Cash', 500, '2026-02-10', 5, 5),
('Card', 1200, '2026-03-12', 6, 6),
('Cash', 4000, '2026-04-01', 7, 7),
('Card', 500, '2026-04-05', 8, 8),
('Cash', 1200, '2026-04-06', 9, 9),
('Card', 7000, '2026-04-07', 10, 10),
('Cash', 500, '2026-04-10', 11, 11),
('Card', 1200, '2026-04-11', 12, 12),
('Cash', 4000, '2026-04-12', 13, 13),
('Card', 7000, '2026-04-13', 14, 14),
('Cash', 500, '2026-04-14', 15, 15),
('Card', 1200, '2026-04-15', 16, 16),
('Cash', 4000, '2026-04-16', 17, 17),
('Card', 500, '2026-04-17', 18, 18),
('Cash', 1200, '2026-04-18', 19, 19),
('Card', 7000, '2026-04-19', 20, 20);

INSERT INTO enrollsin VALUES
(2, 1), (3, 1), (4, 2), (5, 2), (6, 3), (7, 3), (8, 4), (9, 4),
(10, 5), (1, 6), (2, 7), (3, 8), (4, 9), (5, 10),
(6, 11), (7, 12), (8, 13), (9, 14), (10, 15),
(1, 16), (2, 17), (3, 18), (4, 19), (5, 20);

INSERT INTO Memberphoneno VALUES
(1, '01017411385'), (1, '01126117341'), (2, '01022582712'),
(3, '01095332733'), (4, '01046433844'), (5, '01053697553'),
(6, '01011112222'), (7, '01022223333'), (8, '01033334444'),
(9, '01044445555'), (10, '01055556666'), (11, '01066667777'),
(12, '01077778888'), (13, '01088889999'), (14, '01099990001'),
(15, '01100001111'), (16, '01111112222'), (17, '01122223333'),
(18, '01133334444'), (19, '01144445555'), (20, '01155556666');

INSERT INTO trainercertificate VALUES
(1, 'Fitness Diploma'), (2, 'Yoga Certification'), (3, 'Cardio Specialist'),
(4, 'Pilates Instructor'), (5, 'Strength Training Expert'), (6, 'HIIT Coach'),
(7, 'Powerlifting Coach'), (8, 'Zumba Trainer'), (9, 'Boxing Coach'),
(10, 'Rehabilitation Specialist');

INSERT INTO trainerphoneno VALUES
(1, '01274500871'), (2, '01202864002'), (3, '01222079973'),
(4, '01099700004'), (5, '01209786005'), (6, '01208854006'),
(7, '01209873447'), (8, '01204465708'), (9, '01200000009'),
(10, '01200000010');

INSERT INTO Classdate VALUES
(1, '2026-05-01'), (2, '2026-05-02'), (3, '2026-05-03'),
(4, '2026-05-04'), (5, '2026-05-05'), (6, '2026-05-06'),
(7, '2026-05-07'), (8, '2026-05-08'), (9, '2026-05-09'),
(10, '2026-05-10');
GO

SELECT 
    d.MemberName AS [Member Name], 
    d.statuss AS [Subscription Status], 
    d.DaysUntilExpiry AS [Days to expire]
FROM [dbo].[DaysUntilExpiry]() d
ORDER BY d.DaysUntilExpiry DESC;

SELECT 
    c.classname, 
    cd.classdate
FROM Class c
JOIN Classdate cd ON c.classid = cd.classid
ORDER BY cd.classdate;

SELECT 
    t.trainerfname + ' ' + t.trainerlname AS [Trainer name], 
    COUNT(m.memberid) AS [Members]
FROM trainer t
JOIN Memberr m ON m.trainerid = t.trainerid
GROUP BY t.trainerfname, t.trainerlname;

SELECT 
    fname + ' ' + lname AS [Members not enrolled in classes]
FROM Memberr
WHERE memberid NOT IN (SELECT memberid FROM enrollsin);

SELECT 
    classname AS [Class Name], 
    classdifficulty AS [Class Difficulty] 
FROM Class
ORDER BY classdifficulty DESC;
GO
