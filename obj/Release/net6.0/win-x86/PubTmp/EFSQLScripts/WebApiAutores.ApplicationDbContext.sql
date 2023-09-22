﻿DROP PROCEDURE IF EXISTS `MYSQL_BEFORE_DROP_PRIMARY_KEY`;
  DELIMITER //
  CREATE PROCEDURE `MYSQL_BEFORE_DROP_PRIMARY_KEY`(IN `SCHEMA_NAME_ARGUMENT` VARCHAR(255), IN `TABLE_NAME_ARGUMENT` VARCHAR(255))
  BEGIN
    DECLARE HAS_AUTO_INCREMENT_ID TINYINT(1);
    DECLARE PRIMARY_KEY_COLUMN_NAME VARCHAR(255);
    DECLARE PRIMARY_KEY_TYPE VARCHAR(255);
    DECLARE SQL_EXP VARCHAR(1000);
    SELECT COUNT(*)
    INTO HAS_AUTO_INCREMENT_ID
    FROM `information_schema`.`COLUMNS`
    WHERE `TABLE_SCHEMA` = (SELECT IFNULL(SCHEMA_NAME_ARGUMENT, SCHEMA()))
      AND `TABLE_NAME` = TABLE_NAME_ARGUMENT
      AND `Extra` = 'auto_increment'
      AND `COLUMN_KEY` = 'PRI'
      LIMIT 1;
    IF HAS_AUTO_INCREMENT_ID THEN
    SELECT `COLUMN_TYPE`
      INTO PRIMARY_KEY_TYPE
      FROM `information_schema`.`COLUMNS`
      WHERE `TABLE_SCHEMA` = (SELECT IFNULL(SCHEMA_NAME_ARGUMENT, SCHEMA()))
      AND `TABLE_NAME` = TABLE_NAME_ARGUMENT
      AND `COLUMN_KEY` = 'PRI'
      LIMIT 1;
    SELECT `COLUMN_NAME`
      INTO PRIMARY_KEY_COLUMN_NAME
      FROM `information_schema`.`COLUMNS`
      WHERE `TABLE_SCHEMA` = (SELECT IFNULL(SCHEMA_NAME_ARGUMENT, SCHEMA()))
      AND `TABLE_NAME` = TABLE_NAME_ARGUMENT
      AND `COLUMN_KEY` = 'PRI'
      LIMIT 1;
    SET SQL_EXP = CONCAT('ALTER TABLE `', (SELECT IFNULL(SCHEMA_NAME_ARGUMENT, SCHEMA())), '`.`', TABLE_NAME_ARGUMENT, '` MODIFY COLUMN `', PRIMARY_KEY_COLUMN_NAME, '` ', PRIMARY_KEY_TYPE, ' NOT NULL;');
    SET @SQL_EXP = SQL_EXP;
    PREPARE SQL_EXP_EXECUTE FROM @SQL_EXP;
    EXECUTE SQL_EXP_EXECUTE;
    DEALLOCATE PREPARE SQL_EXP_EXECUTE;
    END IF;
  END //
  DELIMITER ;

