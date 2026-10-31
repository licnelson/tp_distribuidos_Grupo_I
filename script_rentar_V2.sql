-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: rentar
-- ------------------------------------------------------
-- Server version	8.4.11

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Bases utilizadas por el Hito 1 y el Hito 2/3.
-- Este dump contiene las tablas y datos del backend monolítico en `rentar`.
-- Vehicle Service utiliza `rentar_vehiculos`; Hibernate crea sus tablas al
-- iniciar el microservicio mediante spring.jpa.hibernate.ddl-auto=update.
CREATE DATABASE IF NOT EXISTS `rentar`;
USE `rentar`;
CREATE DATABASE IF NOT EXISTS `rentar_vehiculos`;

--
-- Table structure for table `reserva`
--

DROP TABLE IF EXISTS `reserva`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reserva` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `cliente_id` bigint NOT NULL,
  `vehiculo_id` bigint NOT NULL,
  `fecha_inicio` datetime NOT NULL,
  `fecha_fin` datetime NOT NULL,
  `precio_diario` decimal(10,2) NOT NULL,
  `importe_total` decimal(10,2) NOT NULL,
  `estado` enum('CONFIRMADA','CANCELADA') NOT NULL DEFAULT 'CONFIRMADA',
  PRIMARY KEY (`id`),
  KEY `fk_reserva_usuario` (`cliente_id`),
  KEY `fk_reserva_vehiculo` (`vehiculo_id`),
  CONSTRAINT `fk_reserva_usuario` FOREIGN KEY (`cliente_id`) REFERENCES `cliente` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reserva`
--

