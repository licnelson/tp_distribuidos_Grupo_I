# Documentación y Pruebas del Sistema Rentar

## 1. Resumen Ejecutivo y Arquitectura
El sistema Rentar es una plataforma distribuida armada para el alquiler de vehículos. Está compuesta por:
- **API Gateway**: Hecho en Python con FastAPI. Actúa como punto de entrada, manejando la autenticación JWT y enrutando los pedidos hacia los microservicios gRPC.
- **Microservicios Backend**: Escritos en Java 17 con Spring Boot. Incluyen vehicle-service, customer-service y rental-service.
- **Comunicación Sincrónica**: Funciona a través de gRPC, lo que permite que los servicios charlen de forma rápida y eficiente.
- **Comunicación Asincrónica**: Usa RabbitMQ (`rentar.events`) para eventos pesados, como mandar a verificar los vehículos.
- **Persistencia**: MySQL con bases de datos divididas para cada servicio.

## 2. Cambios y Mejoras en la rama dev
1. **Autenticación del Administrador**: Resulta que la contraseña de admin en la base de datos estaba vacía. Le generamos el hash válido de BCrypt y lo mandamos directo al script SQL.
2. **Resolución de 404 en Vehículos**: El API Gateway ruteaba mal el endpoint de vehículos. Ajustamos el APIRouter al prefijo `/api/vehiculos` y quedó resuelto el 404 Not Found.
3. **Registro de Vehículos Externos**: Para que los clientes puedan registrar sus vehículos, agregamos el estado `PENDIENTE` al ENUM de la tabla `vehiculo` en MySQL.

## 3. Guía de Instalación y Ejecución
**Requisitos**: Java 17, Maven, Python 3.12, MySQL, RabbitMQ.

**Variables de Entorno**:
```env
JWT_SECRET="RentarClaveSecreta2026ParaJWT123456789"
DB_PORT=3306
DB_USER=root
DB_PASSWORD=root
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
RABBITMQ_USERNAME=rentar
RABBITMQ_PASSWORD=rentar
```

**Comandos**:
```bash
mvn spring-boot:run -f customer-service/pom.xml
mvn spring-boot:run -f vehicle-service/pom.xml
mvn spring-boot:run -f rental-service/pom.xml -Dspring-boot.run.main-class=ar.unla.rentar.rental.RentalServiceApplication
cd api-gateway && uvicorn app.main:app --reload
```

## 4. Catálogo de Endpoints REST
| Ruta HTTP | Método | Descripción |
| --- | --- | --- |
| `/health` | GET | Salud del API Gateway |
| `/auth/login` | POST | Autenticación de cliente/admin (te tira el token) |
| `/api/clientes` | POST | Registro de nuevo cliente |
| `/api/vehiculos` | GET | Listar vehículos |
| `/api/vehiculos` | POST | Registrar vehículo (Solo para Admin) |
| `/api/vehiculos/externos` | POST | Registrar vehículo de cliente (queda como Pendiente) |
| `/api/reservas` | POST | Crear una nueva reserva |

## 5. Reporte Detallado de Pruebas (QA)
| Caso de Prueba | Payload (Entrada) | Código HTTP y Respuesta | Resultado |
| --- | --- | --- | --- |
| Salud | N/A | 200 OK | PASS |
| Registro Cliente | JSON de Cliente | 201 Created | PASS |
| Login Admin | email/password | 200 OK (Trae el Token) | PASS |
| Listar Vehículos | Lleva el Token | 200 OK | PASS |
| Crear Reserva | JSON de Reserva | 201 Created | PASS |
| Vehículo Externo | JSON Vehículo | 201 Created | PASS |