DROP PROCEDURE IF EXISTS `MYSQL_AFTER_ADD_PRIMARY_KEY`;
  DELIMITER //
  CREATE PROCEDURE `MYSQL_AFTER_ADD_PRIMARY_KEY`(IN `SCHEMA_NAME_ARGUMENT` VARCHAR(255), IN `TABLE_NAME_ARGUMENT` VARCHAR(255), IN `COLUMN_NAME_ARGUMENT` VARCHAR(255))
  BEGIN
    DECLARE HAS_AUTO_INCREMENT_ID INT(11);
    DECLARE PRIMARY_KEY_COLUMN_NAME VARCHAR(255);
    DECLARE PRIMARY_KEY_TYPE VARCHAR(255);
    DECLARE SQL_EXP VARCHAR(1000);
    SELECT COUNT(*)
    INTO HAS_AUTO_INCREMENT_ID
    FROM `information_schema`.`COLUMNS`
    WHERE `TABLE_SCHEMA` = (SELECT IFNULL(SCHEMA_NAME_ARGUMENT, SCHEMA()))
      AND `TABLE_NAME` = TABLE_NAME_ARGUMENT
      AND `COLUMN_NAME` = COLUMN_NAME_ARGUMENT
      AND `COLUMN_TYPE` LIKE '%int%'
      AND `COLUMN_KEY` = 'PRI';
    IF HAS_AUTO_INCREMENT_ID THEN
    SELECT `COLUMN_TYPE`
      INTO PRIMARY_KEY_TYPE
      FROM `information_schema`.`COLUMNS`
      WHERE `TABLE_SCHEMA` = (SELECT IFNULL(SCHEMA_NAME_ARGUMENT, SCHEMA()))
      AND `TABLE_NAME` = TABLE_NAME_ARGUMENT
      AND `COLUMN_NAME` = COLUMN_NAME_ARGUMENT
      AND `COLUMN_TYPE` LIKE '%int%'
      AND `COLUMN_KEY` = 'PRI';
    SELECT `COLUMN_NAME`
      INTO PRIMARY_KEY_COLUMN_NAME
      FROM `information_schema`.`COLUMNS`
      WHERE `TABLE_SCHEMA` = (SELECT IFNULL(SCHEMA_NAME_ARGUMENT, SCHEMA()))
      AND `TABLE_NAME` = TABLE_NAME_ARGUMENT
      AND `COLUMN_NAME` = COLUMN_NAME_ARGUMENT
      AND `COLUMN_TYPE` LIKE '%int%'
      AND `COLUMN_KEY` = 'PRI';
    SET SQL_EXP = CONCAT('ALTER TABLE `', (SELECT IFNULL(SCHEMA_NAME_ARGUMENT, SCHEMA())), '`.`', TABLE_NAME_ARGUMENT, '` MODIFY COLUMN `', PRIMARY_KEY_COLUMN_NAME, '` ', PRIMARY_KEY_TYPE, ' NOT NULL AUTO_INCREMENT;');
    SET @SQL_EXP = SQL_EXP;
    PREPARE SQL_EXP_EXECUTE FROM @SQL_EXP;
    EXECUTE SQL_EXP_EXECUTE;
    DEALLOCATE PREPARE SQL_EXP_EXECUTE;
    END IF;
  END //
  DELIMITER ;

CREATE TABLE IF NOT EXISTS `__EFMigrationsHistory` (
    `MigrationId` varchar(150) NOT NULL,
    `ProductVersion` varchar(32) NOT NULL,
    PRIMARY KEY (`MigrationId`)
);

START TRANSACTION;

