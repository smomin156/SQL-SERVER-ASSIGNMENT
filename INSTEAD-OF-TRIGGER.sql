ALTER VIEW EMPDEP_VIEW AS
	SELECT E.EMPNO,E.ENAME,E.SAL,D.DNAME
	FROM EMP E JOIN DEPT D ON E.DEPTNO=D.DEPTNO

SELECT * FROM EMPDEP_VIEW

--INSERT
ALTER TRIGGER INSERT_VIEW
ON EMPDEP_VIEW
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @DNO INT
	SELECT @DNO=D.DEPTNO
	FROM DEPT D JOIN INSERTED I 
	ON D.DNAME=I.DNAME

	IF(@DNO IS NULL)
	BEGIN
		RAISERROR('DEPT NO NOT EXISTS',16,1)
		RETURN
	END

	INSERT INTO EMP(EMPNO,ENAME,SAL,DEPTNO) SELECT EMPNO,ENAME,SAL,@DNO FROM INSERTED
END

INSERT INTO EMPDEP_VIEW VALUES(110,'ASEER',12000,'SALES')
INSERT INTO EMPDEP_VIEW VALUES(110,'ASEER',12000,'SALES MANAFER')--ERROR(DEPT NO NOT EXISTS)
SELECT * FROM EMP
SELECT * FROM EMPDEP_VIEW

--UPDATE TRIGGER
ALTER TRIGGER UPDATE_VIEW
ON EMPDEP_VIEW
INSTEAD OF UPDATE
AS
BEGIN
	IF(UPDATE(EMPNO))
	BEGIN
		RAISERROR('EMPNO CANNOT BE UPDATED',16,1)
		RETURN
	END	
	IF(UPDATE(ENAME))
	BEGIN
		UPDATE EMP SET ENAME=I.ENAME FROM EMP E JOIN INSERTED I ON I.EMPNO=E.EMPNO
	END
	IF(UPDATE(SAL))
	BEGIN
		UPDATE EMP SET SAL=I.SAL FROM EMP E JOIN INSERTED I ON I.EMPNO=E.EMPNO
	END
	IF(UPDATE(DNAME))
	BEGIN
		DECLARE @DNO INT
		SELECT @DNO=D.DEPTNO FROM DEPT D JOIN INSERTED I  ON D.DNAME=I.DNAME
		IF(@DNO IS NULL)
		BEGIN
			RAISERROR('DEPT NO NOT EXISTS',16,1)
			RETURN
		END
		UPDATE EMP SET DEPTNO=@DNO FROM INSERTED I JOIN EMP E ON I.EMPNO=E.EMPNO
	END
END


UPDATE EMPDEP_VIEW SET EMPNO=2 WHERE EMPNO=1--ERROR
UPDATE EMPDEP_VIEW SET SAL=200 WHERE EMPNO=1
UPDATE EMPDEP_VIEW SET ENAME='SAMEERAMOMIN' WHERE EMPNO=1
SELECT * FROM EMPDEP_VIEW

--DELETE
CREATE TRIGGER DELETE_VIEW
ON EMPDEP_VIEW
INSTEAD OF DELETE
AS
BEGIN
	DELETE FROM EMP WHERE EMPNO IN (SELECT EMPNO FROM deleted)
END

DELETE FROM EMPDEP_VIEW WHERE EMPNO=1
SELECT * FROM EMP


