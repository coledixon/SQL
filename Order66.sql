
USE GrandArmyOfTheRepublic
GO

CREATE PROC Order66
AS

DROP TABLE Jedi_Order

GO

IF EXISTS(SELECT 1 FROM Jedi_Order)
BEGIN
	EXEC Order66
END
GO