LOCK TABLES `reserva` WRITE;
/*!40000 ALTER TABLE `reserva` DISABLE KEYS */;
INSERT INTO `reserva` VALUES (1,3,3,'2026-10-01 10:00:00','2026-10-05 10:00:00',48000.00,192000.00,'CONFIRMADA'),(2,4,6,'2026-10-10 09:00:00','2026-10-14 09:00:00',58000.00,232000.00,'CONFIRMADA'),(3,5,10,'2026-10-15 08:00:00','2026-10-18 08:00:00',80000.00,240000.00,'CONFIRMADA'),(4,6,16,'2026-11-01 12:00:00','2026-11-03 12:00:00',140000.00,280000.00,'CONFIRMADA'),(5,7,1,'2026-10-20 10:00:00','2026-10-22 10:00:00',45000.00,90000.00,'CONFIRMADA'),(6,3,5,'2026-08-01 14:00:00','2026-08-04 14:00:00',60000.00,180000.00,'CANCELADA'),(7,8,9,'2026-08-10 11:00:00','2026-08-15 11:00:00',75000.00,375000.00,'CANCELADA'),(8,9,12,'2026-09-01 09:00:00','2026-09-03 09:00:00',38000.00,76000.00,'CANCELADA'),(9,4,15,'2026-07-15 10:00:00','2026-07-20 10:00:00',120000.00,600000.00,'CANCELADA'),(10,3,4,'2026-06-01 08:00:00','2026-06-05 08:00:00',35000.00,140000.00,'CONFIRMADA'),(11,5,8,'2026-06-10 10:00:00','2026-06-15 10:00:00',65000.00,325000.00,'CONFIRMADA'),(12,6,14,'2026-07-01 09:00:00','2026-07-04 09:00:00',40000.00,120000.00,'CONFIRMADA'),(13,10,2,'2026-05-12 10:00:00','2026-05-15 10:00:00',42000.00,126000.00,'CONFIRMADA');
/*!40000 ALTER TABLE `reserva` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cliente`
--

DROP TABLE IF EXISTS `cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cliente` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `documento` int NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `telefono` bigint DEFAULT NULL,
  `fecha_nacimiento` date NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `password` varchar(100) NOT NULL DEFAULT '',
  `es_admin` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `documento` (`documento`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cliente`
--

LOCK TABLES `cliente` WRITE;
/*!40000 ALTER TABLE `cliente` DISABLE KEYS */;
INSERT INTO `cliente` (`id`, `documento`, `nombre`, `apellido`, `email`, `telefono`, `fecha_nacimiento`, `activo`, `password`, `es_admin`) VALUES (1,10000001,'Admin','Sistema','admin@rentar.com',1100000001,'1980-01-01',1,'$2a$10$6ojbKlo4U.G71wfrhrY/2egypRhUrDwB7h0UdJACdyCJImFXjahXC',1),(2,20000001,'Juan','Pérez','juan.perez@example.com',1144440001,'1990-03-15',1,'',0),(3,20000002,'Maria','González','maria.gonzalez@example.com',1144440002,'1992-07-22',1,'',0),(4,20000003,'Lucas','Rodríguez','lucas.rodriguez@example.com',1144440003,'1988-11-05',1,'',0),(5,20000004,'Ana','Martínez','ana.martinez@example.com',1144440004,'1995-01-30',1,'',0),(6,20000005,'Roberto','Sánchez','roberto.sanchez@example.com',1144440005,'1982-09-18',1,'',0),(7,20000006,'Sofia','López','sofia.lopez@example.com',1144440006,'1998-04-12',1,'',0),(8,20000007,'Diego','Fernández','diego.fernandez@example.com',1144440007,'1991-12-08',1,'',0),(9,20000008,'Laura','Díaz','laura.diaz@example.com',1144440008,'1987-06-25',1,'',0),(10,30000001,'Esteban','Quito','esteban.quito@example.com',1155550001,'1993-02-14',0,'',0),(11,30000002,'Valeria','Blanco','valeria.blanco@example.com',1155550002,'1996-10-20',0,'',0);
/*!40000 ALTER TABLE `cliente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehiculo`
--

DROP TABLE IF EXISTS `vehiculo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehiculo` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `patente` varchar(20) NOT NULL,
  `marca` varchar(50) NOT NULL,
  `modelo` varchar(50) NOT NULL,
  `anio` int NOT NULL,
  `color` varchar(30) DEFAULT NULL,
  `tipo_vehiculo` enum('SEDAN','SUV','PICKUP','COUPE','HATCHBACK') NOT NULL,
  `precio_diario` decimal(10,2) NOT NULL,
  `estado` enum('DISPONIBLE','RESERVADO','EN_ALQUILER') NOT NULL DEFAULT 'DISPONIBLE',
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `patente` (`patente`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehiculo`
--

LOCK TABLES `vehiculo` WRITE;
/*!40000 ALTER TABLE `vehiculo` DISABLE KEYS */;
INSERT INTO `vehiculo` VALUES (1,'AAA111','Toyota','Corolla',2022,'Gris','SEDAN',45000.00,'DISPONIBLE',1),(2,'AAA112','Chevrolet','Cruze',2021,'Blanco','SEDAN',42000.00,'DISPONIBLE',1),(3,'AAA113','Nissan','Sentra',2023,'Negro','SEDAN',48000.00,'RESERVADO',1),(4,'AAA114','Fiat','Cronos',2020,'Rojo','SEDAN',35000.00,'EN_ALQUILER',1),(5,'BBB221','Volkswagen','Taos',2024,'Blanco','SUV',60000.00,'DISPONIBLE',1),(6,'BBB222','Jeep','Renegade',2022,'Verde','SUV',58000.00,'RESERVADO',1),(7,'BBB223','Honda','HR-V',2023,'Gris','SUV',62000.00,'DISPONIBLE',1),(8,'BBB224','Ford','Territory',2023,'Azul','SUV',65000.00,'EN_ALQUILER',1),(9,'CCC331','Ford','Ranger',2023,'Negro','PICKUP',75000.00,'DISPONIBLE',1),(10,'CCC332','Toyota','Hilux',2024,'Rojo','PICKUP',80000.00,'RESERVADO',1),(11,'CCC333','Volkswagen','Amarok',2022,'Plata','PICKUP',78000.00,'DISPONIBLE',1),(12,'DDD441','Peugeot','208',2021,'Azul','HATCHBACK',38000.00,'DISPONIBLE',1),(13,'DDD442','Renault','Sandero',2020,'Gris','HATCHBACK',32000.00,'DISPONIBLE',1),(14,'DDD443','Volkswagen','Polo',2023,'Negro','HATCHBACK',40000.00,'EN_ALQUILER',1),(15,'EEE551','Ford','Mustang',2020,'Rojo','COUPE',120000.00,'DISPONIBLE',1),(16,'EEE552','BMW','Serie 4',2022,'Negro','COUPE',140000.00,'RESERVADO',1),(17,'ZZZ991','Renault','Clio',2015,'Blanco','HATCHBACK',25000.00,'DISPONIBLE',0),(18,'ZZZ992','Fiat','Siena',2016,'Gris','SEDAN',28000.00,'DISPONIBLE',0);
/*!40000 ALTER TABLE `vehiculo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Inicialización de Vehicle Service en la base separada `rentar_vehiculos`.
--

CREATE TABLE IF NOT EXISTS `rentar_vehiculos`.`vehiculo` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `activo` bit(1) DEFAULT NULL,
  `anio` int DEFAULT NULL,
  `color` varchar(255) DEFAULT NULL,
  `estado` enum('DISPONIBLE','EN_ALQUILER','RESERVADO','VEHICLE_STATUS_UNSPECIFIED') DEFAULT NULL,
  `marca` varchar(255) NOT NULL,
  `modelo` varchar(255) NOT NULL,
  `patente` varchar(255) NOT NULL,
  `precio_diario` double NOT NULL,
  `tipo` enum('COUPE','HATCHBACK','PICKUP','SEDAN','SUV','VEHICLE_TYPE_UNSPECIFIED') DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_vehiculo_patente_hito3` (`patente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `rentar_vehiculos`.`vehiculo`
  (`id`, `patente`, `marca`, `modelo`, `anio`, `color`, `tipo`, `precio_diario`, `estado`, `activo`)
SELECT
  v.`id`, v.`patente`, v.`marca`, v.`modelo`, v.`anio`, v.`color`,
  v.`tipo_vehiculo`, v.`precio_diario`, v.`estado`, v.`activo`
FROM `rentar`.`vehiculo` v
LEFT JOIN `rentar_vehiculos`.`vehiculo` existente
  ON existente.`id` = v.`id` OR existente.`patente` = v.`patente`
WHERE existente.`id` IS NULL AND existente.`patente` IS NULL;

SET @next_vehicle_id = (SELECT COALESCE(MAX(`id`), 0) + 1 FROM `rentar_vehiculos`.`vehiculo`);
SET @sql = CONCAT('ALTER TABLE `rentar_vehiculos`.`vehiculo` AUTO_INCREMENT = ', @next_vehicle_id);
PREPARE set_auto_increment FROM @sql;
EXECUTE set_auto_increment;
DEALLOCATE PREPARE set_auto_increment;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-11 23:55:18
ALTER TABLE `rentar_vehiculos`.`vehiculo` MODIFY COLUMN `estado` enum('DISPONIBLE','EN_ALQUILER','RESERVADO','VEHICLE_STATUS_UNSPECIFIED','PENDIENTE');