IF NOT EXISTS(SELECT * FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20230911193909_Initial')
BEGIN
    CREATE TABLE `Autores` (
        `Id` int NOT NULL,
        `Nombre` nvarchar(120) NULL,
        PRIMARY KEY (`Id`)
    );
END;

IF NOT EXISTS(SELECT * FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20230911193909_Initial')
BEGIN
    CREATE TABLE `Libros` (
        `Id` int NOT NULL,
        `Nombre` nvarchar(250) NULL,
        PRIMARY KEY (`Id`)
    );
END;

IF NOT EXISTS(SELECT * FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20230911193909_Initial')
BEGIN
    INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
    VALUES ('20230911193909_Initial', '7.0.10');
END;

COMMIT;

START TRANSACTION;

IF NOT EXISTS(SELECT * FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20230912192306_Comentarios')
BEGIN
    ALTER TABLE `Libros` MODIFY `Nombre` nvarchar(250) NOT NULL DEFAULT '';
END;

IF NOT EXISTS(SELECT * FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20230912192306_Comentarios')
BEGIN
    CREATE TABLE `Comentario` (
        `Id` int NOT NULL,
        `Contenido` nvarchar(max) NULL,
        `LibroId` int NOT NULL,
        PRIMARY KEY (`Id`),
        CONSTRAINT `FK_Comentario_Libros_LibroId` FOREIGN KEY (`LibroId`) REFERENCES `Libros` (`Id`) ON DELETE CASCADE
    );
END;

IF NOT EXISTS(SELECT * FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20230912192306_Comentarios')
BEGIN
    CREATE INDEX `IX_Comentario_LibroId` ON `Comentario` (`LibroId`);
END;

IF NOT EXISTS(SELECT * FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20230912192306_Comentarios')
BEGIN
    INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
    VALUES ('20230912192306_Comentarios', '7.0.10');
END;

COMMIT;

START TRANSACTION;

IF NOT EXISTS(SELECT * FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20230912193945_ModifComentario')
BEGIN
    ALTER TABLE `Comentario` DROP CONSTRAINT `FK_Comentario_Libros_LibroId`;
END;

IF NOT EXISTS(SELECT * FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20230912193945_ModifComentario')
BEGIN
    ALTER TABLE Comentario RENAME Comentarios;
END;

IF NOT EXISTS(SELECT * FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20230912193945_ModifComentario')
BEGIN
    ALTER TABLE `Comentarios` RENAME INDEX `IX_Comentario_LibroId` TO `IX_Comentarios_LibroId`;
END;

IF NOT EXISTS(SELECT * FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20230912193945_ModifComentario')
BEGIN
    ALTER TABLE `Comentarios` ADD CONSTRAINT `FK_Comentarios_Libros_LibroId` FOREIGN KEY (`LibroId`) REFERENCES `Libros` (`Id`) ON DELETE CASCADE;
END;

IF NOT EXISTS(SELECT * FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20230912193945_ModifComentario')
BEGIN
    INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
    VALUES ('20230912193945_ModifComentario', '7.0.10');
END;

COMMIT;

START TRANSACTION;

IF NOT EXISTS(SELECT * FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20230913185321_AutorLibro')
BEGIN
    CREATE TABLE `AutoresLibros` (
        `LibroId` int NOT NULL,
        `AutorId` int NOT NULL,
        `Orden` int NOT NULL,
        PRIMARY KEY (`AutorId`, `LibroId`),
        CONSTRAINT `FK_AutoresLibros_Autores_AutorId` FOREIGN KEY (`AutorId`) REFERENCES `Autores` (`Id`) ON DELETE CASCADE,
        CONSTRAINT `FK_AutoresLibros_Libros_LibroId` FOREIGN KEY (`LibroId`) REFERENCES `Libros` (`Id`) ON DELETE CASCADE
    );
END;

IF NOT EXISTS(SELECT * FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20230913185321_AutorLibro')
BEGIN
    CREATE INDEX `IX_AutoresLibros_LibroId` ON `AutoresLibros` (`LibroId`);
END;

IF NOT EXISTS(SELECT * FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20230913185321_AutorLibro')
BEGIN
    INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
    VALUES ('20230913185321_AutorLibro', '7.0.10');
END;

COMMIT;

START TRANSACTION;

IF NOT EXISTS(SELECT * FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20230914183913_FechaPublicacion')
BEGIN
    ALTER TABLE `Libros` ADD `FechaPublicacion` datetime2 NULL;
END;

IF NOT EXISTS(SELECT * FROM `__EFMigrationsHistory` WHERE `MigrationId` = '20230914183913_FechaPublicacion')
BEGIN
    INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
    VALUES ('20230914183913_FechaPublicacion', '7.0.10');
END;

COMMIT;

DROP PROCEDURE `MYSQL_BEFORE_DROP_PRIMARY_KEY`;

DROP PROCEDURE `MYSQL_AFTER_ADD_PRIMARY_KEY`;

